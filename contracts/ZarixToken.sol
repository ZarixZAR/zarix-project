
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZarixToken is ERC20, ERC20Burnable, Pausable, Ownable {
    mapping(address => bool) public frozenAccounts;
    mapping(address => uint256) public lockUntil;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public blacklisted;

    constructor() ERC20("Zarix", "ZAR") Ownable(msg.sender) {
        _mint(msg.sender, 500_000_000 * 10 ** decimals());
        whitelisted[msg.sender] = true;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function freezeAccount(address account) public onlyOwner {
        frozenAccounts[account] = true;
    }

    function unfreezeAccount(address account) public onlyOwner {
        frozenAccounts[account] = false;
    }

    function lockAccount(address account, uint256 timestamp) public onlyOwner {
        lockUntil[account] = timestamp;
    }

    function whitelistAddress(address account) public onlyOwner {
        whitelisted[account] = true;
    }

    function removeWhitelistAddress(address account) public onlyOwner {
        whitelisted[account] = false;
    }

    function blacklistAddress(address account) public onlyOwner {
        blacklisted[account] = true;
    }

    function removeBlacklistAddress(address account) public onlyOwner {
        blacklisted[account] = false;
    }

    function _update(address from, address to, uint256 value)
        internal
        override
    {
        require(!paused(), "ZAR: Token transfers are paused");
        require(!frozenAccounts[from], "ZAR: Sender account is frozen");
        require(block.timestamp >= lockUntil[from], "ZAR: Tokens are time-locked");
        require(!blacklisted[from] && !blacklisted[to], "ZAR: Blacklisted address");

        super._update(from, to, value);
    }
}
