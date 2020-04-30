module Gatleon
  module Authform
    module Rails
      class User
        PERMITTED_CHARS = /\A[a-zA-Z0-9_)]*\z/

        def initialize(json:, _form_secret_key:, _authform_base_url:)
          @json = json

          @_form_secret_key = _form_secret_key
          @_authform_base_url = _authform_base_url
        end

        # Getters
        #
        def _id
          @json["_id"]
        end

        def _email
          @json["_email"]
        end

        # Getters
        #
        def [](key)
          @json[key.to_s]
        end

        # Setters
        #
        def []=(key, value)
          key = _clean_key(key)

          raise Gatleon::Authform::Rails::Error, "can't set reserved field name #{key}" if key[0] == "_" # anything starting with _

          raise Gatleon::Authform::Rails::Error, "can't set empty field name" if key == ""

          raise Gatleon::Authform::Rails::Error, "only characters a-z, A-Z, 0-9, and _ permitted in field name" unless key.match?(PERMITTED_CHARS)

          @json[key] = value.to_s
        end

        private

        def _persist(key, value)
          uri = _persist_url(key, vlue)
          
          Net::HTTP.get_response(uri) # TODO: move to post request
        end

        def _persist_url(key, value)
          URI("#{@_authform_base_url}/v1/setUser?_id=#{_id}&_secretKey=#{@_form_secret_key}&#{key}=#{value}")
        end

        def _clean_key(k_or_v)
          k_or_v.to_s.strip
        end
      end
    end
  end
end

