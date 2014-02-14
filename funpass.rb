#/usr/bin/env ruby

require 'thor'
require 'fileutils'
require 'digest'

# defaults
SECRET_BASE = 2
SECRET_EXPT = 4096
ALPHANUMERIC = true
LENGTH = 31
LOCATION = File.join(Dir.home, '.funpass')
SECRET_LOCATION = File.join(LOCATION, 'secret')

class PassGen
  # Generate a password as a function of the secret key
  # and the token for which the password is generated
  def self.funcy_passwd opts
    secret = secret_data
    digest = (Digest::SHA256.new << opts[:token]).hexdigest
    seed = (Digest::SHA256.new << (digest.to_i(16) + secret).to_s(36)).hexdigest.to_i 16
    srand seed
    randy_passwd opts
  end

  # Generate a password using Ruby's PRNG
  # Calling anything here should be ok, as long as
  # no call to srand (or anything aliased for/by it)
  # occurs.
  # This should allow us to use other gems to generate
  # nice passwords in various styles (memorable words,
  # etc.) as long as the seed functions are monkeypatched.
  def self.randy_passwd opts
    if opts[:alnum]
      base = 36
    else
      base = 26
    end
    max = base ** opts[:len].to_i
    pass = rand(max)
    pass.to_s(base)
  end

  def self.secret_data
    File.open(SECRET_LOCATION, 'r') do |file|
      file.readlines.join('').to_i
    end
  end
end

class SecretFile
  def self.create contents
    begin
      if File.file? SECRET_LOCATION
        raise "File #{loc} exists. Run '#{ARGV[0]} scrunch' first."
      end

      dirname = File.dirname SECRET_LOCATION
      unless File.directory? dirname
        FileUtils.mkdir_p dirname
      end

      File.open(SECRET_LOCATION, 'w') do |file|
        file.write contents
      end
    rescue
      raise "Unable to create file at location #{SECRET_LOCATION}."
    end
  end
end


class FunPass < Thor
  desc 'init', 'initialize funpass folder'
  option :secret
  def init
    if not File.file? SECRET_LOCATION
      secret = options[:secret] || rand(SECRET_BASE ** SECRET_EXPT)
    end
    SecretFile.create secret
  end

  desc 'scrunch', 'destroy funpass folder'
  def scrunch
    puts "Put on your radiation-proof bikini. Your funpass is about to be scrunched!"
    print "Continue? (yes|no = anything else) >"
    resp = STDIN.gets.chomp
    unless resp == 'yes'
      puts "Ok, nevermind."
    else
      puts "Scrunching up your funpass..."
      FileUtils.remove_entry_secure(LOCATION, true)
    end
  end

  desc 'gen TOKEN', 'generate password as a function of the given TOKEN.'
  option :length
  option :alphanumeric, type: :boolean
  def gen token
    len = options[:length] || LENGTH
    alnum = options[:alphanumeric] || ALPHANUMERIC
    passwd = PassGen.funcy_passwd ({ token: token,
      len: len,
      alnum: alnum
    })

    puts "#{token} => #{passwd}"
  end
  
end

FunPass.start(ARGV)
