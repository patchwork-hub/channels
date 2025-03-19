# frozen_string_literal: true

# == Schema Information
#
# Table name: patchwork_community_post_types
#
#  id                     :bigint(8)        not null, primary key
#  posts                  :boolean          default(FALSE), not null
#  replies                :boolean          default(FALSE), not null
#  reposts                :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  patchwork_community_id :bigint(8)        not null
#
class CommunityPostType < ApplicationRecord
  self.table_name = 'patchwork_community_post_types'

  belongs_to :community,
             class_name: 'Community',
             foreign_key: 'patchwork_community_id'
end
