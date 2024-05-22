// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import {PoolFactory} from "../../src/PoolFactory.sol";
import {ERC20Mock} from "../mocks/ERC20Mocks.sol";
import {Handler} from "./handler.t.sol";

contract Invariant is StdInvariant, Test {
    TSwapPool pool;
    PoolFactory factory;
    Handler handler;

    ERC20Mock weth;
    ERC20Mock poolToken;

    int256 constant STARTING_X = 100e18; //starting ERC20 / poolToken
    int256 constant STARTING_Y = 50e18; // starting weth

    //the pools have 2 assets

    function setUp() public {
        weth = new ERC20Mock();
        poolToken = new ERC20Mock();
        factory = new PoolFactory(address(weth));
        pool = TSwapPool(factory.createPool(address(poolToken)));

        poolToken.mint(address(this), uint256(STARTING_X));
        weth.mint(address(this), uint256(STARTING_Y));

        poolToken.approve(address(pool), type(uint256).max);
        weth.approve(address(pool), type(uint256).max);

        //deposit
        pool.deposit(
            uint256(STARTING_Y),
            uint256(STARTING_Y),
            uint256(STARTING_X),
            uint64(block.timestamp)
        );

        handler = new Handler(pool);

        bytes4[] memory selectors = new bytes4[](2);

        selectors[0] = handler.deposit.selector;
        selectors[1] = handler.swapPoolTOkenForWethBasedOnOutputweth.selector;
        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );

        targetContract(address(handler));
    }

    function invariant_constantProductStaysTheSame() public view {
        // assert??
        // the change in the pool size of weth should follow this function
        assertEq(handler.actualDeltaX(), handler.expectedDeltaX());
    }
    function invariant_constantProductStaysTheSameY() public view {
        // assert??
        // the change in the pool size of weth should follow this function
        assertEq(handler.actualDeltaY(), handler.expectedDeltaY());
    }
}
