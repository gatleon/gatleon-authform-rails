# gatleon-authform-rails

add authentication to your application - in 1 minute or less.

## installation

add this line to your application's Gemfile:

```ruby
gem "gatleon-authform-rails"
```

and then execute:

```
$ bundle install
```

open rails credentials:

```
$ EDITOR=vim rails credentials:edit
```

set authform credentials:

```
authform:
  public_key: "Available at https://authform.gatleon.com"
  secret_key: "Available at https://authform.gatleon.com"
```

add a profile controller:

```ruby
class ProfileController < ActionController::Base
  include Gatleon::Authform::Rails::Concern.new(Rails.application.credentials.dig(:authform))

  before_action :require_login, only: [:index]

  def index
    erb = <<~ERB
      <h1>Profile</h1>
      <p style="color: green;">You are signed in. (<a href="/profile/signoff">sign off</a>)</p>
      <p><%= current_user._id %> <%= current_user._email %></p>
    ERB

    render inline: erb
  end

  def signin
    erb = <<~ERB
      <p style="color: red;"><%= flash[:error] %></p>
      <h1>Sign In</h1>
      <form action="<%= signon_url %>" method="POST">
        <input type="hidden" name="successPath" value="/profile">
        <input type="email" name="email">
        <button type="submit">Sign In</button>
      </form>
    ERB

    render inline: erb
  end

  def signoff
    current_user.signoff!

    redirect_to(profile_signin_path) and return
  end

  private

  def require_login
    unless current_user
      flash[:error] = "Sign in, please."

      redirect_to(profile_signin_path) and return
    end
  end
end
```

add profile routes to routes.rb:

```ruby
Rails.application.routes.draw do
  get "/profile", to: "profile#index", as: :profile
  get "/profile/signin", to: "profile#signin", as: :profile_signin
  get "/profile/signoff", to: "profile#signoff", as: :profile_signoff
end
```

that's it!

## license

the gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

