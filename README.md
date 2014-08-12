Resourcerer
=====================
What `resourcerer` proposes is that you go from this:

```ruby
class PersonController < ApplicationController
  def new
    @person = Person.new
  end

  def create
    @person = Person.new(person_params)
    if @person.save
      redirect_to(@person)
    else
      render :new
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(person_params)
      redirect_to(@person)
    else
      render :edit
    end
  end
  
  private
    def person_params
      params.require(:person).permit(:name)
    end
end
```

To something like this:

```ruby
class PersonController < ApplicationController
  resource :person

  def create
    if person.save
      redirect_to(person)
    else
      render :new
    end
  end

  def update
    if person.save
      redirect_to(person)
    else
      render :edit
    end
  end
  
  private
    def person_params
      params.require(:person).permit(:name)
    end
end
```

The idea is that you don't have to write boilerplate for standard CRUD actions, while at the same time improving your controllers readibility.

## Usage

Let's see what Resourcerer is doing behind the curtains :smiley:.

This examples assume that you are using Rails 4 Strong Parameters.

### Obtaining a resource:

```ruby
resource :person
```

**Query Explanation**

<table>
  <tr>
    <td><code>id</code> present?</td>
    <td>Query (get/delete)</td>
    <td>Query (post/patch/put)</td>
  </tr>
  <tr>
    <td><code>true</code></td>
    <td><code>Person.find(params[:id])</code></td>
    <td><code>Person.find(params[:id]).attributes = person_params</code></td>
  </tr>
  <tr>
    <td><code>false</code></td>
    <td><code>Person.new</code></td>
    <td><code>Person.new(person_params)</code></td>
  </tr>
</table>


### Configuration

Let's take a look at some of the things you can do:

**Specify the model name:**

```ruby
resource(:company, model: :enterprise)
```

**Specify the parameter key to use to fetch the object:**

```ruby
resource(:enterprise, finder_param: :company_id)
```

**Specify the model attribute to use to perform the search:**

```ruby
resource(:enterprise, find_by: :name)
```

**Specify how to obtain the object attributes:**

```ruby
# Specify the strong parameters method's name when using the default `StrongParametersStrategy`
resource(:employee, attributes_method: :person_params)

# Specify the parameter key that holds the attributes when using the `EagerAttributesStrategy`
resource(:person, param_key: :employee)
```

### DSL
Resourcer also features a nice DSL, which is helpful when you need more control over the resource
lifecycle.

You can also access every configuration option available above:
```ruby
resource(:employee) do
  model :person
  find_by :name
  find {|name| company.find_employee(name) }
  build { company.new_employee }
  assign { params.require(:employee).permit(:name) }
  permit [:name, :description]
end
# is the same as:
resource(:employee, model: :person, finder_attribute: :name, finder: ->(name){ company.find_employee(name) }, builder: ->{ company.new_employee }, attributes: ->{ params.require(:employee).permit(:name) })
```
The DSL is more convenient when you have an object oriented design and want to allow an object to handle its collections, or as a quick way to set the StrongParameters method.

Configuration options play well together, and the defaults try to make intelligent use of them. For example,
setting the `finder_attribute` in the example above changes the `finder_param` to `person_name` instead of `person_id`, and the value of that parameter is provided to the finder block.

### Setting a distinct object for a single action

There are times when one action in a controller is different from the
rest of the actions. A nice approach to circumvent this is to use the
controller's setter methods. This example uses [presenter_rails](https://github.com/ElMassimo/presenter_rails).

```ruby
resource(:article)

def show_oldest
  self.article = Article.find_oldest
end

present :article do
  ArticlePresenter.new(article)
end
```

### Custom strategies

For times when you need custom behavior for resource finding, you can
create your own strategy by extending `Resourcerer::Strategy`:

```ruby
class VerifiableStrategy < Resourcerer::Strategy
  delegate :current_user, :to => :controller

  def resource
    instance = model.find(params[:id])
    if current_user != instance.user
      raise ActiveRecord::RecordNotFound
    end
    instance
  end
end
```

You would then use your custom strategy in your controller:

```ruby
resource(:post, strategy: VerifiableStrategy)
```

## Using decorators or presenters
### With [draper](http://github.com/drapergem/draper)

If you use decorators, you can go from something like this:

```ruby
class PersonController < ApplicationController
  def new
    @person = Person.new.decorate
  end

  def create
    @person = Person.new(person_params)
    if @person.save
      redirect_to(@person)
    else
      @person = @person.decorate
      render :new
    end
  end

  def edit
    @person = Person.find(params[:id]).decorate
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(person_params)
      redirect_to(@person)
    else
      @person = @person.decorate
      render :edit
    end
  end
  
  private
    def person_params
      params.require(:person).permit(:name)
    end
end
```

To something like this by adding [presenter_rails](https://github.com/ElMassimo/presenter_rails) to the mix:

```ruby
class PersonController < ApplicationController
  resource(:person)
  
  present :person do
    person.decorate
  end

  def create
    if person.save
      redirect_to(person)
    else
      render :new
    end
  end

  def update
    if person.save
      redirect_to(person)
    else
      render :edit
    end
  end

  private
    def person_params
      params.require(:person).permit(:name)
    end
end
```

### Comparison with [decent_exposure](https://github.com/voxdolo/decent_exposure).

Resourcerer is heavily inspired on [decent exposure](https://github.com/voxdolo/decent_exposure), it attempts to be more predictable by focusing on finding a resource and assigning attributes, and discarding completely the view exposure part.

#### Similarities
Both allow you to find or initialize a resource and assign attributes, removing the boilerplate from most CRUD actions.

#### Differences
Resourcerer does not expose an object to the view in any way, scope the query to a collection method if defined, nor deal with collections. It also has better support for strong parameters.


### Caveats
#### When using StrongParametersStrategy
Since attributes are assigned on every POST, PUT, and PATCH request, sometimes when using Strong Parameters it's not desirable that the attributes method is called. For that reason, the presence of `params[param_key]` is checked before assigning attributes.
##### Troubleshooting
- _The attributes are not being assigned_: Check that the resource name matches the param used in the attributes method, and set the `param_key` configuration if they are different.
- _Need an error to be thrown if the params are not present_: Use the `EagerStrongParametersStrategy`, available in the sample strategies in this repository, you can set it using the `strategy` configuration option.

### Special Thanks
Resourcerer was inspired by [decent_exposure](https://github.com/voxdolo/decent_exposure).
