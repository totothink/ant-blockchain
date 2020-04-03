# AntBlockchain

蚂蚁开放联盟链SDK(Ruby版)，API接口文档请参考https://tech.antfin.com/docs/2/146925

## Installation

在你项目的Gemfile文件里加下面一行:

```ruby
gem 'ant_blockchain'
```

并且执行:

    $ bundle install

或者可以自行安装:

    $ gem install ant_blockchain

## 使用

### 实例化客户端

```ruby
    client = AntBlockChain::Client.new()
    client.tenant_id = "你的tenant_id"
    client.access_id = "你的access_id"
    client.access_key = "你的access_key"
    client.bizid = "链标识" # 蚂蚁开放联盟链默认值a00e36c5
    client.account = "默认使用的链上账号" # 如果配置了默认账号，则默认使用该账号进行交易，如果在后续的使用中指明了具体的账号，则使用指明的账号
    client.mykms_key_id = "你的密钥托管id" # 如果配置了默认密钥托管ID，则默认使用该ID进行交易，如果在后续的使用中指明了具体的ID，则使用指明的ID
```

或者


```ruby
    client = AntBlockChain::Client.new(
        tenant_id: "你的tenant_id",
        access_id: "你的access_id",
        access_key: "你的access_key",
        bizid: "你的bizid",
        account: "默认使用的链上账号",
        mykms_key_id: "你的密钥托管id"
    )
```

### 存证

用默认账户进行操作:
```ruby
    client.deposit(content: 'hi, ruby sdk')
```

如果用指定账户进行操作:
```ruby
    client.deposit(content: 'hi, ruby sdk', account: 'other account', mykms_key_id: 'other kms key id')
```

### 部署Solidity合约

```ruby
    client.deploy_sol(contract_name: '合约名称', contract_code: '编译后的合约代码')
```

### 调用Solidity合约方法

```ruby
    client.call_sol(contract_name: '调用的合约名称', method_signature: '方法签名', input_params: '实参列表', out_types: '返回参数列表')
```

### 查询交易

```ruby
    client.query_transaction("52b35a5e325aa7de4ac5a4c0f3cdefb56e2601279f2a7dd8afe305d643f2714b")
```

### 查询交易回执

```ruby
    client.query_receipt("52b35a5e325aa7de4ac5a4c0f3cdefb56e2601279f2a7dd8afe305d643f2714b")
```

### 查询区块头

```ruby
    block_number = 1
    client.query_blockheader(block_number)
```

### 查询区块链体

```ruby
    block_number = 1
    client.query_blockbody(block_number)
```

### 查询最新区块高度

```ruby
    client.query_last_block()
```

### 查询账号

```ruby
    client.query_account("需要查询的账号名")
```