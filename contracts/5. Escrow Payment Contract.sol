// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EscrowPayment {
    address public payer;
    address public payee;
    address public arbiter;
    uint256 public amount;
    bool public isFunded;
    bool public isReleased;

    event FundDeposited(address indexed from, uint256 amount);
    event PaymentReleased(address indexed to, uint256 amount);
    event RefundIssued(address indexed to, uint256 amount);

    modifier onlyPayer() {
        require(msg.sender == payer, "Only payer can call this");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can call this");
        _;
    }

    constructor(address _payee, address _arbiter) payable {
        payer = msg.sender;
        payee = _payee;
        arbiter = _arbiter;
        amount = msg.value;
        isFunded = msg.value > 0;
    }

    // Function 1: Deposit funds into escrow (if not already funded)
    function deposit() external payable onlyPayer {
        require(!isFunded, "Already funded");
        require(msg.value > 0, "Must deposit some ether");
        amount = msg.value;
        isFunded = true;
        emit FundDeposited(msg.sender, msg.value);
    }

    // Function 2: Release funds to the payee
    function releaseFunds() external onlyArbiter {
        require(isFunded, "No funds to release");
        require(!isReleased, "Funds already released");
        isReleased = true;
        payable(payee).transfer(amount);
        emit PaymentReleased(payee, amount);
    }

    // Function 3: Refund funds to the payer
    function refund() external onlyArbiter {
        require(isFunded, "No funds to refund");
        require(!isReleased, "Funds already released");
        isFunded = false;
        payable(payer).transfer(amount);
        emit RefundIssued(payer, amount);
    }

    // Function 4: Get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Function 5: Check escrow status
    function getStatus() external view returns (string memory) {
        if (!isFunded) return "Not Funded";
        if (isReleased) return "Released to Payee";
        return "Funded and Pending";
    }
}

