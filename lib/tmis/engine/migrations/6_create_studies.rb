class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.references :groupable, :polymorphic => true
      t.integer :subject_id
      t.integer :lecturer_id
      t.integer :cabinet_id
      t.integer :number
      t.date    :date
      t.string  :color

      t.timestamps
    end
  end
end
