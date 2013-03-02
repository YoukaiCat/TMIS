class CreateSubgroups < ActiveRecord::Migration
  def change
    create_table :subgroups do |t|
      t.integer :number
      t.integer :group_id

      t.timestamps
    end
  end
end
