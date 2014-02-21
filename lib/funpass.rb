require_relative 'store'
require_relative 'key_maker'
require_relative 'password_generator'
require_relative '../conf'

class FunPass
  def self.init(key = nil)
    key = KeyMaker.ensure_key key
    Store.create_folder_with_secret_file key
  end

  def self.scrunch
    Store.scrunch
  end

  def self.gen(token)
    PasswordGenerator.gen token
  end

  def self.scrub
    Store.scrub
  end
end
