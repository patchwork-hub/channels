# frozen_string_literal: true

class CommunityAdmin < ApplicationRecord
  self.table_name = 'patchwork_communities_admins'
  belongs_to :account

  belongs_to :community,
             foreign_key: 'patchwork_community_id'
end
