# == Schema Information
# Schema version: 20110108115736
#
# Table name: galleries
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Gallery < ActiveRecord::Base
  attr_accessible :name, :description, :photo
  belongs_to :user
  
  has_attached_file :photo, :styles => { :small => "150x150>",
                                         :big => "700x500"},
                  :url  => "/assets/galleries/:id/:style/:basename.:extension",
                  :path => ":rails_root/public/assets/galleries/:id/:style/:basename.:extension"

  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  
  validates :name,  :presence => true
  validates :description, :length => { :maximum => 140 }
  validates :user_id, :presence => true
  
  default_scope :order => 'galleries.created_at DESC'

  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

    # Return an SQL condition for users followed by the given user.
    # We include the user's own id as well.
    def self.followed_by(user)
      followed_ids = %(SELECT followed_id FROM relationships
                       WHERE follower_id = :user_id)
      where("user_id IN (#{followed_ids}) OR user_id = :user_id",
            { :user_id => user })
    end
end
