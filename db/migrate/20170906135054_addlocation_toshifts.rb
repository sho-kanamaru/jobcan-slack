class AddlocationToshifts < ActiveRecord::Migration[5.1]
  def change
    add_column :shifts, :location, :integer
  end
end
