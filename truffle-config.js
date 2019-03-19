module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    },
    test: {
      host: '127.0.0.1',
      port: 8546,
      network_id: 1234321
    }
  }
}
