import * as ethers from 'ethers'
import * as config from './config.js'

let provider

const cfg = config[process.env.NODE_ENV]

if (cfg.network === 'ganache') {
  provider = new ethers.JsonRpcProvider(cfg.jsonRpcUrl)
} else if (cfg.network === 'rinkeby') {
  provider = new ethers.InfuraProvider(ethers.utils.getNetwork('rinkeby'), cfg.infuraApiToken)
}

const wallet1 = new ethers.Wallet(cfg.wallet1Password, provider)
const wallet2 = new ethers.Wallet(cfg.wallet2Password, provider)

export { wallet1, wallet2 }
