require 'fakefs/safe'

FUNPASS_DIR = File.join(Dir.home, '.funpass')
SECRET_FILE = File.join(FUNPASS_DIR, 'secret')

include FakeFS

shared_context 'fake fs' do
  before :each do
    FakeFS.activate!
    funpass_setup
  end

  after :each do
    FakeFS.deactivate!
  end
end

def funpass_setup
  FileSystem.clear
  FileUtils.mkdir_p Dir.home
end

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

