class Chapter < ActiveRecord::Base
  include Trashable, Activateable

  belongs_to :course
  acts_as_list scope: :course

  has_many :sections, -> { order(:position) }
  has_one :chapter_quiz

  validates :course, presence: true
  validates :title, presence: true

  default_scope { order(:position) }

  scope :active, -> { where(active: true) }

  scope :for_short_uuid, ->(id) { where(["SUBSTRING(CAST(id AS VARCHAR), 1, 8) = ?", id]) }
  def self.find_by_uuid(id, with_404 = true)
    chapters = for_short_uuid(id)
    raise ActiveRecord::RecordNotFound if chapters.empty? && with_404
    raise StudyflowPublishing::ShortUuidDoubleError.new("Multiple chapters found for uuid: #{id}") if chapters.length > 1
    chapters.first
  end

  def to_s
    "#{title}"
  end

  def to_publishing_format
    hash = {
      id: id,
      title: title.to_s.strip,
      sections: sections.active.map(&:to_publishing_format),
      remedial: remedial?
    }
    hash[:chapter_quiz] = chapter_quiz.to_publishing_format if chapter_quiz && chapter_quiz.active?
    hash
  end

  def errors_when_publishing
    errors = []
    errors << sections.active.map(&:errors_when_publishing)
    errors << chapter_quiz.errors_when_publishing if chapter_quiz && chapter_quiz.active?
    errors.flatten
  end


  def to_param
    "#{id[0,8]}"
  end

end
