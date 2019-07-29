require 'rails_helper'

feature 'cac proofing enter info step' do
  include CacProofingHelper

  before do
    enable_cac_proofing
    sign_in_and_2fa_user
    complete_cac_proofing_steps_before_present_cac_step
  end

  it 'is on the correct page' do
    expect(page).to have_current_path(idv_cac_proofing_enter_info_step)
  end

  it 'proceeds to the next page' do
    click_continue

    expect(page).to have_current_path(idv_cac_proofing_verify_step)
  end
end
