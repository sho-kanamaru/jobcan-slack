class CreateShifts < ActiveRecord::Migration[5.1]
  def change
    create_table :shifts do |t|
      t.references :user, foreign_key: true
      t.string :date
      t.string :time
      t.timestamps
    end
  end
end
