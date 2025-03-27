# frozen_string_literal: true

# == Schema Information
#
# Table name: patchwork_communities_hashtags
#
#  id                     :bigint(8)        not null, primary key
#  hashtag                :string
#  name                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  patchwork_community_id :bigint(8)        not null
#
class CommunityHashtag < ApplicationRecord
  self.table_name = 'patchwork_communities_hashtags'

  belongs_to :community,
             class_name: 'Community',
             foreign_key: 'patchwork_community_id'
end
