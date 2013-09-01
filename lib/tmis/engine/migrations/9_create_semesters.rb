class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.string :title
      t.integer :course_id

      t.timestamps
    end
  end
end
