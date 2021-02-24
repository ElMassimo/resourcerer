<h1 align="center">
Resourcerer
<p align="center">
  <a href="https://github.com/ElMassimo/resourcerer/actions">
    <img alt="Build Status" src="https://github.com/ElMassimo/resourcerer/workflows/build/badge.svg"/>
  </a>
  <a href="https://codeclimate.com/github/ElMassimo/vite_ruby">
    <img alt="Maintainability" src="https://codeclimate.com/github/ElMassimo/vite_ruby/badges/gpa.svg"/>
  </a>
  <a href="https://codeclimate.com/github/ElMassimo/resourcerer">
    <img alt="Test Coverage" src="https://codeclimate.com/github/ElMassimo/resourcerer/badges/coverage.svg"/>
  </a>
  <a href="https://rubygems.org/gems/resourcerer">
    <img alt="Gem Version" src="https://img.shields.io/gem/v/resourcerer.svg?colorB=e9573f"/>
  </a>
  <a href="https://github.com/ElMassimo/resourcerer/blob/master/LICENSE.txt">
    <img alt="License" src="https://img.shields.io/badge/license-MIT-428F7E.svg"/>
  </a>
</p>
</h1>

A small library to help you avoid boilerplate for standard CRUD actions, while improving your controllers' readibility.

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'resourcerer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resourcerer

### Usage

In the simplest scenario you'll just use it to define a resource in the controller:

```ruby
class BandsController < ApplicationController
  resource :band
end
```

Now every time you call `band` in your controller or view, it will look for an
ID and try to perform `Band.find(id)`. If an ID parameter isn't found, it will
call `Band.new(band_params)`. The result will be memoized in a
`@resourcerer_band` instance variable.

#### Example

Here's what a standard Rails CRUD controller using Resourcerer might look like:

```ruby
class BandsController < ApplicationController
  resource :band do
    permit [:name, :genre]
  end

  def create
    if band.save
      redirect_to band_path(band)
    else
      render :new
    end
  end

  def update
    if band.save
      redirect_to band_path(band)
    else
      render :edit
    end
  end

  def destroy
    band.destroy
    redirect_to bands_path
  end
end
```

That's [way less code than usual!](https://gist.github.com/ElMassimo/18fbdb7108f46f3c975712945f7a3318) :smiley:

### Under the Hood

The default resolving workflow is pretty powerful and customizable. It could be
expressed with the following pseudocode:

```ruby
def fetch(scope, id)
  instance = id ? find(id, scope) : build(attrs, scope)
  instance.tap { instance.assign_attributes(attrs) if assign? }
end

def id
  params[:band_id] || params[:id]
end

def find(id, scope)
  scope.find(id)
end

def build(params, scope)
  scope.new(params) # Band.new(params)
end

def scope
  model # Band
end

def model
  :band.classify.constantize # Band
end

def assign?
  action_name == 'update'
end

def attrs
  if respond_to?(:band_params, true) && !request.get?
    band_params
  else
    {}
  end
end
```
The resource is lazy, so it won't do anyband until the method is called.

## Configuration

It is possible to override each step with options. The acceptable options to the
`resource` macro are:

### `id`

In order to fetch a resource Resourcerer relies on the presence of an ID:

```ruby
# Default Behavior
resource :band, id: ->{ params[:band_id] || params[:id] }
```

You can override any option's default behavior by passing in a `Proc`:

```ruby
resource :band, id: ->{ 42 }
```

Passing lambdas might not always be fun, so most options provide shortcuts that
might help make life easier:

```ruby
resource :band, id: :custom_band_id
# same as
resource :band, id: ->{ params[:custom_band_id] }

resource :band, id: [:try_this_id, :or_maybe_that_id]
# same as
resource :band, id: ->{ params[:try_this_id] || params[:or_maybe_that_id] }
```

### `find`

If an ID was provided, Resourcerer will try to find the model:

```ruby
# Default Behavior
resource :band, find: -> (id, scope) { scope.find(id) }
```

Where `scope` is a model scope, like `Band` or `User.active` or
`Post.published`. There's even a convenient shortcut for cases where the ID is
actually something else:

```ruby
resource :band, find_by: :slug
# same as
resource :band, find: ->(slug, scope){ scope.find_by!(slug: slug) }
```

### `build`

When an ID is not present, Resourcerer tries to build an object for you:

```ruby
# Default Behavior
resource :band, build: ->(attrs, scope){ scope.new(band_params) }
```

### `attrs`

This option is responsible for calulating params before passing them to the
build step. The default behavior was modeled with Strong Parameters in mind and
is somewhat smart: it calls the `band_params` controller method if it's
available and the request method is not `GET`. In all other cases it produces
an empty hash.

You can easily specify which controller method you want it to call instead of
`band_params`, or just provide your own logic:

```ruby
resource :band, attrs: :custom_band_params
resource :other_band, attrs: ->{ { foo: "bar" } }

private

def custom_band_params
  params.require(:band).permit(:name, :genre)
end
```

Using the default model name conventions? `permit` can do that for you:

```ruby
resource :band, permit: [:name, :genre]
```

### `collection`

Defines the scope that's used in `find` and `build` steps:

```ruby
resource :band, collection: ->{ current_user.bands }
```

### `model`

Allows you to specify the model class to use:

```ruby
resource :band, model: ->{ AnotherBand }
resource :band, model: AnotherBand
resource :band, model: "AnotherBand"
resource :band, model: :another_band
```

### `assign` and `assign?`

Allows you to specify whether the attributes should be assigned:

```ruby
resource :band, assign?: false
resource :band, assign?: [:edit, :update]
resource :band, assign?: ->{ current_user.admin? }
```

and also how to assign them:

```ruby
resource :band, assign: ->(band, attrs) { band.set_info(attrs) }

```


## Advanced Configuration with `resourcerer_config`

You can define configuration presets with the `resourcerer_config` method to reuse
them later in different resource definitions.

```ruby
resourcerer_config :cool_find, find: ->{ very_cool_find_code }
resourcerer_config :cool_build, build: ->{ very_cool_build_code }

resource :band, using: [:cool_find, :cool_build]
resource :another_band, using: :cool_build
```

Options that are passed to `resource` will take precedence over the presets.


## Decorators or Presenters (like [draper](http://github.com/drapergem/draper))

If you use decorators, you'll be able to avoid [even more boilerplate](https://gist.github.com/ElMassimo/6775148c0d7364be111531a254b41ba9) if you throw [presenter_rails](https://github.com/ElMassimo/presenter_rails) in the mix:

```ruby
class BandController < ApplicationController
  resource(:band, permit: :name)
  present(:band) { band.decorate }

  def create
    if band.save
      redirect_to(band)
    else
      render :new
    end
  end

  def update
    if band.save
      redirect_to(band)
    else
      render :edit
    end
  end
end
```

### Comparison with [Decent Exposure](https://github.com/hashrocket/decent_exposure).

Resourcerer is heavily inspired on [Decent Exposure](https://github.com/hashrocket/decent_exposure), but it attempts to be simpler and more flexible by not focusing on exposing variables to the view context.

#### Similarities
Both allow you to find or initialize a model and assign attributes, removing the boilerplate from most CRUD actions.

#### Differences
Resourcerer does not expose an object to the view in any way, nor deal with decoratation. It also provides better support for strong parameters.

### Special Thanks
Resourcerer is based on [DecentExposure](https://github.com/hashrocket/decent_exposure).
