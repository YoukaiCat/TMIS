class CreateSpecialitySubjects < ActiveRecord::Migration
  def change
    create_table :speciality_subjects do |t|
      t.integer :subject_id
      t.integer :semester_id
      t.integer :speciality_id
      t.integer :hours

      t.timestamps
    end
  end
end