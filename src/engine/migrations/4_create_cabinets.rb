# coding: UTF-8
class CreateCabinets < ActiveRecord::Migration
  def change
    create_table :cabinets do |t|
      t.string :title
      t.boolean :stub, default: false
      t.boolean :with_computers, default: false

      t.timestamps
    end
  end
end
