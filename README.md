Singular Resource
=====================

Extracted from decent exposure, attempts to leave the useful parts, and just use `helper_method` to expose your view models.

## DOES
Allow you to find or initialize a simple resource, removing the boilerplate from CRUD actions.


## DOES NOT
Expose the model in any way, scope the query to a collection method if defined, or deal with collections.


## Use
It provides a private method that performs a query for the document when invoked, unless the id is not defined (`new`, `create`), in which case it returns an initialized model.
```ruby
   singular_resource :patient
```

#### Strategies
Like `decent_exposure`, it's configurable, and provides different strategies.
By default, it uses `StrongParametersStrategy`, which only assigns the attributes if a method name is provided via the `attributes` option.

#### Options
``` ruby
  :optional => "True if shouldn't fail if document does not exist",

  :model => "Class or name of the model class",

  :finder_parameter => "Name of the parameter that has the document's id",

  :attributes => "Name of the attributes method name if using strong parameters",

  :param_key => "Name of the parameter that has the document's attributes"
```

### Special Thanks
Singular Resource is a subset of [decent_exposure](https://github.com/voxdolo/decent_exposure).
