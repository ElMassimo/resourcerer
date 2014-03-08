Singular Resource
=====================
What `singular_resource` proposes is that you go from this:

```ruby
class Controller
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
class Controller
  singular_resource :person

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

Let's see what SingularResource is doing behind the curtains :smiley:. This examples assume that you are using Rails 4 Strong Parameters.

### Obtaining a resource:

```ruby
singular_resource :person
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
singular_resource(:company, model: :enterprise)
```

**Specify the parameter key to use to fetch the object:**

```ruby
singular_resource(:enterprise, finder_parameter: :company_id)
```

**Specify how to obtain the object attributes:**

```ruby
# Specify the strong parameters method's name when using the default `StrongParametersStrategy`
singular_resource(:employee, attributes: :person_params)

# Specify the parameter key that holds the attributes when using the `EagerAttributesStrategy`
singular_resource(:person, param_key: :employee)
```

**Specifying an optional resource**

```ruby
class EmployeeController
  singular_resource(:person, optional: true)
  
  def custom
    if person
      render :show
    else
      redirect_to :index
    end
  end
```

### Setting a distinct object for a single action

There are times when one action in a controller is different from the
rest of the actions. A nice approach to circumvent this is to use the
controller's setter methods. This example uses [presenter_rails](https://github.com/ElMassimo/presenter_rails).

```ruby
singular_resource(:article)

def show_oldest
  self.article = Article.find_oldest
end

present :article do
  ArticlePresenter.new(article)
end
```

### Custom strategies

For times when you need custom behavior for resource finding, you can
create your own strategy by extending `SingularResource::Strategy`:

```ruby
class VerifiableStrategy < SingularResource::Strategy
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
singular_resource(:post, strategy: VerifiableStrategy)
```

### Customizing your resources

For most things, you'll be able to pass a few configuration options and get
the desired behavior. For changes you want to affect every call to 
`singular_resource` in a controller or controllers inheriting from it, you
can define a `singular_configuration` block:

```ruby
class ApplicationController < ActionController::Base
  singular_configuration do
    strategy EagerAttributesStrategy
  end
end
```

## Using decorators or presenters
### With [draper](http://github.com/drapergem/draper)

If you use decorators, you can go from something like this:

```ruby
class Controller
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
class Controller
  singular_resource(:person)
  
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

SingularResource is shamelessly extracted from [decent exposure](https://github.com/voxdolo/decent_exposure), it attempts to be more predictable by focusing on finding a resource and assigning attributes, and discarding completely the view exposure part.

#### Similarities
Both allow you to find or initialize a resource and assign attributes, removing the boilerplate from most CRUD actions.

#### Differences
SingularResource does not expose an object to the view in any way, scope the query to a collection method if defined, nor deal with collections.


### Special Thanks
Singular Resource is heavily based on [decent_exposure](https://github.com/voxdolo/decent_exposure).
