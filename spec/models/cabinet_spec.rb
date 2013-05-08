#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/database'
require_relative '../../src/engine/models/cabinet'
require_relative '../../src/engine/models/study'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe Cabinet do
  before(:all) do
    @cabinet = create(:cabinet)
    @study = create(:study, :whole_group, cabinet: @cabinet)
  end

  describe "Cabinet associations" do
    it "Cabinet.studies" do
      @cabinet.studies.last.should eq(@study)
    end
    it "Study.cabinet" do
      @study.cabinet.should eq(@cabinet)
    end
  end

  after(:all) do
    Cabinet.delete_all
  end
end
