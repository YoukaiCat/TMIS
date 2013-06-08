# coding: UTF-8
class CreateLecturers < ActiveRecord::Migration
  def change
    create_table :lecturers do |t|
      t.string :surname
      t.string :name
      t.string :patronymic
      t.boolean :stub

      t.timestamps
    end
  end
end
