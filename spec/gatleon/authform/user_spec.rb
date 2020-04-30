require "active_support/concern"

RSpec.describe Gatleon::Authform::Rails::User do
  let(:_id) { "2" }
  let(:_email) { "email@example.com" }

  let(:_form_secret_key) { "authform_form_secret_1234" }
  let(:_authform_base_url) { "https://authform.gatleon.com" }

  let(:json) do
    {
      "_id" => _id,
      "_email" => _email
    }
  end

  let(:attrs) do
    {
      json: json,
      _form_secret_key: _form_secret_key,
      _authform_base_url: _authform_base_url
    }
  end

  let(:user) { Gatleon::Authform::Rails::User.new(attrs) }

  describe "#_id" do
    it "returns" do
      expect(user["_id"]).to eql("2")
    end
  end

  describe "#_email" do
    it "returns" do
      expect(user["_email"]).to eql("email@example.com")
    end
  end

  describe "setting" do
    it "cannot set _id" do
      expect do
        user["_id"] = "99"
      end.to raise_error(StandardError)
    end

    it "cannot set _email" do
      expect do
        user["_email"] = "other@example.com"
      end.to raise_error(StandardError)
    end

    it "can set and get a custom attribute" do
      user["name"] = "Person One"

      expect(user["name"]).to eql("Person One")
    end

    it "cannot set an empty key" do
      expect do
        user[""] = "something"
      end.to raise_error(StandardError)

      expect do
        user[" "] = "something"
      end.to raise_error(StandardError)

      expect do
        user[" "] = "something"
      end.to raise_error(StandardError)
    end

    it "converts value types to string" do
      user["phone_number"] = 5551238484
      expect(user["phone_number"]).to eql("5551238484")

      user["phone_number"] = nil
      expect(user["phone_number"]).to eql("")
    end

    it "converts key types to string" do
      user[2] = "hi"
      expect(user["2"]).to eql("hi")
      expect(user[2]).to eql("hi")
    end

    it "does not permit keys with -" do
      expect do
        user["key-with-dash"] = "hi"
      end.to raise_error(StandardError)
    end
  end
end
