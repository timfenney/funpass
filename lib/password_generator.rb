require 'digest'
require 'base62'
require_relative '../conf'

class PasswordGenerator
  # This class implementation may need improvement from a security standpoint.
  def self.gen(token)
    srand(seed(token))
    gen_randy_password
  end

  private

  def self.seed(token)
    hashed = hash_secret_with token
    hashed.to_i
  end

  def self.hash(token)
    (Digest::SHA256.new << token).hexdigest
  end

  def self.hash_secret_with token
    hash(hash(token) + Store.secret)
  end

  def self.gen_randy_password
    rand(PASSWORD_BASE ** (PASSWORD_LENGTH + 1)).base62_encode[0...30]
  end
end
