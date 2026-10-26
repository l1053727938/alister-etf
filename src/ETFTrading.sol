// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {IETFTrading} from "./interfaces/IETFTrading.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {FullMath} from "./libraries/FullMath.sol";
contract ETFTrading is IETFTrading, ERC20, Ownable {
    using FullMath for uint256;
    uint24 internal _investFee;
    uint24 internal _redeemFee;
    address internal _feeTo;
    address public immutable swapRouter;
    uint256 internal _minMintAmount;
    address[] internal _tokens;

    mapping(address => bool) internal _isTokenExists;

    uint256[] private _initTokenAmountPerShares;

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory tokens_,
        uint256[] memory initTokenAmountPerShares_,
        uint256 minMintAmount_,
        address swapRouter_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(
            tokens_.length > 0,
            "ETFTrading: tokens length must be greater than 0"
        );

        require(
            tokens_.length == initTokenAmountPerShares_.length,
            "ETFTrading: tokens and initTokenAmountPerShares length mismatch"
        );
        
        require(
            swapRouter_ != address(0),
            "ETFTrading: swapRouter is zero address"
        );
        _tokens = tokens_;
        _initTokenAmountPerShares = initTokenAmountPerShares_;
        _minMintAmount = minMintAmount_;
        swapRouter = swapRouter_;

        for (uint256 i = 0; i < tokens_.length; i++) {
            require(
                tokens_[i] != address(0),
                "ETFTrading: token address is zero"
            );
            _isTokenExists[tokens_[i]] = true;
        }
    }

    function setFee(
        address feeTo_,
        uint24 investFee_,
        uint24 redeemFee_
    ) external virtual override {
        _feeTo = feeTo_;
        _investFee = investFee_;
        _redeemFee = redeemFee_;
    }

    function getInvestTokenAmounts(
        uint256 mintAmount
    ) public view returns (uint256[] memory tokenAmounts) {
        uint256 totalSupply = totalSupply();
        tokenAmounts = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (totalSupply > 0) {
                uint256 tokenReserve=IERC20(_tokens[i]).balanceOf(address(this));
                
                tokenAmounts[i] = tokenReserve.mulDivRoundingUp(mintAmount, totalSupply);
            } else {
                tokenAmounts[i] =mintAmount.mulDivRoundingUp(_initTokenAmountPerShares[i], 1e18);
            }
        }
    }
}
