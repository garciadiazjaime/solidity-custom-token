pragma solidity ^0.4.24;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./ChToken.sol";

/** This is an assignment to create a smart contract that allows you to run your own token crowdsale.
 *  Your contract will mint your custom token every time a purchase is made by your or your classmates.
 *  We've provided you with the pseudocode and some hints to guide you in the right direction.
 *  Make sure to implement the best practices you learned during the Solidity Walkthrough segment.
 *  Check for errors by compiling often. Ask your classmates for help - we highly encourage student collaboration.
 *  You should be able to deploy your crowdsale contract onto the Kovan testnet and buy/sell your classmates' tokens.
 */

 // Set up your contract.
contract MintedCrowdsale {
    using SafeMath for uint256;

    // Define 4 publicly accessible state variables.
    // Your custom token being sold.
    // Wallet address where funds are collected.
    // Rate of how many token units a buyer gets per wei. Note that wei*10^-18 converts to ether.
    // Amount of wei raised.
    ChToken public chToken;
    address public walletAddress;
    uint public rate;
    uint public weiRaised = 0;

    /** Create event to log token purchase with 4 parameters:
    * 1) Who paid for the tokens
    * 2) Who got the tokens
    * 3) Number of weis paid for purchase
    * 4) Amount of tokens purchased
    */
    event TokenPurchase(address indexed payer, address indexed buyer, uint weis, uint tokens);

    /** Create publicly accessible constructor function with 3 parameters:
    * 1) Rate of how many token units a buyer gets per wei
    * 2) Wallet address where funds are collected
    * 3) Address of your custom token being sold
    * Function modifiers are incredibly useful and effective. Make sure to use the right ones for each Solidity function you write.
    */
    constructor (uint _rate, address _walletAddress, ChToken _chTokenAddress) public payable {
        require(_rate >= 0, "Rate needs to be a positive number");
        require(_walletAddress != address(0), "Wallett address can not be zero");
        require(_chTokenAddress != address(0), "ChToken address can not be zero");

        rate = _rate;
        walletAddress = _walletAddress;
        chToken = _chTokenAddress;
    }

    // Create the fallback function that is called whenever anyone sends funds to this contract.
    // Fallback functions are functions without a name that serve as a default function.
    // Functions dealing with funds have a special modifier.
    function () external payable {
        // Call buyTokens function with the address defaulting to the address the message originates from.
        buyTokens(msg.sender);
    }

    // Create the function used for token purchase with one parameter for the address performing the token purchase.
    function buyTokens(address _beneficiary) public payable returns(uint) {
        uint weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        uint tokens = _getTokenAmount(weiAmount);

        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);

        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        // Call function that stores ETH from purchases into a wallet address.
        _forwardFunds();
    }

    // THIS PORTION IS FOR THE CONTRACT'S INTERNAL INTERFACE.
    // Remember, the following functions are for the contract's internal interface.

    // Create function that validates an incoming purchase with two parameters: beneficiary's address and value of wei.
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal pure {
        // Set conditions to make sure the beneficiary's address and the value of wei involved in purchase are non-zero.
        require(_beneficiary != address(0), "Beneficiary address can not be zero");
        require(_weiAmount != 0, "Value can not be zero");
    }

    // Create function that delivers the purchased tokens with two parameters: beneficiary's address and number of tokens.
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        // Set condition that requires contract to mint your custom token with the mint method inherited from your MintableToken contract.
        require(ChToken(chToken).mint(_beneficiary, _tokenAmount));
    }

    // Create function that executes the deliver function when a purchase has been processed with two parameters: beneficiary's address and number of tokens.
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    // Create function to convert purchase value in wei into tokens with one parameter: value in wei.
    // Write the function so that it returns the number of tokens (value in wei multiplied by defined rate).
    // Multiplication can be done as a method.
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint) {
        return _weiAmount.mul(rate);
    }

    // Create function to store ETH from purchases into a wallet address.
    function _forwardFunds() internal {
        walletAddress.transfer(msg.value);
    }
 }
