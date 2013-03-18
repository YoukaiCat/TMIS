#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require './src/engine/database'
require './src/engine/models/subgroup'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe Subgroup do
  before(:all) do
    @subgroup = create(:subgroup)
    @study = create(:study, :separated_group, groupable: @subgroup)
  end

  describe "Subgroup associations" do
    it "Subgroup.studies" do
      @subgroup.studies.last.should eq(@study)
    end
    it "Study.groupable" do
      @study.groupable.should eq(@subgroup)
    end
  end

  after(:all) do
    Subgroup.delete_all
  end
end
