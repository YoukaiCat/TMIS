class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.integer :groupable_id
      t.integer :subject_id
      t.integer :lecturer_id
      t.integer :cabinet_id
      t.integer :number
      t.date    :date

      t.timestamps
    end
  end
end
