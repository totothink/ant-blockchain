require "ant_blockchain/version"
require "openssl"
require "json"

module AntBlockchain
  class Error < StandardError; end
  class AccessError < Error; end
  class ShakeHandError < Error; end
  
  class Client
    attr_accessor :tenant_id, :bizid, :access_id, :access_key, :account, :mykms_key_id
    attr_reader :token, :root_url, :token_expires_at

    BIZID = 'a00e36c5'
    ROOT_URL = 'https://rest.baas.alipay.com'
    TRANSACTION_PATH = '/api/contract/chainCallForBiz'
    QUERY_PATH = '/api/contract/chainCall'

    def initialize(tenant_id: nil, bizid: nil, access_id: nil, access_key: nil, account: nil, root_url: nil, mykms_key_id: nil)
      @tenant_id = tenant_id
      @bizid = bizid || BIZID
      @access_id = access_id
      @access_key = access_key
      @account = account
      @root_url = root_url || ROOT_URL
      @mykms_key_id = mykms_key_id
    end

    def shakehand(force = false)
      if token_expired? || force 
        @token = _get_token()
      end
    rescue => e
      raise ShakeHandError, JSON.dump(e.message)
    end

    def deposit(order_id: gen_order_id, content:, mykms_key_id: nil, account: nil, gas: 100000)
      shakehand()
      body = { 
        orderId: order_id, 
        bizid: bizid,
        account: account || self.account,
        content: content,
        mykmsKeyId: mykms_key_id || self.mykms_key_id,
        method: 'DEPOSIT',
        accessId: access_id,
        token: token,
        gas: gas,
        tenantid: tenant_id
      }
      _request(TRANSACTION_PATH, body)
    end

    def deploy_sol(order_id: gen_order_id, account: nil, contract_name:, contract_code:, mykms_key_id: nil, gas: 100000)
      shakehand()
      body = { 
        orderId: order_id,
        bizid: bizid,
        account: account || self.account,
        contractName: contract_name,
        contractCode: contract_code,
        mykmsKeyId: mykms_key_id || self.mykms_key_id,
        method: 'DEPLOYCONTRACTFORBIZ',
        accessId: access_id,
        token: token,
        gas: gas,
        tenantid: tenant_id
      }
      _request(TRANSACTION_PATH, body)
    end

    def call_sol(order_id: gen_order_id, account: nil, contract_name:, method_signature:, input_params:, out_types:, mykms_key_id: nil, gas: 100000)
      shakehand()
      body = { 
        orderId: order_id,
        bizid: bizid,
        account: account || self.account,
        contractName: contract_name,
        methodSignature: method_signature,
        mykmsKeyId: mykms_key_id || self.mykms_key_id,
        method: 'CALLCONTRACTBIZASYNC',
        inputParamListStr: input_params,
        outTypes: out_types,
        accessId: access_id,
        token: token,
        gas: gas,
        tenantId: tenant_id
      }
      _request(TRANSACTION_PATH, body)
    end

    def query_transaction(hash)
      shakehand()
      body = { 
        bizid: bizid,
        method: 'QUERYTRANSACTION',
        accessId: access_id,
        hash: hash,
        token: self.token
       }
       _request(QUERY_PATH, body)
    end

    def query_receipt(hash)
      shakehand()
      body = { 
        bizid: bizid,
        method: 'QUERYRECEIPT',
        accessId: access_id,
        hash: hash,
        token: self.token
       }
       _request(QUERY_PATH, body)
    end

    def query_blockheader(block_number)
      shakehand()
      body = { 
        bizid: bizid,
        method: 'QUERYBLOCK',
        accessId: access_id,
        requestStr: block_number,
        token: self.token
       }
       _request(QUERY_PATH, body)      
    end

    def query_blockbody(block_number)
      shakehand()
      body = { 
        bizid: bizid,
        method: 'QUERYBLOCKBODY',
        accessId: access_id,
        requestStr: block_number,
        token: self.token
       }
       _request(QUERY_PATH, body)         
    end

    def query_last_block()
      shakehand()
      body = { 
        bizid: bizid,
        method: 'QUERYLASTBLOCK',
        accessId: access_id,
        token: self.token
       }
       _request(QUERY_PATH, body)           
    end

    def query_account(account)
      shakehand()
      body = { 
        bizid: bizid,
        method: 'QUERYACCOUNT',
        requestStr: "{\"queryAccount\":\"#{account}\"}",
        accessId: access_id,
        token: self.token
       }
       _request(QUERY_PATH, body)           
    end

    def token_expired?
      token_expires_at.nil? || Time.now > token_expires_at
    end

    def gen_order_id(prefix: 'order_')
      time = Time.now.to_i.to_s + '000'
      order_id = prefix + time
    end

    private
    def _request(path, body)
      response = RestClient.post(root_url + path, body.to_json, { content_type: :json})
      result = JSON.parse(response.body)
      raise(AccessError, result) unless result['success']
      result
    end
    
    def _get_token()
      time = Time.now.to_i.to_s + '000'
      tnonce = access_id + time
      k = OpenSSL::PKey::RSA.new(access_key)
      digest = OpenSSL::Digest::SHA256.new
      signature = k.sign(digest,tnonce)
      hex_signature = signature.unpack('H*').first
      response = RestClient.post(root_url + '/api/contract/shakeHand', {accessId: access_id, time: time, secret: hex_signature}.to_json, { content_type: :json })
      result = JSON.parse(response.body)
      raise(AccessError, result) unless result['success']
      @token_expires_at = Time.now + 2 * 60 * 60
      result['data']
    end
  end
end
