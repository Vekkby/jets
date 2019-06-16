require 'dotenv'

class Jets::Dotenv
  def self.load!(remote=false)
    new(remote).load!
  end

  def initialize(remote=false)
    @remote = ENV['JETS_ENV_REMOTE'] || remote
  end

  def load!
    vars = ::Dotenv.load(*dotenv_files)
    Ssm.new(vars).interpolate!
  end

  # dotenv files with the following precedence:
  #
  # - .env.development.jets_env_extra (highest)
  # - .env.development.remote (2nd highest)
  # - .env.development.local
  # - .env.development
  # - .env.local - This file is loaded for all environments _except_ `test`.
  # - .env - The original (lowest)
  #
  def dotenv_files
    files = [
      root.join(".env"),
      (root.join(".env.local") unless Jets.env.test?),
      root.join(".env.#{Jets.env}"),
      root.join(".env.#{Jets.env}.local"),
    ]
    files << root.join(".env.#{Jets.env}.remote") if @remote
    if ENV["JETS_ENV_EXTRA"]
      files << root.join(".env.#{Jets.env}.#{ENV["JETS_ENV_EXTRA"]}")
    end
    files.compact
  end

  def root
    Jets.root || Pathname.new(ENV["JETS_ROOT"] || Dir.pwd)
  end
end
