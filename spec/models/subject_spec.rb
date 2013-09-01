#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require_relative '../config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'tmis/engine/database'
require 'tmis/engine/models/subject'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe Subject do
  before(:all) do
    @subject = create(:subject)
    @study = create(:study, :whole_group, subject: @subject)
    @speciality_subject = create(:speciality_subject, subject: @subject)
  end

  describe 'Subject associations' do
    it 'Subject.studies' do
      @subject.studies.last.should eq(@study)
    end
    it 'Study.subject' do
      @study.subject.should eq(@subject)
    end
    it 'Subject.speciality_subjects' do
      @subject.speciality_subjects.last.should eq(@speciality_subject)
    end
    it 'Speciality_subject.subject' do
      @speciality_subject.subject.should eq(@subject)
    end
  end

  it 'Stubs should not be deleted' do
    s = Subject.create(title: "test", stub: true)
    expect { s.destroy }.to raise_error
    s.delete
  end

  after(:all) do
    Subject.delete_all
  end
end
