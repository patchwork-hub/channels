# frozen_string_literal: true

# == Schema Information
#
# Table name: patchwork_communities_admins
#
#  id                     :bigint(8)        not null, primary key
#  account_status         :integer          default("active"), not null
#  display_name           :string
#  email                  :string
#  is_boost_bot           :boolean          default(FALSE), not null
#  password               :string
#  role                   :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :bigint(8)
#  patchwork_community_id :bigint(8)
#
class CommunityAdmin < ApplicationRecord
  self.table_name = 'patchwork_communities_admins'
  belongs_to :community, foreign_key: 'patchwork_community_id', optional: true
  belongs_to :account, foreign_key: 'account_id', optional: true

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' },
                    uniqueness: { case_sensitive: false, message: 'is already in use. Please use a different email for the organisation admin account.' }

  enum :account_status, active: 0, suspended: 1, deleted: 2
end
