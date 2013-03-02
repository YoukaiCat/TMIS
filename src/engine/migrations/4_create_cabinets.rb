class CreateCabinets < ActiveRecord::Migration
  def change
    create_table :cabinets do |t|
      t.string :title
      #type? number & title?

      t.timestamps
    end
  end
end
