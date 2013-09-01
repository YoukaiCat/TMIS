class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.references :emailable, :polymorphic => true
      t.string :email

      t.timestamps
    end
  end
end
