const chai = require('chai')
const BigNumber = web3.BigNumber
chai.use(require('chai-bignumber')(BigNumber)).should()
const BloomFilter = artifacts.require('BloomFilter')

contract.only('BloomFilter', ([deployer, ...members]) => {
  let bloomFilter
  context('Test', async () => {
    before('Deploy library', async () => {
      bloomFilter = await BloomFilter.new()
    })
    describe('getHashCount()', async () =>{
      it('should return the hash function number using a fomula', async() => {
        let BIT_LEN = 256
        let itemNum = 32
        let expected = Math.ceil(BIT_LEN / (itemNum * Math.log(2)))
        let hashCount = await bloomFilter.getHashCount(itemNum)
        hashCount.toNumber().should.equal(expected)
      })
    })
    describe('addToBitmap()', async () => {
      let hashCount
      before(async()=>{
        hashCount = await bloomFilter.getHashCount(32)
      })
      it('should return same bitmap for the same item', async()=>{
        let bitmapA = await bloomFilter.addToBitmap(0, hashCount, web3.utils.sha3('a'))
        let bitmapB = await bloomFilter.addToBitmap(bitmapA, hashCount, web3.utils.sha3('a'))
        bitmapA.eq(bitmapB).should.equal(true)
      })
      it('should return different bitmap for differrent items', async()=>{
        let bitmapA = await bloomFilter.addToBitmap(0, hashCount, web3.utils.sha3('a'))
        let bitmapB = await bloomFilter.addToBitmap(bitmapA, hashCount, web3.utils.sha3('b'))
        bitmapB.eq(bitmapA).should.equal(false)
      })
    }) 
    describe('falsePositive()', async() => {
      let inclusionSet = ['a','b','c','d','e','f','g','h','i','j']
      let nonInclusionSet = ['k','l','m','n','o','p','q','r','s','t']
      let hashCount
      let bitmap
      before('Add items first', async() => {
        hashCount = await bloomFilter.getHashCount(32)
        bitmap = 0
        for(let item of inclusionSet) {
          bitmap = await bloomFilter.addToBitmap(bitmap, hashCount, web3.utils.sha3(item))
        }
      })
      it('should return true for items in the inclusion set', async () => {
        for(let item of inclusionSet) {
          let falsePositive = await bloomFilter.falsePositive(bitmap, hashCount, web3.utils.sha3(item))
          falsePositive.should.equal(true)
        }
      })
      it('should return false for items in the non inclusion set', async () => {
        for(let item of nonInclusionSet) {
          let falsePositive = await bloomFilter.falsePositive(bitmap, hashCount, web3.utils.sha3(item))
          falsePositive.should.equal(false)
        }
      })
    })
  })
})
