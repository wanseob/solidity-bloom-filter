# Solidity Bloom Filter

[![npm](https://img.shields.io/npm/v/solidity-bloom-filter/latest.svg)](https://www.npmjs.com/package/solidity-bloom-filter)
[![Build Status](https://travis-ci.org/wanseob/solidity-bloom-filter.svg?branch=master)](https://travis-ci.org/wanseob/solidity-bloom-filter)

Mainnet: `0x9de80828ff54e961a41c3b31ca6e8eceadc8aef4`

## Usage

#### With struct

```solidity
pragma solidity >=0.4.21 < 0.6.0;

import "truffle/Assert.sol";
import "../contracts/BloomFilter.sol";

contract TestBloomFilter {
    using BloomFilter for BloomFilter.Filter;

    BloomFilter.Filter filter;

    // Initialize the filter with the expected number of items to add into the bitmap
    function testInit() public {
        filter.init(10);
        Assert.equal(uint(filter.hashCount), uint(37), "Filter should have ");
    }


    // It updates the bitmap of the filter with the received item.
    function testAdd() public {
        filter.add('a'); // Calling add() method will update the bitmap of the filter
        uint256 bitmapA = filter.bitmap;
        filter.add('a');
        uint256 bitmapB = filter.bitmap;
        Assert.equal(bitmapB, bitmapA, "Adding same item should not update the bitmap");

        filter.add('c');
        uint256 bitmapC = filter.bitmap;
        Assert.notEqual(bitmapC, bitmapB, "Adding different item should update the bitmap");
    }


    // It returns the item's false positive value. If it returns true, then
    // the item may exist or not. Otherwise, it definitely does not exist.
    function testCheck() public {
        string[10] memory inclusion = ['a','b','c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];
        string[10] memory nonInclusion = ['k','l','m', 'n', 'o', 'p', 'q', 'r', 's', 't'];
        for(uint i = 0; i < inclusion.length; i ++) {
            bytes32 key = keccak256(abi.encodePacked(inclusion[i]));
            filter.add(key);
        }
        for(uint j = 0; j < inclusion.length; j ++) {
            bytes32 key = keccak256(abi.encodePacked(inclusion[j])); 
            bool falsePositive = filter.check(key);
            // It may exist or not
            Assert.isTrue(falsePositive, "Should return false positive");
        }
        for(uint k = 0; k < nonInclusion.length; k ++) {
            bytes32 key = keccak256(abi.encodePacked(nonInclusion[k]));
            bool falsePositive = filter.check(key);
            // It definitely does not exist
            Assert.isFalse(falsePositive, "Should return definitely not exist");
        }
    }

}
```

## LICENSE

MIT LICENSE
