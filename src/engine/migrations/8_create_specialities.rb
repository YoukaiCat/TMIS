class CreateSpecialities < ActiveRecord::Migration
  def change
    create_table :specialities do |t|
      t.string :speciality

      t.timestamps
    end
  end
end
