require_relative '../spec_helper'
require_relative '../../lib/funpass'
require_relative '../../lib/store'

describe Store do
  describe '.scrub' do
    include_context 'fake fs'

    context 'with a full installation' do
      it 'removes the funpass installation' do
        FunPass.init
        Store.scrub
        expect(Dir.exists? FUNPASS_DIR).to_not be_true
      end
    end
  end
end
