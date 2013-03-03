require 'rspec'
require 'config'
require './src/engine/database'
require './src/engine/models/lecturer'

describe Lecturer do
  before(:all) do
    @lecturer = create(:lecturer)
    @study = create(:study, :whole_group, lecturer: @lecturer)
  end

  describe "Lecturer associations" do
    it "Lecturer.studies" do
      @lecturer.studies.last.should eq(@study)
    end
    it "Study.lecturer" do
      @study.lecturer.should eq(@lecturer)
    end
  end
end
