// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { CoreOwnable } from '../dependencies/CoreOwnable.sol';
import { IResupplyRegistry } from "../interfaces/IResupplyRegistry.sol";
import { IFeeDeposit } from "../interfaces/IFeeDeposit.sol";

//keep track of fees
contract FeeLogger is CoreOwnable {

    address public immutable registry;
    mapping(address => mapping(uint256 => uint256)) public pairEpochWeightings;
    mapping(uint256 => uint256) public epochInterestFees;
    mapping(uint256 => uint256) public epochTotalFees;

    event UpdateEpochTotalFees(uint256 indexed epoch, uint256 fees);
    event UpdateEpochInterestFees(uint256 indexed epoch, uint256 fees);
    event UpdatePairEpochFees(address indexed pair, uint256 indexed epoch, uint256 fees);

    constructor(
        address _core,
        address _registry
    ) CoreOwnable(_core){
        registry = _registry;
    }

    function updateTotalFees(uint256 _epoch, uint256 _amount) external{
        address feeDeposit = IResupplyRegistry(registry).feeDeposit();
        require(msg.sender == IFeeDeposit(feeDeposit).operator()
            || msg.sender == owner(), "!feeDepositOperator");


        //write total fees for epoch
        epochTotalFees[_epoch] = _amount;

        emit UpdateEpochTotalFees(_epoch, _amount);
    }
    
    function updateInterestFees(address _pair, uint256 _epoch, uint256 _amount) external{
        require(msg.sender == IResupplyRegistry(registry).rewardHandler()
            || msg.sender == owner(), "!rewardHandler");


        //write amount for given pair
        pairEpochWeightings[_pair][_epoch] = _amount;
        //write to state how much fees in interest this epoch collected
        uint256 total = epochInterestFees[_epoch] + _amount;
        epochInterestFees[_epoch] = total;

        emit UpdateEpochInterestFees(_epoch, total);
        emit UpdatePairEpochFees(_pair, _epoch, _amount);
    }
}