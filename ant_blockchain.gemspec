require_relative 'lib/ant_blockchain/version'

Gem::Specification.new do |spec|
  spec.name          = "ant_blockchain"
  spec.version       = AntBlockchain::VERSION
  spec.authors       = ["aaron"]
  spec.email         = ["yalong1976@gmail.com"]

  spec.summary       = %q{ant_blockchain是蚂蚁联盟链ruby版本的SDK}
  spec.description   = %q{ant_blockchain是蚂蚁联盟链ruby版本的SDK，基于蚂蚁区块链的HTTP接入方式封装而成}
  spec.homepage      = "http://github.com/totothink/ant-blockchain"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "http://github.com/totothink/ant-blockchain"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
