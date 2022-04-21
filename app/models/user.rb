class User < ApplicationRecord
  has_secure_password
  validates :id_perfil, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password,
            length: { minimum: 6 },
            if: -> { new_record? || !password.nil? }
end
