# coding: UTF-8
class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :title
      t.boolean :stub, default: false

      t.timestamps
    end
  end
end
