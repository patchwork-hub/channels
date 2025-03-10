# frozen_string_literal: true

# == Schema Information
#
# Table name: patchwork_communities
#
#  id                          :bigint(8)        not null, primary key
#  admin_following_count       :integer          default(0)
#  avatar_image_content_type   :string
#  avatar_image_file_name      :string
#  avatar_image_file_size      :bigint(8)
#  avatar_image_updated_at     :datetime
#  banner_image_content_type   :string
#  banner_image_file_name      :string
#  banner_image_file_size      :bigint(8)
#  banner_image_updated_at     :datetime
#  channel_type                :string           default("channel"), not null
#  description                 :string
#  did_value                   :string
#  guides                      :jsonb
#  is_custom_domain            :boolean          default(FALSE), not null
#  is_recommended              :boolean          default(FALSE), not null
#  logo_image_content_type     :string
#  logo_image_file_name        :string
#  logo_image_file_size        :bigint(8)
#  logo_image_updated_at       :datetime
#  name                        :string           not null
#  participants_count          :integer          default(0)
#  position                    :integer          default(0)
#  slug                        :string           not null
#  visibility                  :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  patchwork_collection_id     :bigint(8)        not null
#  patchwork_community_type_id :bigint(8)
#
class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'

  has_many :community_admins,
           foreign_key: 'patchwork_community_id',
           dependent: :destroy

  has_one :community_post_type,
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

  enum :visibility, public_access: 0, guest_access: 1, private_local: 2
end
