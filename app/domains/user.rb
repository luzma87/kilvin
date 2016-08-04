class User
  include Mongoid::Document

  field :email, type: String
  field :name, type: String

  validates :email, presence: true, format: /\A([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})\z/i,
            length: { minimum: 8, maximum: 50 }, uniqueness: true

  validates :name, presence: true, length: { minimum: 3, maximum: 200 }
end