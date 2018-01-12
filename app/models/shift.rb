class Shift < ApplicationRecord
  belongs_to :user

  enum location: %w(shibuya vr ai waseda tokyo ikebukuro shinjuku ochanomizu expert umeda nagoya ios)
end
