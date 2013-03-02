class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :title
      t.integer :speciality_id
      t.integer :course_id

      t.timestamps
    end
  end
end
