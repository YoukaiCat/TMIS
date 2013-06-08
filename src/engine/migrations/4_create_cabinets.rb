# coding: UTF-8
class CreateCabinets < ActiveRecord::Migration
  def change
    create_table :cabinets do |t|
      t.string :title
      t.boolean :stub
      #TODO type? number & title?

      t.timestamps
    end
  end
end
