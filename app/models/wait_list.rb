# frozen_string_literal: true

class WaitList < ApplicationRecord
  self.table_name = 'patchwork_wait_lists'
  belongs_to :account, class_name: 'Account', optional: true, uniqueness: true

  validates :invitation_code, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :description, length: { maximum: 255 }, allow_blank: true
end
