#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require './src/engine/database'
require './src/engine/models/semester'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe Semester do
  before(:all) do
    @semester = create(:semester)
    @speciality_subject = create(:speciality_subject, semester: @semester)
  end

  describe "Semester associations" do
    it "Semester.speciality_subjects" do
      @semester.speciality_subjects.last.should eq(@speciality_subject)
    end
    it "Speciality_subject.semester" do
      @speciality_subject.semester.should eq(@semester)
    end
  end

  after(:all) do
    Semester.delete_all
  end
end
