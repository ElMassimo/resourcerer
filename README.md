Singular Resource
=====================

Extracted from decent exposure, attempts to leave the useful parts, and just use `helper_method` to expose your view models.

## Use
It provides a private method that performs a query for the document when invoked whenever id is defined.
When there is no id parameter, like in `new` and `create`, it returns an initialized model.

### Attributes
Attributes can be assigned from a method or params, and are assigned on POST/PATCH/PUT requests
```ruby
   # app/controllers/person_controller.rb
   class PersonController < ApplicationController
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
      
      def destroy
         person.destroy
         redirect_to action: :index
      end
      
      private
         def person_params
            params.require(:person).permit(:name)
         end
   end
```

#### Strategies
Like `decent_exposure`, it's configurable, and provides different strategies.
By default, it uses `StrongParametersStrategy`, which assumes that there is a `_params` method available that corresponds to the resource if a method name is provided via the `attributes` option.

#### Options
``` ruby
          optional: "Return nil if the document does not exist when passed a truthy value",

             model: "Class or name of the model class",

  finder_parameter: "Name of the parameter that has the document's id",

        attributes: "Name of the attributes method name if using strong parameters",

         param_key: "Name of the parameter that has the document's attributes"
```

## Comparison
What `singular_resource` proposes is that you go from this:

```ruby
class Controller
  def new
    @person = Person.new(params[:person])
  end

  def create
    @person = Person.new(params[:person])
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
    if @person.update_attributes(params[:person])
      redirect_to(@person)
    else
      render :edit
    end
  end
end
```

To something like this:

```ruby
class Controller
  expose(:person)

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
end
```

### With [draper](http://github.com/drapergem/draper)

If you use decorators, you can go from something like this:

```ruby
class Controller
  def new
    @person = Person.new(params[:person]).decorate
  end

  def create
    @person = Person.new(params[:person])
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
    if @person.update_attributes(params[:person])
      redirect_to(@person)
    else
      @person = @person.decorate
      render :edit
    end
  end
end
```

To something like this:

```ruby
class Controller
  before_filter :decorate_person

  singular_resource(:person)

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
    def decorate_person
      @person = person.decorate
    end
end
```

If you think that the `before_filter` is nasty or don't like ivars in your views, so do I! Check the [presenter_rails](http://github.com/ElMassimo/presenter_rails) gem

### Comparison with [decent_exposure](https://github.com/voxdolo/decent_exposure).

#### Similar
Both allow you to find or initialize a simple resource, and assign attributes, removing the boilerplate from CRUD actions.

#### Differences
SingularResource does not expose the model in any way, scope the query to a collection method if defined, nor deal with collections.


### Special Thanks
Singular Resource is heavily based on [decent_exposure](https://github.com/voxdolo/decent_exposure).
