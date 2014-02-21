require 'fileutils'
require_relative '../conf'

class Store
  def self.create_folder_with_secret_file(key)
    Dir.mkdir FUNPASS_PATH
    File.open(SECRET_PATH, 'w') { |secret_file| secret_file.write(key) }
  end

  def self.scrunch
    File.unlink SECRET_PATH
    Dir.rmdir FUNPASS_PATH
  end

  def self.secret
    secret = File.open SECRET_PATH do |secret_file|
      secret_file.readlines.join('')
    end
  end

  def self.scrub
    begin
      FileUtils.rm_rf FUNPASS_PATH
    rescue
    end
  end
end
