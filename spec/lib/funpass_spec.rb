require_relative '../spec_helper.rb'
require_relative '../../lib/funpass'

module MakeSure
  def self.the_funpass_folder_does_not_exist
    begin
      FileUtils.rm_r FUNPASS_DIR
    rescue
    end
  end

  def self.the_funpass_folder_is_empty
    the_funpass_folder_does_not_exist
    Dir.mkdir FUNPASS_DIR
  end

  def self.the_funpass_folder_contains_secret
    the_funpass_folder_is_empty
    FileUtils.touch SECRET_FILE
  end

  def self.the_secret_file_correctly_exists
    the_funpass_folder_is_empty
    File.open(SECRET_FILE, 'w') do |secret_file|
      secret_file.write '1234'
    end
  end
end

describe FunPass do
  include MakeSure

  describe '.init' do
    include_context 'fake fs'

    def read_secret_file
      File.open(SECRET_FILE, 'r') do |file|
        file.readlines.join('').to_i
      end
    end

    context 'when funpass folder does not exist' do
      it 'creates the funpass folder' do
        FunPass.init
        expect(File.directory?(FUNPASS_DIR)).to be_true
      end

      it 'creates the secret file in the funpass folder' do
        FunPass.init
        expect(File.file?(SECRET_FILE)).to be_true
      end

      it 'creates the secret file with the argument as its secret key' do
        key = 1234
        FunPass.init(key)
        retrieved_key = read_secret_file
        expect(retrieved_key).to equal(key)
      end

      it 'raises an ArgumentError when the key argument is not positive or not integral' do
        keys = [0, -1, -1020389, 3.14]
        keys.each do |key|
          expect { FunPass.init key }.to raise_error(ArgumentError)
        end
      end

      it 'sets the contents of the secret file such that it may be read as a positive integer' do
        FunPass.init
        secret = read_secret_file
        expect(secret).to be > 0
      end

      it 'generates a different secret file two times in a row' do
        FunPass.init
        first_secret = read_secret_file
        funpass_setup
        FunPass.init
        second_secret = read_secret_file
        expect(second_secret).not_to equal(first_secret)
      end

      it 'generates a significantly large secret number' do
        threshold = 2 ** (4096 - 1)
        tries = 32
        max = 0
        tries.times do
          funpass_setup
          FunPass.init
          secret = read_secret_file
          max = secret unless secret < max
        end
        expect(max).to be > threshold
      end
    end

    context 'when funpass folder already exists' do
      before { MakeSure.the_funpass_folder_is_empty }
      it 'raises an error' do
        message = 'The funpass folder already exists.'
        expect { FunPass.init }.to raise_error(Errno::EEXIST)
      end
    end
  end


  describe '.scrunch' do
    include_context 'fake fs'

    context 'when the funpass folder exists and contains secret' do
      before { MakeSure.the_funpass_folder_contains_secret }
      it 'removes the funpass folder' do
        FunPass.scrunch
        expect(File.directory?(FUNPASS_DIR)).to be_false
      end
    end

    context 'when funpass folder does not exist' do
      it 'raises an error' do
        expect { FunPass.scrunch }.to raise_error
      end
    end

    context 'when funpass folder exists, but secret does not' do
      before { MakeSure.the_funpass_folder_is_empty }
      it 'raises an error' do
        expect { FunPass.scrunch }.to raise_error
      end
    end
  end

  describe '.scrub' do
    include_context 'fake fs'

    context 'when funpass folder contains secret' do
      before { MakeSure.the_funpass_folder_contains_secret }
      it 'removes the funpass folder' do
        FunPass.scrub
        expect(File.directory?(FUNPASS_DIR)).to be_false
      end
    end

    context 'when funpass folder does not exist' do
      it 'moves on without complaining' do
        FunPass.scrub
        expect(File.directory?(FUNPASS_DIR)).to be_false
      end
    end

    context 'when funpass folder exists, but secret does not' do
      before { MakeSure.the_funpass_folder_is_empty }
      it 'removes the funpass folder' do
        FunPass.scrub
        expect(File.directory?(FUNPASS_DIR)).to be_false
      end
    end
  end

  describe '.gen' do
    include_context 'fake fs'
    context 'when the funpass folder does not exist' do
      before { MakeSure.the_funpass_folder_does_not_exist }
      it 'generates the same password when initialized with the same key' do
        key = '1234'.freeze
        token = 'bob@4appl.es'.freeze
        FunPass.init key
        first_password = FunPass.gen token
        MakeSure.the_funpass_folder_does_not_exist
        FunPass.init key
        second_password = FunPass.gen token
        expect(second_password).to eq(first_password)
      end

      it 'generates a different password for a different secret key' do
        token = 'bob@4appl.es'.freeze
        FunPass.init '1234'
        first_password = FunPass.gen token
        MakeSure.the_funpass_folder_does_not_exist
        FunPass.init '2345'
        second_password = FunPass.gen token
        expect(second_password).not_to eq(first_password)
      end
    end

    context 'when secret file correctly exists' do
      before(:each) { MakeSure.the_secret_file_correctly_exists }
      it 'generates a password for a given string' do
        password = FunPass.gen 'bob@4appl.es'
        expect(password.length).to equal(30)
      end

      it 'generates the same password two times in a row' do
        token = 'bob@4appl.es'.freeze
        first_password = FunPass.gen token
        second_password = FunPass.gen token
        expect(second_password).to eq(first_password)
      end

      it 'generates a different password for a different token' do
        first_password = FunPass.gen 'bob@4appl.es'
        second_password = FunPass.gen 'bob@4pea.rs'
        expect(second_password).not_to eq(first_password)
      end
    end

    context 'when secret file does not exist' do
      it 'raises a RuntimeError' do
        FunPass.init
        FileUtils.rm(SECRET_FILE)
        expect { FunPass.gen 'frugle_mom@google.com' }.to raise_error
      end
    end
  end
end
