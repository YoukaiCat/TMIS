class CreateLecturers < ActiveRecord::Migration
  def change
    create_table :lecturers do |t|
      t.string :surname
      t.string :name
      t.string :patronymic

      t.timestamps
    end
  end
end
