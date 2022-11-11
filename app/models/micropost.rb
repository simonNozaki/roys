class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached(:image)
  default_scope -> { order(created_at: :desc) }
  validates(:user_id, { presence: true })
  validates(:content, {
    presence: true,
    length: {
      maximum: 140
    }
  })
  validates(:image, {
    content_type: {
      in: %w[image/jpeg image/gif image/png],
      message: 'Content should be image/jpeg, image/gif, or image/png.'
    },
    size: {
      less_than: 5.megabytes,
      message: 'File size must be in 5MB.'
    }
  })

  # 最大ピクセル数に合わせた画像を返す
  def get_resized_image
    self.image.variant({ resize_to_limit: [500, 500] })
  end
end
