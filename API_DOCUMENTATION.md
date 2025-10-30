# LinkCoin API Documentation

Complete reference for LinkCoin RPC and REST API endpoints.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Blockchain Information](#blockchain-information)
- [Network Operations](#network-operations)
- [Wallet Operations](#wallet-operations)
- [Mining Operations](#mining-operations)
- [Raw Transactions](#raw-transactions)
- [Utility Commands](#utility-commands)
- [Docker Usage](#docker-usage)
- [Error Codes](#error-codes)

---

## Overview

LinkCoin provides a JSON-RPC interface for interacting with the blockchain. The API follows JSON-RPC 1.0 protocol and is accessible via HTTP.

### Connection Details

- **Default RPC Port**: 9600
- **Protocol**: JSON-RPC 1.0 over HTTP
- **Authentication**: HTTP Basic Auth (username/password)
- **Content-Type**: application/json

### Authentication

Configure in `linkcoin.conf`:
```ini
rpcuser=your_username
rpcpassword=your_secure_password
rpcport=9600
rpcallowip=127.0.0.1
```

---

## Getting Started

### Using linkcoin-cli

```bash
# Local daemon
./linkcoin-cli <command> [params]

# Example
./linkcoin-cli getinfo
./linkcoin-cli getblockcount
```

### Using Docker

```bash
# Execute commands in Docker container
docker-compose exec linkcoin linkcoind <command> [params]

# Examples
docker-compose exec linkcoin linkcoind getinfo
docker-compose exec linkcoin linkcoind getblockcount
docker-compose exec linkcoin linkcoind help
```

### Using HTTP/JSON-RPC

```bash
curl --user username:password --data-binary '{"jsonrpc":"1.0","id":"curltest","method":"getinfo","params":[]}' \
  -H 'content-type: text/plain;' http://127.0.0.1:9600/
```

---

## Blockchain Information

### getblockcount

Returns the number of blocks in the longest blockchain.

**Syntax:**
```bash
getblockcount
```

**Parameters:** None

**Returns:** `integer` - Current block height

**Example:**
```bash
./linkcoin-cli getblockcount
# Docker
docker-compose exec linkcoin linkcoind getblockcount
```

**Response:**
```json
245678
```

---

### getbestblockhash

Returns the hash of the best (tip) block in the longest blockchain.

**Syntax:**
```bash
getbestblockhash
```

**Parameters:** None

**Returns:** `string` - Block hash (hex)

**Example:**
```bash
./linkcoin-cli getbestblockhash
# Docker
docker-compose exec linkcoin linkcoind getbestblockhash
```

**Response:**
```json
"00000000000a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c"
```

---

### getblock

Returns information about a block with the given hash.

**Syntax:**
```bash
getblock <hash> [verbose]
```

**Parameters:**
- `hash` (string, required) - Block hash
- `verbose` (boolean, optional, default=true) - If false, returns hex-encoded data

**Returns:** `object` - Block information (if verbose=true)

**Example:**
```bash
./linkcoin-cli getblock "00000000000a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c"
# Docker
docker-compose exec linkcoin linkcoind getblock "00000000000a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c"
```

**Response:**
```json
{
  "hash": "00000000000a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c",
  "confirmations": 100,
  "size": 1234,
  "height": 245678,
  "version": 2,
  "merkleroot": "abc123...",
  "tx": ["txid1", "txid2", "..."],
  "time": 1234567890,
  "nonce": 987654321,
  "bits": "1a0a1b2c",
  "difficulty": 1.23456789,
  "previousblockhash": "000000...",
  "nextblockhash": "000000..."
}
```

---

### getblockhash

Returns the hash of the block at the specified height.

**Syntax:**
```bash
getblockhash <index>
```

**Parameters:**
- `index` (integer, required) - Block height

**Returns:** `string` - Block hash

**Example:**
```bash
./linkcoin-cli getblockhash 12345
# Docker
docker-compose exec linkcoin linkcoind getblockhash 12345
```

---

### getdifficulty

Returns the proof-of-work difficulty as a multiple of the minimum difficulty.

**Syntax:**
```bash
getdifficulty
```

**Parameters:** None

**Returns:** `number` - Current difficulty

**Example:**
```bash
./linkcoin-cli getdifficulty
# Docker
docker-compose exec linkcoin linkcoind getdifficulty
```

**Response:**
```json
1.23456789
```

---

### getrawmempool

Returns all transaction IDs in the memory pool.

**Syntax:**
```bash
getrawmempool
```

**Parameters:** None

**Returns:** `array` - Array of transaction IDs

**Example:**
```bash
./linkcoin-cli getrawmempool
# Docker
docker-compose exec linkcoin linkcoind getrawmempool
```

---

### gettxout

Returns details about an unspent transaction output.

**Syntax:**
```bash
gettxout <txid> <n> [includemempool]
```

**Parameters:**
- `txid` (string, required) - Transaction ID
- `n` (integer, required) - Output index
- `includemempool` (boolean, optional, default=true) - Include mempool

**Returns:** `object` - UTXO information or null if spent

**Example:**
```bash
./linkcoin-cli gettxout "abc123..." 0
# Docker
docker-compose exec linkcoin linkcoind gettxout "abc123..." 0
```

---

### gettxoutsetinfo

Returns statistics about the unspent transaction output set.

**Syntax:**
```bash
gettxoutsetinfo
```

**Parameters:** None

**Returns:** `object` - UTXO set statistics

**Example:**
```bash
./linkcoin-cli gettxoutsetinfo
# Docker
docker-compose exec linkcoin linkcoind gettxoutsetinfo
```

---

### verifychain

Verifies the blockchain database.

**Syntax:**
```bash
verifychain [checklevel] [numblocks]
```

**Parameters:**
- `checklevel` (integer, optional, default=3) - Thoroughness level (0-4)
- `numblocks` (integer, optional, default=288) - Number of blocks to check

**Returns:** `boolean` - Verification result

**Example:**
```bash
./linkcoin-cli verifychain
# Docker
docker-compose exec linkcoin linkcoind verifychain 3 1000
```

---

## Network Operations

### getconnectioncount

Returns the number of connections to other nodes.

**Syntax:**
```bash
getconnectioncount
```

**Parameters:** None

**Returns:** `integer` - Number of connections

**Example:**
```bash
./linkcoin-cli getconnectioncount
# Docker
docker-compose exec linkcoin linkcoind getconnectioncount
```

**Response:**
```json
8
```

---

### getpeerinfo

Returns data about each connected network node.

**Syntax:**
```bash
getpeerinfo
```

**Parameters:** None

**Returns:** `array` - Array of peer information objects

**Example:**
```bash
./linkcoin-cli getpeerinfo
# Docker
docker-compose exec linkcoin linkcoind getpeerinfo
```

**Response:**
```json
[
  {
    "addr": "192.168.1.100:9333",
    "services": "00000001",
    "lastsend": 1234567890,
    "lastrecv": 1234567890,
    "bytessent": 123456,
    "bytesrecv": 654321,
    "conntime": 1234567890,
    "version": 70002,
    "subver": "/LinkCoin:0.8.7.2/",
    "inbound": false,
    "startingheight": 245000,
    "banscore": 0
  }
]
```

---

### addnode

Attempts to add or remove a node from the addnode list, or try a connection once.

**Syntax:**
```bash
addnode <node> <add|remove|onetry>
```

**Parameters:**
- `node` (string, required) - Node IP address or hostname with port
- `command` (string, required) - 'add' to add, 'remove' to remove, 'onetry' to try once

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli addnode "192.168.1.100:9333" "add"
# Docker
docker-compose exec linkcoin linkcoind addnode "192.168.1.100:9333" "add"
```

---

### getaddednodeinfo

Returns information about manually added nodes.

**Syntax:**
```bash
getaddednodeinfo <dns> [node]
```

**Parameters:**
- `dns` (boolean, required) - If true, return DNS lookup info
- `node` (string, optional) - Specific node to query

**Returns:** `array` - Information about added nodes

**Example:**
```bash
./linkcoin-cli getaddednodeinfo true
# Docker
docker-compose exec linkcoin linkcoind getaddednodeinfo true
```

---

### getnetworkhashps

Returns the estimated network hashes per second.

**Syntax:**
```bash
getnetworkhashps [blocks] [height]
```

**Parameters:**
- `blocks` (integer, optional, default=120) - Number of blocks to average
- `height` (integer, optional, default=-1) - Block height (-1 for current)

**Returns:** `number` - Network hash rate

**Example:**
```bash
./linkcoin-cli getnetworkhashps
# Docker
docker-compose exec linkcoin linkcoind getnetworkhashps 120
```

---

## Wallet Operations

### getinfo

Returns general information about the node and wallet.

**Syntax:**
```bash
getinfo
```

**Parameters:** None

**Returns:** `object` - Node and wallet information

**Example:**
```bash
./linkcoin-cli getinfo
# Docker
docker-compose exec linkcoin linkcoind getinfo
```

**Response:**
```json
{
  "version": 80702,
  "protocolversion": 70002,
  "walletversion": 60000,
  "balance": 123.45678900,
  "blocks": 245678,
  "timeoffset": 0,
  "connections": 8,
  "proxy": "",
  "difficulty": 1.23456789,
  "testnet": false,
  "keypoololdest": 1234567890,
  "keypoolsize": 101,
  "paytxfee": 0.00000000,
  "mininput": 0.00001000,
  "errors": ""
}
```

---

### getnewaddress

Returns a new LinkCoin address for receiving payments.

**Syntax:**
```bash
getnewaddress [account]
```

**Parameters:**
- `account` (string, optional, default="") - Account name

**Returns:** `string` - New LinkCoin address

**Example:**
```bash
./linkcoin-cli getnewaddress
./linkcoin-cli getnewaddress "mining"
# Docker
docker-compose exec linkcoin linkcoind getnewaddress
docker-compose exec linkcoin linkcoind getnewaddress "mining"
```

**Response:**
```json
"LKCabcdef123456789ABCDEFGHIJK"
```

---

### getaccountaddress

Returns the current LinkCoin address for receiving payments to an account.

**Syntax:**
```bash
getaccountaddress <account>
```

**Parameters:**
- `account` (string, required) - Account name

**Returns:** `string` - LinkCoin address

**Example:**
```bash
./linkcoin-cli getaccountaddress "mining"
# Docker
docker-compose exec linkcoin linkcoind getaccountaddress "mining"
```

---

### getbalance

Returns the total available balance.

**Syntax:**
```bash
getbalance [account] [minconf]
```

**Parameters:**
- `account` (string, optional, default="*") - Account name, "*" for all
- `minconf` (integer, optional, default=1) - Minimum confirmations

**Returns:** `number` - Balance in LKC

**Example:**
```bash
./linkcoin-cli getbalance
./linkcoin-cli getbalance "mining" 6
# Docker
docker-compose exec linkcoin linkcoind getbalance
docker-compose exec linkcoin linkcoind getbalance "mining" 6
```

**Response:**
```json
123.45678900
```

---

### sendtoaddress

Sends an amount to a given address.

**Syntax:**
```bash
sendtoaddress <address> <amount> [comment] [comment-to]
```

**Parameters:**
- `address` (string, required) - LinkCoin address
- `amount` (number, required) - Amount in LKC (rounded to 8 decimals)
- `comment` (string, optional) - Transaction comment (not sent)
- `comment-to` (string, optional) - Recipient comment (not sent)

**Returns:** `string` - Transaction ID

**Example:**
```bash
./linkcoin-cli sendtoaddress "LKCabcdef123..." 10.5
./linkcoin-cli sendtoaddress "LKCabcdef123..." 10.5 "payment" "John"
# Docker
docker-compose exec linkcoin linkcoind sendtoaddress "LKCabcdef123..." 10.5
```

**Response:**
```json
"abc123def456...transaction_id"
```

**Note:** Requires wallet to be unlocked if encrypted.

---

### sendfrom

Sends an amount from an account to an address.

**Syntax:**
```bash
sendfrom <fromaccount> <toaddress> <amount> [minconf] [comment] [comment-to]
```

**Parameters:**
- `fromaccount` (string, required) - Account to send from
- `toaddress` (string, required) - LinkCoin address
- `amount` (number, required) - Amount in LKC
- `minconf` (integer, optional, default=1) - Minimum confirmations
- `comment` (string, optional) - Transaction comment
- `comment-to` (string, optional) - Recipient comment

**Returns:** `string` - Transaction ID

**Example:**
```bash
./linkcoin-cli sendfrom "mining" "LKCabcdef123..." 10.5
# Docker
docker-compose exec linkcoin linkcoind sendfrom "mining" "LKCabcdef123..." 10.5
```

---

### sendmany

Sends multiple amounts to multiple addresses.

**Syntax:**
```bash
sendmany <fromaccount> <amounts> [minconf] [comment]
```

**Parameters:**
- `fromaccount` (string, required) - Account to send from
- `amounts` (object, required) - JSON object with addresses and amounts
- `minconf` (integer, optional, default=1) - Minimum confirmations
- `comment` (string, optional) - Transaction comment

**Returns:** `string` - Transaction ID

**Example:**
```bash
./linkcoin-cli sendmany "" '{"LKCaddr1":10.5,"LKCaddr2":5.25}'
# Docker
docker-compose exec linkcoin linkcoind sendmany "" '{"LKCaddr1":10.5,"LKCaddr2":5.25}'
```

---

### gettransaction

Returns detailed information about an in-wallet transaction.

**Syntax:**
```bash
gettransaction <txid>
```

**Parameters:**
- `txid` (string, required) - Transaction ID

**Returns:** `object` - Transaction details

**Example:**
```bash
./linkcoin-cli gettransaction "abc123..."
# Docker
docker-compose exec linkcoin linkcoind gettransaction "abc123..."
```

**Response:**
```json
{
  "amount": 10.50000000,
  "confirmations": 100,
  "blockhash": "00000000...",
  "blockindex": 2,
  "blocktime": 1234567890,
  "txid": "abc123...",
  "normtxid": "def456...",
  "time": 1234567890,
  "timereceived": 1234567890,
  "details": [
    {
      "account": "",
      "address": "LKCabcdef123...",
      "category": "send",
      "amount": -10.50000000,
      "fee": -0.00010000
    }
  ]
}
```

---

### listtransactions

Returns up to 'count' most recent transactions for an account.

**Syntax:**
```bash
listtransactions [account] [count] [from]
```

**Parameters:**
- `account` (string, optional, default="*") - Account name
- `count` (integer, optional, default=10) - Number of transactions
- `from` (integer, optional, default=0) - Skip this many transactions

**Returns:** `array` - Array of transaction objects

**Example:**
```bash
./linkcoin-cli listtransactions
./linkcoin-cli listtransactions "mining" 20
# Docker
docker-compose exec linkcoin linkcoind listtransactions "" 10
```

---

### listaccounts

Returns account balances.

**Syntax:**
```bash
listaccounts [minconf]
```

**Parameters:**
- `minconf` (integer, optional, default=1) - Minimum confirmations

**Returns:** `object` - Object with account names and balances

**Example:**
```bash
./linkcoin-cli listaccounts
# Docker
docker-compose exec linkcoin linkcoind listaccounts 6
```

**Response:**
```json
{
  "": 100.50000000,
  "mining": 50.25000000,
  "savings": 200.00000000
}
```

---

### listunspent

Returns array of unspent transaction outputs.

**Syntax:**
```bash
listunspent [minconf] [maxconf] [addresses]
```

**Parameters:**
- `minconf` (integer, optional, default=1) - Minimum confirmations
- `maxconf` (integer, optional, default=9999999) - Maximum confirmations
- `addresses` (array, optional) - Filter by addresses

**Returns:** `array` - Array of unspent outputs

**Example:**
```bash
./linkcoin-cli listunspent
./linkcoin-cli listunspent 6 999999
# Docker
docker-compose exec linkcoin linkcoind listunspent
```

---

### getreceivedbyaddress

Returns the total amount received by an address.

**Syntax:**
```bash
getreceivedbyaddress <address> [minconf]
```

**Parameters:**
- `address` (string, required) - LinkCoin address
- `minconf` (integer, optional, default=1) - Minimum confirmations

**Returns:** `number` - Total amount received

**Example:**
```bash
./linkcoin-cli getreceivedbyaddress "LKCabcdef123..." 6
# Docker
docker-compose exec linkcoin linkcoind getreceivedbyaddress "LKCabcdef123..." 6
```

---

### getreceivedbyaccount

Returns the total amount received by an account.

**Syntax:**
```bash
getreceivedbyaccount <account> [minconf]
```

**Parameters:**
- `account` (string, required) - Account name
- `minconf` (integer, optional, default=1) - Minimum confirmations

**Returns:** `number` - Total amount received

**Example:**
```bash
./linkcoin-cli getreceivedbyaccount "mining" 6
# Docker
docker-compose exec linkcoin linkcoind getreceivedbyaccount "mining" 6
```

---

### listreceivedbyaddress

Returns list of addresses with received amounts.

**Syntax:**
```bash
listreceivedbyaddress [minconf] [includeempty]
```

**Parameters:**
- `minconf` (integer, optional, default=1) - Minimum confirmations
- `includeempty` (boolean, optional, default=false) - Include addresses with zero balance

**Returns:** `array` - Array of address objects

**Example:**
```bash
./linkcoin-cli listreceivedbyaddress 6 true
# Docker
docker-compose exec linkcoin linkcoind listreceivedbyaddress 6 true
```

---

### listreceivedbyaccount

Returns list of accounts with received amounts.

**Syntax:**
```bash
listreceivedbyaccount [minconf] [includeempty]
```

**Parameters:**
- `minconf` (integer, optional, default=1) - Minimum confirmations
- `includeempty` (boolean, optional, default=false) - Include accounts with zero balance

**Returns:** `array` - Array of account objects

**Example:**
```bash
./linkcoin-cli listreceivedbyaccount 6 false
# Docker
docker-compose exec linkcoin linkcoind listreceivedbyaccount 6 false
```

---

### getaccount

Returns the account associated with an address.

**Syntax:**
```bash
getaccount <address>
```

**Parameters:**
- `address` (string, required) - LinkCoin address

**Returns:** `string` - Account name

**Example:**
```bash
./linkcoin-cli getaccount "LKCabcdef123..."
# Docker
docker-compose exec linkcoin linkcoind getaccount "LKCabcdef123..."
```

---

### setaccount

Sets the account associated with an address.

**Syntax:**
```bash
setaccount <address> <account>
```

**Parameters:**
- `address` (string, required) - LinkCoin address
- `account` (string, required) - Account name

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli setaccount "LKCabcdef123..." "mining"
# Docker
docker-compose exec linkcoin linkcoind setaccount "LKCabcdef123..." "mining"
```

---

### getaddressesbyaccount

Returns the list of addresses for an account.

**Syntax:**
```bash
getaddressesbyaccount <account>
```

**Parameters:**
- `account` (string, required) - Account name

**Returns:** `array` - Array of addresses

**Example:**
```bash
./linkcoin-cli getaddressesbyaccount "mining"
# Docker
docker-compose exec linkcoin linkcoind getaddressesbyaccount "mining"
```

---

### move

Moves amount from one account to another.

**Syntax:**
```bash
move <fromaccount> <toaccount> <amount> [minconf] [comment]
```

**Parameters:**
- `fromaccount` (string, required) - Source account
- `toaccount` (string, required) - Destination account
- `amount` (number, required) - Amount to move
- `minconf` (integer, optional, default=1) - Minimum confirmations
- `comment` (string, optional) - Comment

**Returns:** `boolean` - Success status

**Example:**
```bash
./linkcoin-cli move "mining" "savings" 50.0
# Docker
docker-compose exec linkcoin linkcoind move "mining" "savings" 50.0
```

---

### encryptwallet

Encrypts the wallet with a passphrase.

**Syntax:**
```bash
encryptwallet <passphrase>
```

**Parameters:**
- `passphrase` (string, required) - Encryption passphrase

**Returns:** `string` - Status message

**Example:**
```bash
./linkcoin-cli encryptwallet "my_secure_passphrase"
# Docker
docker-compose exec linkcoin linkcoind encryptwallet "my_secure_passphrase"
```

**Note:** This will shutdown the server. Backup your wallet first!

---

### walletpassphrase

Unlocks the wallet for a specified time.

**Syntax:**
```bash
walletpassphrase <passphrase> <timeout>
```

**Parameters:**
- `passphrase` (string, required) - Wallet passphrase
- `timeout` (integer, required) - Time in seconds to keep wallet unlocked

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli walletpassphrase "my_secure_passphrase" 60
# Docker
docker-compose exec linkcoin linkcoind walletpassphrase "my_secure_passphrase" 60
```

---

### walletpassphrasechange

Changes the wallet passphrase.

**Syntax:**
```bash
walletpassphrasechange <oldpassphrase> <newpassphrase>
```

**Parameters:**
- `oldpassphrase` (string, required) - Current passphrase
- `newpassphrase` (string, required) - New passphrase

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli walletpassphrasechange "old_pass" "new_pass"
# Docker
docker-compose exec linkcoin linkcoind walletpassphrasechange "old_pass" "new_pass"
```

---

### walletlock

Locks the wallet.

**Syntax:**
```bash
walletlock
```

**Parameters:** None

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli walletlock
# Docker
docker-compose exec linkcoin linkcoind walletlock
```

---

### backupwallet

Safely copies wallet.dat to a destination.

**Syntax:**
```bash
backupwallet <destination>
```

**Parameters:**
- `destination` (string, required) - Destination path/filename

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli backupwallet "/backup/wallet_backup.dat"
# Docker
docker-compose exec linkcoin linkcoind backupwallet "/data/wallet_backup.dat"
```

---

### dumpprivkey

Reveals the private key for an address.

**Syntax:**
```bash
dumpprivkey <address>
```

**Parameters:**
- `address` (string, required) - LinkCoin address

**Returns:** `string` - Private key

**Example:**
```bash
./linkcoin-cli dumpprivkey "LKCabcdef123..."
# Docker
docker-compose exec linkcoin linkcoind dumpprivkey "LKCabcdef123..."
```

**Note:** Requires wallet to be unlocked if encrypted.

---

### importprivkey

Imports a private key.

**Syntax:**
```bash
importprivkey <privkey> [label] [rescan]
```

**Parameters:**
- `privkey` (string, required) - Private key
- `label` (string, optional, default="") - Label for address
- `rescan` (boolean, optional, default=true) - Rescan blockchain

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli importprivkey "5J..." "imported" false
# Docker
docker-compose exec linkcoin linkcoind importprivkey "5J..." "imported" false
```

**Note:** Requires wallet to be unlocked if encrypted.

---

### keypoolrefill

Refills the keypool.

**Syntax:**
```bash
keypoolrefill [size]
```

**Parameters:**
- `size` (integer, optional, default=100) - New keypool size

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli keypoolrefill 200
# Docker
docker-compose exec linkcoin linkcoind keypoolrefill 200
```

---

## Mining Operations

### getgenerate

Returns if the server is set to generate coins.

**Syntax:**
```bash
getgenerate
```

**Parameters:** None

**Returns:** `boolean` - Mining status

**Example:**
```bash
./linkcoin-cli getgenerate
# Docker
docker-compose exec linkcoin linkcoind getgenerate
```

**Response:**
```json
true
```

---

### setgenerate

Turns generation (mining) on or off.

**Syntax:**
```bash
setgenerate <generate> [genproclimit]
```

**Parameters:**
- `generate` (boolean, required) - Turn mining on/off
- `genproclimit` (integer, optional, default=-1) - Processor limit (-1 = unlimited)

**Returns:** `null`

**Example:**
```bash
./linkcoin-cli setgenerate true 4
./linkcoin-cli setgenerate false
# Docker
docker-compose exec linkcoin linkcoind setgenerate true 4
```

---

### gethashespersec

Returns recent hashes per second performance.

**Syntax:**
```bash
gethashespersec
```

**Parameters:** None

**Returns:** `number` - Hashes per second

**Example:**
```bash
./linkcoin-cli gethashespersec
# Docker
docker-compose exec linkcoin linkcoind gethashespersec
```

**Response:**
```json
125000
```

---

### getmininginfo

Returns mining-related information.

**Syntax:**
```bash
getmininginfo
```

**Parameters:** None

**Returns:** `object` - Mining information

**Example:**
```bash
./linkcoin-cli getmininginfo
# Docker
docker-compose exec linkcoin linkcoind getmininginfo
```

**Response:**
```json
{
  "blocks": 245678,
  "currentblocksize": 1234,
  "currentblocktx": 5,
  "difficulty": 1.23456789,
  "errors": "",
  "generate": true,
  "genproclimit": 4,
  "hashespersec": 125000,
  "networkhashps": 5000000,
  "pooledtx": 10,
  "testnet": false
}
```

---

### getwork

Returns formatted hash data to work on.

**Syntax:**
```bash
getwork [data]
```

**Parameters:**
- `data` (string, optional) - If provided, tries to solve the block

**Returns:** `object` - Work data (if no data parameter) or `boolean` (if data provided)

**Example:**
```bash
./linkcoin-cli getwork
# Docker
docker-compose exec linkcoin linkcoind getwork
```

**Note:** Used by external miners. Consider using getblocktemplate instead.

---

### getworkex

Returns extended work data (includes coinbase).

**Syntax:**
```bash
getworkex [data] [coinbase]
```

**Parameters:**
- `data` (string, optional) - Block data
- `coinbase` (string, optional) - Coinbase transaction

**Returns:** `object` - Extended work data

**Example:**
```bash
./linkcoin-cli getworkex
# Docker
docker-compose exec linkcoin linkcoind getworkex
```

---

### getblocktemplate

Returns data needed to construct a block.

**Syntax:**
```bash
getblocktemplate [params]
```

**Parameters:**
- `params` (object, optional) - Request parameters

**Returns:** `object` - Block template

**Example:**
```bash
./linkcoin-cli getblocktemplate
# Docker
docker-compose exec linkcoin linkcoind getblocktemplate
```

**Note:** Used by mining pools and advanced miners.

---

### submitblock

Attempts to submit a new block to the network.

**Syntax:**
```bash
submitblock <hexdata> [params]
```

**Parameters:**
- `hexdata` (string, required) - Hex-encoded block data
- `params` (object, optional) - Additional parameters

**Returns:** `null` or `string` - Error message if rejected

**Example:**
```bash
./linkcoin-cli submitblock "hexdata..."
# Docker
docker-compose exec linkcoin linkcoind submitblock "hexdata..."
```

---

## Raw Transactions

### getrawtransaction

Returns raw transaction data.

**Syntax:**
```bash
getrawtransaction <txid> [verbose]
```

**Parameters:**
- `txid` (string, required) - Transaction ID
- `verbose` (integer, optional, default=0) - 0 for hex, 1 for JSON

**Returns:** `string` or `object` - Raw transaction (hex or JSON)

**Example:**
```bash
./linkcoin-cli getrawtransaction "abc123..." 1
# Docker
docker-compose exec linkcoin linkcoind getrawtransaction "abc123..." 1
```

---

### createrawtransaction

Creates a raw transaction.

**Syntax:**
```bash
createrawtransaction <inputs> <outputs>
```

**Parameters:**
- `inputs` (array, required) - Array of transaction inputs
- `outputs` (object, required) - Object with addresses and amounts

**Returns:** `string` - Hex-encoded raw transaction

**Example:**
```bash
./linkcoin-cli createrawtransaction '[{"txid":"abc123...","vout":0}]' '{"LKCaddr":10.5}'
# Docker
docker-compose exec linkcoin linkcoind createrawtransaction '[{"txid":"abc123...","vout":0}]' '{"LKCaddr":10.5}'
```

---

### decoderawtransaction

Returns JSON object representing a raw transaction.

**Syntax:**
```bash
decoderawtransaction <hex>
```

**Parameters:**
- `hex` (string, required) - Hex-encoded raw transaction

**Returns:** `object` - Decoded transaction

**Example:**
```bash
./linkcoin-cli decoderawtransaction "hexdata..."
# Docker
docker-compose exec linkcoin linkcoind decoderawtransaction "hexdata..."
```

---

### signrawtransaction

Signs a raw transaction.

**Syntax:**
```bash
signrawtransaction <hex> [prevtxs] [privkeys] [sighashtype]
```

**Parameters:**
- `hex` (string, required) - Hex-encoded raw transaction
- `prevtxs` (array, optional) - Previous dependent transaction outputs
- `privkeys` (array, optional) - Private keys for signing
- `sighashtype` (string, optional, default="ALL") - Signature hash type

**Returns:** `object` - Signed transaction and completion status

**Example:**
```bash
./linkcoin-cli signrawtransaction "hexdata..."
# Docker
docker-compose exec linkcoin linkcoind signrawtransaction "hexdata..."
```

**Note:** Requires wallet to be unlocked if encrypted.

---

### sendrawtransaction

Submits a raw transaction to the network.

**Syntax:**
```bash
sendrawtransaction <hex>
```

**Parameters:**
- `hex` (string, required) - Hex-encoded signed transaction

**Returns:** `string` - Transaction ID

**Example:**
```bash
./linkcoin-cli sendrawtransaction "hexdata..."
# Docker
docker-compose exec linkcoin linkcoind sendrawtransaction "hexdata..."
```

---

### getnormalizedtxid

Returns the normalized transaction ID (excluding witness data).

**Syntax:**
```bash
getnormalizedtxid <txid>
```

**Parameters:**
- `txid` (string, required) - Transaction ID

**Returns:** `string` - Normalized transaction ID

**Example:**
```bash
./linkcoin-cli getnormalizedtxid "abc123..."
# Docker
docker-compose exec linkcoin linkcoind getnormalizedtxid "abc123..."
```

---

### lockunspent

Locks or unlocks specified transaction outputs.

**Syntax:**
```bash
lockunspent <unlock> [outputs]
```

**Parameters:**
- `unlock` (boolean, required) - True to unlock, false to lock
- `outputs` (array, optional) - Array of outputs to lock/unlock

**Returns:** `boolean` - Success status

**Example:**
```bash
./linkcoin-cli lockunspent false '[{"txid":"abc123...","vout":0}]'
./linkcoin-cli lockunspent true
# Docker
docker-compose exec linkcoin linkcoind lockunspent false '[{"txid":"abc123...","vout":0}]'
```

---

### listlockunspent

Returns list of temporarily unspendable outputs.

**Syntax:**
```bash
listlockunspent
```

**Parameters:** None

**Returns:** `array` - Array of locked outputs

**Example:**
```bash
./linkcoin-cli listlockunspent
# Docker
docker-compose exec linkcoin linkcoind listlockunspent
```

---

### listsinceblock

Returns transactions since a specific block.

**Syntax:**
```bash
listsinceblock [blockhash] [minconf]
```

**Parameters:**
- `blockhash` (string, optional) - Block hash to list from
- `minconf` (integer, optional, default=1) - Minimum confirmations

**Returns:** `object` - Transactions and last block hash

**Example:**
```bash
./linkcoin-cli listsinceblock "00000000..." 6
# Docker
docker-compose exec linkcoin linkcoind listsinceblock "00000000..." 6
```

---

## Utility Commands

### help

Lists all commands or gets help for a specific command.

**Syntax:**
```bash
help [command]
```

**Parameters:**
- `command` (string, optional) - Command name for detailed help

**Returns:** `string` - Help text

**Example:**
```bash
./linkcoin-cli help
./linkcoin-cli help getinfo
# Docker
docker-compose exec linkcoin linkcoind help
docker-compose exec linkcoin linkcoind help getinfo
```

---

### stop

Stops the LinkCoin server.

**Syntax:**
```bash
stop
```

**Parameters:** None

**Returns:** `string` - Shutdown message

**Example:**
```bash
./linkcoin-cli stop
# Docker
docker-compose exec linkcoin linkcoind stop
```

---

### validateaddress

Validates a LinkCoin address.

**Syntax:**
```bash
validateaddress <address>
```

**Parameters:**
- `address` (string, required) - LinkCoin address

**Returns:** `object` - Validation information

**Example:**
```bash
./linkcoin-cli validateaddress "LKCabcdef123..."
# Docker
docker-compose exec linkcoin linkcoind validateaddress "LKCabcdef123..."
```

**Response:**
```json
{
  "isvalid": true,
  "address": "LKCabcdef123...",
  "ismine": true,
  "isscript": false,
  "pubkey": "02abc123...",
  "iscompressed": true,
  "account": "mining"
}
```

---

### verifymessage

Verifies a signed message.

**Syntax:**
```bash
verifymessage <address> <signature> <message>
```

**Parameters:**
- `address` (string, required) - LinkCoin address
- `signature` (string, required) - Base64 signature
- `message` (string, required) - Message that was signed

**Returns:** `boolean` - Verification result

**Example:**
```bash
./linkcoin-cli verifymessage "LKCaddr" "signature..." "message"
# Docker
docker-compose exec linkcoin linkcoind verifymessage "LKCaddr" "signature..." "message"
```

---

### signmessage

Signs a message with the private key of an address.

**Syntax:**
```bash
signmessage <address> <message>
```

**Parameters:**
- `address` (string, required) - LinkCoin address
- `message` (string, required) - Message to sign

**Returns:** `string` - Base64 signature

**Example:**
```bash
./linkcoin-cli signmessage "LKCabcdef123..." "Hello World"
# Docker
docker-compose exec linkcoin linkcoind signmessage "LKCabcdef123..." "Hello World"
```

**Note:** Requires wallet to be unlocked if encrypted.

---

### createmultisig

Creates a multi-signature address.

**Syntax:**
```bash
createmultisig <nrequired> <keys>
```

**Parameters:**
- `nrequired` (integer, required) - Number of required signatures
- `keys` (array, required) - Array of public keys or addresses

**Returns:** `object` - Multisig address and redeem script

**Example:**
```bash
./linkcoin-cli createmultisig 2 '["key1","key2","key3"]'
# Docker
docker-compose exec linkcoin linkcoind createmultisig 2 '["key1","key2","key3"]'
```

**Response:**
```json
{
  "address": "3MultiSigAddress...",
  "redeemScript": "52210abc123..."
}
```

---

### addmultisigaddress

Adds a multi-signature address to the wallet.

**Syntax:**
```bash
addmultisigaddress <nrequired> <keys> [account]
```

**Parameters:**
- `nrequired` (integer, required) - Number of required signatures
- `keys` (array, required) - Array of public keys or addresses
- `account` (string, optional) - Account to assign address to

**Returns:** `string` - Multisig address

**Example:**
```bash
./linkcoin-cli addmultisigaddress 2 '["key1","key2","key3"]' "multisig"
# Docker
docker-compose exec linkcoin linkcoind addmultisigaddress 2 '["key1","key2","key3"]' "multisig"
```

---

### listaddressgroupings

Returns groups of addresses with common ownership.

**Syntax:**
```bash
listaddressgroupings
```

**Parameters:** None

**Returns:** `array` - Array of address groupings

**Example:**
```bash
./linkcoin-cli listaddressgroupings
# Docker
docker-compose exec linkcoin linkcoind listaddressgroupings
```

---

### settxfee

Sets the transaction fee per KB.

**Syntax:**
```bash
settxfee <amount>
```

**Parameters:**
- `amount` (number, required) - Fee amount in LKC per KB

**Returns:** `boolean` - Success status

**Example:**
```bash
./linkcoin-cli settxfee 0.0001
# Docker
docker-compose exec linkcoin linkcoind settxfee 0.0001
```

---

### setmininput

Sets the minimum transaction output value.

**Syntax:**
```bash
setmininput <amount>
```

**Parameters:**
- `amount` (number, required) - Minimum input value in LKC

**Returns:** `boolean` - Success status

**Example:**
```bash
./linkcoin-cli setmininput 0.00001
# Docker
docker-compose exec linkcoin linkcoind setmininput 0.00001
```

---

## Docker Usage

### Running Commands in Docker

All RPC commands can be executed within the Docker container using `docker-compose exec`:

```bash
# General syntax
docker-compose exec linkcoin linkcoind <command> [params]

# Examples
docker-compose exec linkcoin linkcoind getinfo
docker-compose exec linkcoin linkcoind getblockcount
docker-compose exec linkcoin linkcoind getnewaddress "mining"
docker-compose exec linkcoin linkcoind sendtoaddress "LKCaddr..." 10.5
```

### Using linkcoin-cli-rpc Script

The `linkcoin-cli-rpc.sh` script provides network-based RPC access:

```bash
# Configure environment variables
export LINKCOIN_RPC_HOST=localhost
export LINKCOIN_RPC_PORT=9600
export LINKCOIN_RPC_USER=linkcoinrpc
export LINKCOIN_RPC_PASSWORD=your_password

# Execute commands
./linkcoin-cli-rpc.sh getinfo
./linkcoin-cli-rpc.sh getblockcount
./linkcoin-cli-rpc.sh getnewaddress "mining"
```

### Remote Access

Access a remote LinkCoin node:

```bash
# Using environment variables
export LINKCOIN_RPC_HOST=192.168.1.100
export LINKCOIN_RPC_PASSWORD=remote_password
./linkcoin-cli-rpc.sh getinfo

# Using command-line options
./linkcoin-cli-rpc.sh --host 192.168.1.100 --password remote_password getinfo
```

### Docker Compose Examples

```bash
# Start node
docker-compose up -d

# View logs
docker-compose logs -f linkcoin

# Execute command
docker-compose exec linkcoin linkcoind getinfo

# Stop node
docker-compose down

# Restart node
docker-compose restart linkcoin
```

---

## Error Codes

LinkCoin RPC uses standard JSON-RPC error codes plus custom codes:

### Standard JSON-RPC Errors

| Code | Message | Description |
|------|---------|-------------|
| -32700 | Parse error | Invalid JSON |
| -32600 | Invalid request | Invalid request object |
| -32601 | Method not found | Method does not exist |
| -32602 | Invalid params | Invalid method parameters |
| -32603 | Internal error | Internal JSON-RPC error |

### LinkCoin-Specific Errors

| Code | Constant | Description |
|------|----------|-------------|
| -1 | RPC_MISC_ERROR | General application error |
| -2 | RPC_FORBIDDEN_BY_SAFE_MODE | Server in safe mode |
| -3 | RPC_TYPE_ERROR | Unexpected type |
| -4 | RPC_INVALID_ADDRESS_OR_KEY | Invalid address or key |
| -5 | RPC_OUT_OF_MEMORY | Out of memory |
| -6 | RPC_INVALID_PARAMETER | Invalid parameter |
| -7 | RPC_DATABASE_ERROR | Database error |
| -8 | RPC_DESERIALIZATION_ERROR | Error parsing/validating structure |
| -10 | RPC_VERIFY_ERROR | General verification error |
| -11 | RPC_VERIFY_REJECTED | Transaction/block rejected |
| -12 | RPC_VERIFY_ALREADY_IN_CHAIN | Already in chain |
| -13 | RPC_IN_WARMUP | Client in initial download |
| -14 | RPC_WALLET_ERROR | Wallet error |
| -15 | RPC_WALLET_INSUFFICIENT_FUNDS | Insufficient funds |
| -16 | RPC_WALLET_INVALID_ACCOUNT_NAME | Invalid account name |
| -17 | RPC_WALLET_KEYPOOL_RAN_OUT | Keypool ran out |
| -18 | RPC_WALLET_UNLOCK_NEEDED | Wallet unlock needed |
| -19 | RPC_WALLET_PASSPHRASE_INCORRECT | Passphrase incorrect |
| -20 | RPC_WALLET_WRONG_ENC_STATE | Wrong encryption state |
| -21 | RPC_WALLET_ENCRYPTION_FAILED | Encryption failed |
| -22 | RPC_WALLET_ALREADY_UNLOCKED | Wallet already unlocked |
| -23 | RPC_CLIENT_NOT_CONNECTED | Not connected to network |
| -24 | RPC_CLIENT_IN_INITIAL_DOWNLOAD | Still downloading blocks |

### Error Response Example

```json
{
  "result": null,
  "error": {
    "code": -5,
    "message": "Invalid LinkCoin address"
  },
  "id": "1"
}
```

---

## Common Use Cases

### Setting Up a New Wallet

```bash
# 1. Generate a new address
./linkcoin-cli getnewaddress "main"

# 2. Encrypt wallet (optional but recommended)
./linkcoin-cli encryptwallet "secure_passphrase"

# 3. Backup wallet
./linkcoin-cli backupwallet "/backup/wallet.dat"

# 4. Check balance
./linkcoin-cli getbalance
```

### Sending Coins

```bash
# 1. Unlock wallet (if encrypted)
./linkcoin-cli walletpassphrase "passphrase" 60

# 2. Send coins
./linkcoin-cli sendtoaddress "LKCrecipient..." 10.5 "payment" "John"

# 3. Verify transaction
./linkcoin-cli gettransaction "txid..."

# 4. Lock wallet
./linkcoin-cli walletlock
```

### Mining Setup

```bash
# 1. Generate mining address
./linkcoin-cli getnewaddress "mining"

# 2. Start mining with 4 threads
./linkcoin-cli setgenerate true 4

# 3. Check mining status
./linkcoin-cli getmininginfo

# 4. Monitor hash rate
./linkcoin-cli gethashespersec

# 5. Stop mining
./linkcoin-cli setgenerate false
```

### Monitoring Node

```bash
# General information
./linkcoin-cli getinfo

# Blockchain status
./linkcoin-cli getblockcount
./linkcoin-cli getbestblockhash
./linkcoin-cli getdifficulty

# Network status
./linkcoin-cli getconnectioncount
./linkcoin-cli getpeerinfo
./linkcoin-cli getnetworkhashps

# Memory pool
./linkcoin-cli getrawmempool
```

### Creating Multi-Signature Wallet

```bash
# 1. Create multisig address (2-of-3)
./linkcoin-cli createmultisig 2 '["pubkey1","pubkey2","pubkey3"]'

# 2. Add to wallet
./linkcoin-cli addmultisigaddress 2 '["pubkey1","pubkey2","pubkey3"]' "multisig"

# 3. Send to multisig address
./linkcoin-cli sendtoaddress "3MultisigAddr..." 100.0

# 4. Create raw transaction from multisig
./linkcoin-cli createrawtransaction '[{"txid":"...","vout":0}]' '{"LKCdest...":99.9}'

# 5. Sign with first key
./linkcoin-cli signrawtransaction "rawtx..."

# 6. Sign with second key (on another wallet)
./linkcoin-cli signrawtransaction "partiallysignedtx..."

# 7. Broadcast fully signed transaction
./linkcoin-cli sendrawtransaction "fullysignedtx..."
```

---

## Best Practices

### Security

1. **Always encrypt your wallet** with a strong passphrase
2. **Backup regularly** using `backupwallet` command
3. **Use strong RPC credentials** in linkcoin.conf
4. **Limit RPC access** with `rpcallowip` settings
5. **Lock wallet** after sensitive operations
6. **Never share private keys** or wallet.dat file

### Performance

1. **Use appropriate confirmations** (6+ for large amounts)
2. **Set reasonable transaction fees** with `settxfee`
3. **Monitor memory pool** to avoid congestion
4. **Keep blockchain synced** for accurate information
5. **Use batch operations** when possible

### Development

1. **Test on testnet first** before mainnet
2. **Handle errors properly** using error codes
3. **Validate addresses** before sending
4. **Use normalized txids** for transaction tracking
5. **Implement proper timeout handling** for RPC calls

---

## Additional Resources

### Configuration Files

- **linkcoin.conf**: Main configuration file
- **wallet.dat**: Wallet data (keep secure!)
- **debug.log**: Debug and error logs

### Related Documentation

- [DOCKER_GUIDE.md](DOCKER_GUIDE.md) - Docker deployment guide
- [MINING_GUIDE.md](MINING_GUIDE.md) - Mining setup and optimization
- [RPC_CLIENT_GUIDE.md](RPC_CLIENT_GUIDE.md) - RPC client usage
- [README.md](README.md) - General project information

### Support

- **Website**: http://www.linkcoin.org
- **GitHub**: https://github.com/senasgr-eth/LinkCoin

---

## Appendix: Complete Command List

### Blockchain Commands
- `getbestblockhash` - Get best block hash
- `getblock` - Get block information
- `getblockcount` - Get block count
- `getblockhash` - Get block hash by height
- `getdifficulty` - Get mining difficulty
- `getrawmempool` - Get memory pool transactions
- `gettxout` - Get transaction output
- `gettxoutsetinfo` - Get UTXO set info
- `verifychain` - Verify blockchain

### Network Commands
- `addnode` - Add/remove node
- `getaddednodeinfo` - Get added node info
- `getconnectioncount` - Get connection count
- `getnetworkhashps` - Get network hash rate
- `getpeerinfo` - Get peer information

### Wallet Commands
- `addmultisigaddress` - Add multisig address
- `backupwallet` - Backup wallet
- `dumpprivkey` - Export private key
- `encryptwallet` - Encrypt wallet
- `getaccount` - Get account for address
- `getaccountaddress` - Get address for account
- `getaddressesbyaccount` - Get addresses by account
- `getbalance` - Get balance
- `getnewaddress` - Generate new address
- `getreceivedbyaccount` - Get received by account
- `getreceivedbyaddress` - Get received by address
- `gettransaction` - Get transaction details
- `importprivkey` - Import private key
- `keypoolrefill` - Refill key pool
- `listaccounts` - List accounts
- `listaddressgroupings` - List address groupings
- `listlockunspent` - List locked outputs
- `listreceivedbyaccount` - List received by account
- `listreceivedbyaddress` - List received by address
- `listsinceblock` - List since block
- `listtransactions` - List transactions
- `listunspent` - List unspent outputs
- `lockunspent` - Lock/unlock outputs
- `move` - Move between accounts
- `sendfrom` - Send from account
- `sendmany` - Send to multiple addresses
- `sendtoaddress` - Send to address
- `setaccount` - Set account for address
- `settxfee` - Set transaction fee
- `signmessage` - Sign message
- `walletlock` - Lock wallet
- `walletpassphrase` - Unlock wallet
- `walletpassphrasechange` - Change passphrase

### Mining Commands
- `getgenerate` - Get mining status
- `gethashespersec` - Get hash rate
- `getmininginfo` - Get mining info
- `getwork` - Get work data
- `getworkex` - Get extended work data
- `getblocktemplate` - Get block template
- `setgenerate` - Start/stop mining
- `submitblock` - Submit block

### Raw Transaction Commands
- `createrawtransaction` - Create raw transaction
- `decoderawtransaction` - Decode raw transaction
- `getrawtransaction` - Get raw transaction
- `getnormalizedtxid` - Get normalized txid
- `sendrawtransaction` - Send raw transaction
- `signrawtransaction` - Sign raw transaction

### Utility Commands
- `createmultisig` - Create multisig address
- `getinfo` - Get general info
- `help` - Get help
- `setmininput` - Set minimum input
- `stop` - Stop server
- `validateaddress` - Validate address
- `verifymessage` - Verify message

---

**Last Updated**: 2025-10-30
**LinkCoin Version**: 0.8.7.2
**API Version**: JSON-RPC 1.0

