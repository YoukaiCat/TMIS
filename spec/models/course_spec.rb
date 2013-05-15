#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/database'
require_relative '../../src/engine/models/course'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe Course do
  before(:all) do
    @course = create(:course)
    @semester = create(:semester, course: @course)
  end

  describe 'Course associations' do
    it 'Course.semesters' do
      @course.semesters.last.should eq(@semester)
    end
    it 'Semester.course' do
      @semester.course.should eq(@course)
    end
  end

  after(:all) do
    Course.delete_all
  end
end
