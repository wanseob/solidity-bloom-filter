pragma solidity >=0.4.21 < 0.6.0;

import "truffle/Assert.sol";
import "../contracts/BloomFilter.sol";

contract TestBloomFilter {
    using BloomFilter for BloomFilter.Filter;

    BloomFilter.Filter filter;

    function testInit() public {
        filter.init(10);
        Assert.equal(uint(filter.hashCount), uint(37), "Filter should have ");
    }

    function testAdd() public {
        filter.add('a');
        uint256 bitmapA = filter.bitmap;
        filter.add('a');
        uint256 bitmapB = filter.bitmap;
        Assert.equal(bitmapB, bitmapA, "Adding same item should not update the bitmap");

        filter.add('c');
        uint256 bitmapC = filter.bitmap;
        Assert.notEqual(bitmapC, bitmapB, "Adding different item should update the bitmap");
    }

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
