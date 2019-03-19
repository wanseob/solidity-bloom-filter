const BloomFilter = artifacts.require('./BloomFilter.sol')

module.exports = function (deployer) {
  deployer.deploy(BloomFilter)
}
