class AddmentionExpTousers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :mention_exp, :string
  end
end
