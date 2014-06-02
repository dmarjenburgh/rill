class Course < ActiveRecord::Base
  has_many :chapters

  validates_presence_of :name

  def to_s
    "#{name}"
  end

end
