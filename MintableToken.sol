pragma solidity ^0.4.24;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

/** Create contract that extends the standard ERC20 token contract with minting capabilities.
 *  We've provided you with the pseudocode and some hints to guide you in the right direction.
 *  Some of the initial conditions are written out for you to ease you into writing the contracts.
 *  Make sure to implement the best practices you learned during the Solidity Walkthrough segment.
 *  Check for errors by compiling often. Ask your classmates for help - we highly encourage student collaboration.
 */

// Set up your contract so that it inherits functionality from OpenZeppelin's StandardToken and Ownable.
contract MintableToken is StandardToken, Ownable {
    bool public mintingFinished = false;
    address private owner;
    uint private totalSupply_;
    mapping (address => uint) private balances;

    event Mint(address indexed to, uint amount);
    event MintFinished();

    modifier canMint() {
        require(!mintingFinished, "Minting has already finished");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() public payable {
        owner = msg.sender;
    }

    // Create function to mint tokens with 2 parameters: the address that will receive the minted tokens and the amount of tokens to mint.
    function mint(address _to, uint _amount) public canMint payable returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        return true;
    }

    // Create function to stop minting new tokens. Modifiers modifiers modifiers.
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

    function getBalance(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply_;
    }
}
