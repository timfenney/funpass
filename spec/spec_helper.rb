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


