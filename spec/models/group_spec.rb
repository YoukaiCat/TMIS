#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/database'
require_relative '../../src/engine/models/group'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe Group do
  before(:all) do
    @group = create(:group)
    @subgroup = create(:subgroup, group: @group)
    @study = create(:study, :whole_group, groupable: @group)
  end

  describe 'Group associations' do
    it 'Group.subgroups' do
      @group.subgroups.last.should eq(@subgroup)
    end
    it 'Subgroup.group' do
      @subgroup.group.should eq(@group)
    end
    it 'Group.studies' do
      @group.studies.last.should eq(@study)
    end
    it 'Study.groupable' do
      @study.groupable.should eq(@group)
    end
  end

  after(:all) do
    Group.delete_all
  end
end
