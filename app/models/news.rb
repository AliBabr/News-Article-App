class News < ApplicationRecord
  has_one_attached :image

  def self.search(query)
    if query.blank?  # blank? covers both nil and empty string
      all
    else
      where('title LIKE ?', "%#{query}%")
    end
  end
end
