class AddIndexes < ActiveRecord::Migration
  def change
    add_index(:groups, [:id, :title])
    add_index(:subgroups, [:id, :group_id, :number])
    add_index(:subjects, [:id, :title])
    add_index(:cabinets, [:id, :title])
    add_index(:lecturers, [:id, :surname])
    add_index(:studies, [:subject_id, :lecturer_id, :cabinet_id])
    add_index(:courses, [:id, :number])
    add_index(:specialities, [:id, :title])
    add_index(:semesters, [:id, :course_id, :title])
    add_index(:speciality_subjects, [:subject_id, :semester_id])
  end
end
