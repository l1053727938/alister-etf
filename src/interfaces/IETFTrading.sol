//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;
interface IETFTrading{

    error LessThanMinMintAmount();
    error TokenNotFound();
    error TokenExists();
    error InvalidSwapPath(bytes swapPath);
    error InvalidArrayLength();
    error OverSlippage();

    
    event SafeTransferETHFailed();
    event InvestedWithETH(address to,uint256 mintMount,uint256 paidAmount);
    event InvestedWithToken(address indexed srcToken,address to,uint256 mintAmount,uint256 totalPaid);
    event RedeemedToETH(address to,uint256 burnAmount,uint256 receivedAmount);
    event RedeemedToToken(address indexed sdtToken,address to,uint256 burnAmount,uint256 receivedAmount);


    function setFee(address feeTo_,uint24 investFee_,uint24 redeemFee_)
    external;

    function getInvestTokenAmounts(uint256 mintAmount)
    external view returns (uint256[] memory tokenAmounts);

    function getRedeemTokenAmounts(uint256 burnAmount)
    external view returns (uint256[] memory tokenAmounts);

    function investWithToken(address srcToken,address to,uint256 mintAmount,
    uint256 maxSrcTokenAmount)
    external;

    function redeemToToken(address sdtToken,address to,uint256 burnAmount,
    uint256 minDstTokenAmount,
    bytes[] memory swapPaths)external;

    function getTokens() external view returns (address[] memory);
}