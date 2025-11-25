# == Schema Information
#
# Table name: ip_addresses
#
#  id          :bigint           not null, primary key
#  ip          :string           not null
#  private_ip  :string
#  reserved_at :datetime
#  use_count   :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_ip_addresses_on_ip  (ip) UNIQUE
#
class IpAddress < ApplicationRecord
  LIMIT_USAGE = 15
  RESERVATION_WINDOW = 1.hour
  has_many :communities

  validates :ip, presence: true, uniqueness: true, format: { with: Resolv::IPv4::Regex, message: "must be a valid IPv4 address" }

  def decrement_use_count
    update!(use_count: use_count - 1)
  end
end
