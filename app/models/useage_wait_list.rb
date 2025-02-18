# frozen_string_literal: true

class UseageWaitList < ApplicationRecord
  self.table_name = 'patchwork_useage_wait_lists'
  belongs_to :account, class_name: 'Account'
  belongs_to :wait_list, class_name: 'WaitList'
end
