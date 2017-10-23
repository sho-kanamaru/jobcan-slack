class AddlocationTousers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :location, :integer, null: false
  end
end
