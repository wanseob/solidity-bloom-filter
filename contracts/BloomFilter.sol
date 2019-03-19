pragma solidity >=0.4.21 < 0.6.0;

library BloomFilter {
    struct Filter {
        uint256 bitmap;
        uint8 hashCount;
    }
   
    /**
     * @dev It returns how many times it should be hashed, when the expected
     * number of input items is _itenNum.
     * @param _itemNum Expected number of input items
     */
    function getHashCount(uint _itemNum) public pure returns(uint8) {
        uint numOfHash = (256 * 144) / (_itemNum * 100) + 1;
        if(numOfHash < 256) return uint8(numOfHash);
        else return 255;
    }

    /**
     * @dev It returns updated bitmap when a new item is added into the bitmap
     * @param _bitmap Original bitmap
     * @param _hashCount How many times to hash. You should use the same value with the one
        which is used for the original bitmap.
     * @param _item Hash value of an item
     */
    function addToBitmap(uint256 _bitmap,  uint8 _hashCount, bytes32 _item) public pure returns(uint256 _newBitmap) {
        _newBitmap = _bitmap;
        require(_hashCount > 0, "Hash count can not be zero");
        for(uint i = 0; i < _hashCount; i++) {
            uint256 position = uint256(keccak256(abi.encodePacked(_item, i))) % 256;
            require(position < 256, "Overflow error");
            uint256 digest = 1 << position;
            _newBitmap = _newBitmap | digest;
        }
        return _newBitmap;
    }

    /**
     * @dev It returns it may exist or definitely not exist.
     * @param _bitmap Original bitmap
     * @param _hashCount How many times to hash. You should use the same value with the one
        which is used for the original bitmap.
     * @param _item Hash value of an item
     */
    function falsePositive(uint256 _bitmap,  uint8 _hashCount, bytes32 _item) public pure returns(bool _probablyPresent){
        require(_hashCount > 0, "Hash count can not be zero");
        for(uint i = 0; i < _hashCount; i++) {
            uint256 position = uint256(keccak256(abi.encodePacked(_item, i))) % 256;
            require(position < 256, "Overflow error");
            uint256 digest = 1 << position;
            if(_bitmap != _bitmap | digest) return false;
        }
        return true;
    }

    // Please see the test/TestBloomFilter.sol to know how to use this library in another contract.

    /**
     * @dev It initialize the Filter struct. It sets the appropriate hash count for the expected number of item
     * @param _itemNum Expected number of items to be added
     */
    function init(Filter storage _filter, uint _itemNum) internal {
        _filter.hashCount = getHashCount(_itemNum);
    }

    /**
     * @dev It updates the bitmap of the filter using the given item value
     * @param _item Hash value of an item
     */
    function add(Filter storage _filter, bytes32 _item) internal {
        _filter.bitmap = addToBitmap(_filter.bitmap, _filter.hashCount, _item);
    }

    /**
     * @dev It returns the filter may include the item or definitely now include it.
     * @param _item Hash value of an item
     */
    function check(Filter storage _filter, bytes32 _item) internal view returns(bool) {
        return falsePositive(_filter.bitmap, _filter.hashCount, _item);
    }
}
