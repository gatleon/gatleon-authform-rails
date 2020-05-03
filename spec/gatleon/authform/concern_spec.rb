require "active_support/concern"
require "rails"
require "action_controller"
require "byebug"

RSpec.describe Gatleon::Authform::Rails::Concern do
  let(:user_voucher) { "authform_user_voucher_1234" }

  let(:public_key) { "authform_form_public_1234" }
  let(:secret_key) { "authform_form_secret_1234" }

  let(:dummy) do
    class DummyController < ActionController::Base
      include Gatleon::Authform::Rails::Concern.new(public_key: "authform_form_public_1234", secret_key: "authform_form_secret_1234")
    end

    DummyController.new
  end

  let(:params) do
    {
      _authformForm: public_key,
      _authformUserVoucher: user_voucher
    }
  end

  let(:body) do
    JSON.generate({ data: { _id: "1", _email: "a@example.com" } })
  end
  let(:response) { double("response", code: "200", body: body) }
  let(:request) { double("request", url: "http://example.com/profile?_authformForm=#{public_key}&_authformUserVoucher=#{user_voucher}", path: "/profile") }
  let(:cookies) { {} }

  before do
    allow(dummy).to receive(:params).and_return(params)
    allow(dummy).to receive(:cookies).and_return(cookies)
    allow(dummy).to receive(:request).and_return(request)
    allow(dummy).to receive(:redirect_to).and_return(true)

    allow(Net::HTTP).to receive(:get_response).and_return(response)
  end

  describe "#_exchange_user_voucher_for_user" do
    it "sets cookie" do
      expect(cookies).to receive(:[]=).with("authform_form_public_1234_46947589", { value: body }).once

      dummy.send(:_exchange_user_voucher_for_user)
    end

    context "when domain :all is set" do
      let(:dummy) do
        class DummyController < ActionController::Base
          include Gatleon::Authform::Rails::Concern.new(public_key: "authform_form_public_1234", secret_key: "authform_form_secret_1234", domain: :all)
        end

        DummyController.new
      end

      it "sets cookie with domain all" do
        expect(cookies).to receive(:[]=).with("authform_form_public_1234_3815978777", { value: body, domain: :all }).once

        dummy.send(:_exchange_user_voucher_for_user)
      end
    end

    context "when domain set to a list of domains" do
      let(:dummy) do
        class DummyController < ActionController::Base
          include Gatleon::Authform::Rails::Concern.new(public_key: "authform_form_public_1234", secret_key: "authform_form_secret_1234", domain: %w(.example.com .example.org))
        end

        DummyController.new
      end

      it "sets cookie with domain all" do
        expect(cookies).to receive(:[]=).with("authform_form_public_1234_4159358443", { value: body, domain: [".example.com", ".example.org"] }).once

        dummy.send(:_exchange_user_voucher_for_user)
      end
    end
  end
end

