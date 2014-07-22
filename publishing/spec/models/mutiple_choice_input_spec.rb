require 'rails_helper'

RSpec.describe MultipleChoiceInput, type: :model do

  it {is_expected.to have_many :choices}

  before do
    @multiple_choice_input = create(:multiple_choice_input)
  end

  it "should return an abbreviated uuid" do
    id = @multiple_choice_input.id.to_s
    expect(@multiple_choice_input.to_param).to eq id[0,8]
  end

end
