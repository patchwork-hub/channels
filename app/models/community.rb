# frozen_string_literal: true

# == Schema Information
#
# Table name: patchwork_communities
#
#  id                          :bigint(8)        not null, primary key
#  about                       :string
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
#  deleted_at                  :datetime
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
#  post_visibility             :integer          default("followers_only"), not null
#  registration_mode           :string           default("none")
#  slug                        :string           not null
#  visibility                  :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  ip_address_id               :bigint(8)
#  patchwork_collection_id     :bigint(8)
#  patchwork_community_type_id :bigint(8)
#
class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'

  LIMIT = 2.megabytes

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

  enum :post_visibility, { public_visibility: 0, unlisted: 1, followers_only: 2, direct: 3 }

  has_attached_file :avatar_image
  has_attached_file :banner_image

  validates_attachment :avatar_image,
                       content_type: { content_type: %r{\Aimage/.*\z} },
                       size: { less_than: LIMIT }

  validates_attachment :banner_image,
                       content_type: { content_type: %r{\Aimage/.*\z} },
                       size: { less_than: LIMIT }

  def self.default_privacy(user)
    admin = CommunityAdmin.find_by(account_id: user.account_id, is_boost_bot: true, account_status: CommunityAdmin.account_statuses['active'])
    return nil unless admin

    community = Community.find_by(id: admin.patchwork_community_id)
    return nil unless community&.content_type&.group_channel?

    case community.post_visibility
    when 'followers_only'
      'private'
    when 'public_visibility'
      'public'
    else
      community.post_visibility
    end
  end
end
