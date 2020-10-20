require 'rails_helper'

describe DocAuth::LexisNexis::ErrorGenerator do

  def build_alerts(*failed)
    {
      passed: [],
      failed: failed,
    }
  end

  def build_error_info (doc_auth_result, alerts, pm_result)
    {
      ConversationId: 31000406181234,
      Reference: 'Reference1',
      LivenessChecking: 'test',
      ProductType: 'TrueID',
      TransactionReasonCode: 'testing',
      DocAuthResult: doc_auth_result,
      Alerts: alerts,
      AlertFailureCount: alerts[:failed].length,
      PortraitMatchResults: { FaceMatchResult: pm_result },
      ImageMetrics: {},
    }
  end

  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  context 'The correct errors are delivered with liveness off when' do
    it 'DocAuthResult is Attention' do
      error_info = build_error_info(
        'Attention',
        build_alerts({name: '2D Barcode Read', result: 'Attention'}),
        nil)

      output = described_class.generate_trueid_errors(error_info, false)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:back)
      expect(output[:back]).to contain_exactly(I18n.t('doc_auth.errors.lexis_nexis.barcode_read_check'))
    end

    it 'DocAuthResult is Failed' do
      error_info = build_error_info(
        'Failed',
        build_alerts({name: 'Visible Pattern', result: 'Failed'}),
        nil)

      output = described_class.generate_trueid_errors(error_info, false)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:id)
      expect(output[:id]).to contain_exactly(I18n.t('doc_auth.errors.lexis_nexis.id_not_verified'))
    end

    it 'DocAuthResult is Failed with multiple different alerts' do
      error_info = build_error_info(
        'Failed',
        build_alerts({name: '2D Barcode Read', result: 'Attention'},
                     {name: 'Visible Pattern', result: 'Failed'}),
        nil)

      output = described_class.generate_trueid_errors(error_info, false)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:general)
      expect(output[:general]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.general_error_no_liveness')
      )
    end

    it 'DocAuthResult is Failed with multiple id alerts' do
      error_info = build_error_info(
        'Failed',
        build_alerts({name: 'Expiration Date Valid', result: 'Attention'},
                     {name: 'Full Name Crosscheck', result: 'Failed'}),
        nil)

      output = described_class.generate_trueid_errors(error_info, false)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:id)
      expect(output[:id]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.general_error_no_liveness')
      )
    end

    it 'DocAuthResult is Failed with multiple back alerts' do
      error_info = build_error_info(
        'Failed',
        build_alerts({name: '2D Barcode Read', result: 'Attention'},
                          {name: '2D Barcode Content', result: 'Failed'}),
        nil)

      output = described_class.generate_trueid_errors(error_info, false)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:back)
      expect(output[:back]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.multiple_back_id_failures')
      )
    end

    it 'DocAuthResult is Failed with an unknown alert' do
      error_info = build_error_info(
        'Failed',
        build_alerts({name: 'Not a known alert', result: 'Failed'}),
        nil)

      expect(NewRelic::Agent).to receive(:notice_error).
        with(anything, hash_including(:custom_params)).twice

      output = described_class.generate_trueid_errors(error_info, false)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:general)
      expect(output[:general]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.general_error_no_liveness')
      )
    end

    it 'DocAuthResult is Failed with multiple alerts including an unknown' do
      error_info = build_error_info(
        'Failed',
        build_alerts({name: 'Not a known alert', result: 'Failed'},
                     {name: 'Birth Date Crosscheck', result: 'Failed'}),
        nil)

      expect(NewRelic::Agent).to receive(:notice_error).
        with(anything, hash_including(:custom_params)).once

      output = described_class.generate_trueid_errors(error_info, false)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:id)
      expect(output[:id]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.birth_date_checks')
      )
    end

    it 'DocAuthResult is Failed with an unknown passed alert' do
      error_info = build_error_info(
        'Failed',
        { passed: [{name: 'Not a known alert', result: 'Passed'}],
          failed: [{name: 'Birth Date Crosscheck', result: 'Failed'}] },
        nil)

      expect(NewRelic::Agent).to receive(:notice_error).
        with(anything, hash_including(:custom_params)).once

      output = described_class.generate_trueid_errors(error_info, false)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:id)
      expect(output[:id]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.birth_date_checks')
      )
    end
  end

  context 'The correct errors are delivered with liveness on when' do
    it 'DocAuthResult is Attention and selfie has passed' do
      error_info = build_error_info(
        'Attention',
        build_alerts({name: '2D Barcode Read', result: 'Attention'}),
        'Pass')

      output = described_class.generate_trueid_errors(error_info, true)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:back)
      expect(output[:back]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.barcode_read_check')
      )
    end

    it 'DocAuthResult is Attention and selfie has failed' do
      error_info = build_error_info(
        'Attention',
        build_alerts({name: '2D Barcode Read', result: 'Attention'}),
        'Fail')

      output = described_class.generate_trueid_errors(error_info, true)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:general)
      expect(output[:general]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.general_error_liveness')
      )
    end

    it 'DocAuthResult is Attention and selfie has succeeded' do
      error_info = build_error_info(
        'Attention',
        build_alerts({name: '2D Barcode Read', result: 'Attention'}), 'Pass')

      output = described_class.generate_trueid_errors(error_info, true)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:back)
      expect(output[:back]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.barcode_read_check')
      )
    end

    it 'DocAuthResult has passed but liveness failed' do
      error_info = build_error_info('Passed', build_alerts(), 'Fail')

      output = described_class.generate_trueid_errors(error_info, true)

      expect(output.keys.length).to equal(1)
      expect(output.keys.first).to equal(:selfie)
      expect(output[:selfie]).to contain_exactly(
        I18n.t('doc_auth.errors.lexis_nexis.selfie_failure')
      )
    end
  end
end
