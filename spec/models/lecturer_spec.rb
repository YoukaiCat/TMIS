# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/database'
require_relative '../../src/engine/models/lecturer'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe Lecturer do
  before(:all) do
    @lecturer = create(:lecturer)
    @study = create(:study, :whole_group, lecturer: @lecturer)
  end

  describe 'Lecturer associations' do
    it 'Lecturer.studies' do
      @lecturer.studies.last.should eq(@study)
    end

    it 'Study.lecturer' do
      @study.lecturer.should eq(@lecturer)
    end
  end

  it 'should print surname with initials' do
    @lecturer.to_s.should match(/[[:alpha:]]+\s[[:alpha:]]+\.[[:alpha:]]+\./)
  end

  it 'Stubs should not be deleted' do
    s = Lecturer.create(surname: "test", stub: true)
    expect { s.destroy }.to raise_error
    s.delete
  end

  after(:all) do
    Lecturer.delete_all
  end
end
