class Shift < ApplicationRecord
  belongs_to :user

  enum location: %w(shibuya waseda tokyo ikebukuro shinjuku ochanomizu)
end
