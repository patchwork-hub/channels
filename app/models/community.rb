# frozen_string_literal: true

class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'

  has_many :community_admins,
           foreign_key: 'patchwork_community_id',
           dependent: :destroy

  has_many :community_post_types,
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  has_many :community_hashtags,
           foreign_key: 'patchwork_community_id',
           dependent: :destroy

  has_one :content_type,
          class_name: 'ContentType',
          foreign_key: 'patchwork_community_id',
          dependent: :destroy

  validates :name, presence: true, uniqueness: true

  enum visibility: { public_access: 0, guest_access: 1, private_local: 2 }
end
