<p align="center">
  <a href="http://github.com/Colex/gdpr_admin" target="blank"><img src="https://i.ibb.co/mJwpsFY/logo.png" width="120" alt="GDPR and Ruby logo" /></a>

  # GDPR Admin

  [![Build Status](https://github.com/Colex/gdpr_admin/actions/workflows/build.yml/badge.svg)](https://github.com/Colex/gdpr_admin/actions/workflows/build.yml)
  [![Code Climate](https://codeclimate.com/github/Colex/gdpr_admin.svg)](https://codeclimate.com/github/Colex/gdpr_admin)
  [![Gem Version](https://badge.fury.io/rb/gdpr_admin.svg)](http://badge.fury.io/rb/gdpr_admin)

  Rails engine for processing GDPR processes. GDPR Admin offers a simple interface for defining strategies for automating the process of data access and data removal as required by data privacy regulations like GDPR.
</p>

## Installation
Add this line to your application's Gemfile:

```ruby
gem "gdpr_admin"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install gdpr_admin
```

## Usage

Create your data policies file within `app/gdpr` _(configurable)_ and inherit from `GdprAdmin::ApplicationDataPolicy`.
Implement the methods `#scope`, `#export` and `#erase` for the new data policy. Within the data policy, you will be
able to access the `GdprAdmin::Request` object in any method by calling the method `request` - you can, therefore, have
different scopes and different removal behaviors depending on the request.

```ruby
class UserDataPolicy < GdprAdmin::ApplicationDataPolicy
  def scope
    User.with_deleted.where(updated_at: ...request.data_older_than)
  end

  def erase(user)
    user.update_columns(
      first_name: 'Anonymous',
      last_name: "User #{user.id}",
      email: "anonymous.user#{user.id}@company.co",
      anonymized_at: Time.zone.now,
    )
  end
end
```

Once you have all your data policies defined, create a `GdprAdmin::Request` to process a new request:

```ruby
GdprAdmin::Request.create!(
  tenant: current_tenant,
  requester: current_admin_user,
  request_type: 'erase_all',
  data_older_than: 1.month.ago, # Optional: by default, it will be todays date
)
```

Creating a request will automatically enqueue the request to be processed in 4 hours - this gives time to cancel an accidental request. You can configure this grace period as desired.


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
