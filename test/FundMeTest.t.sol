// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    //uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployfundMe = new DeployFundMe();
        fundMe = deployfundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
       
    }
    function testOwnerisMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }
    function testPriceFeedVersionIsACC() public {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }
    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        fundMe.fund();
    }
    function testFundUpdatesFundedDataStruct() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddresstoAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunder() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOnwerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        //act
        /*uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);*/
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
       /* uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);   test avec gas    */ 

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOnwerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numbersOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numbersOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawWithASingleFundercheaper() public funded {
        // Arrange
        uint256 startingOnwerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        //act
        /*uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);*/
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
       /* uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);   test avec gas    */ 

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOnwerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numbersOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numbersOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}