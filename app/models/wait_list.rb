# frozen_string_literal: true

class WaitList < ApplicationRecord
  self.table_name = 'patchwork_wait_lists'
  has_one :useage_wait_list, class_name: 'UseageWaitList', foreign_key: 'patchwork_wait_list_id'
  has_one :account, through: :useage_wait_list, class_name: 'Account', dependent: :destroy

  validates :invitation_code, presence: true, uniqueness: true
end
