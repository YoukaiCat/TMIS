class CreateSpecialitySubjects < ActiveRecord::Migration
  def change
    create_table :speciality_subjects do |t|
      t.integer :lecturer_id
      t.integer :subject_id
      t.integer :semester_id
      t.integer :speciality_id
      t.integer :lecture_hours
      t.integer :practical_hours
      t.integer :consultations_hours
      t.string  :preffered_days
      t.boolean :facultative

      t.timestamps
    end
  end
end
