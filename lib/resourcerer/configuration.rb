# frozen_string_literal: true

module Resourcerer
  # Internal: Normalizes configuration options by providing common shortcuts for
  # certain options. These shortcuts make the library easier to use.
  #
  # Examples:
  #   find_by: :name     ->(name, collection) { collection.find_by(name: name)}
  #   assign?: :update   -> { action_name == 'update' }
  #   id: :person_id     -> { params[:person_id] }
  class Configuration
    # Public: Available configuration options for a Resource.
    OPTIONS = [
      :assign,
      :assign?,
      :attrs,
      :build,
      :collection,
      :find,
      :find_by,
      :id,
      :model,
      :permit,
    ].freeze

    attr_reader :options

    # Public: Normalizes configuration options for a Resource, ensuring every
    # relevant option is assigned a Proc.
    #
    # options - Config Hash for the new Resource. See OPTIONS.
    # block   - If supplied, the block is executed to provide options.
    #
    # Returns a Hash where every value is a Proc.
    def initialize(options, &block)
      @options = options
      instance_eval(&block) if block_given?

      assert_incompatible_options_pair :find_by, :find
      assert_incompatible_options_pair :permit, :attrs

      normalize_assign_option
      normalize_attrs_option
      normalize_find_by_option
      normalize_id_option
      normalize_model_option
      normalize_permit_option

      assert_proc_options *OPTIONS
    end

    # Public: Applies the configuration to the specified options.
    # Does not override an option if it had previously been specified.
    #
    # Returns the updated configuration options.
    def apply(other_options)
      other_options.reverse_merge!(options)
    end

    # Internal: Every option can also be specified in the block, DSL-style.
    #
    # Each generated method captures the value of an option.
    OPTIONS.each do |name|
      define_method(name) do |arg = nil, &block|
        options[name] = arg || block
      end
    end

  private


    # Internal: Normalizes the `find_by` option to be a `find` Proc.
    #
    # Example:
    #   find_by: :name  ->(name, collection) { collection.find_by(name: name)}
    def normalize_find_by_option
      if find_by = options.delete(:find_by)
        options[:find] = ->(id, scope) { scope.find_by!(find_by => id) }
      end
    end

    # Internal: Normalizes the `permit` option to be a Proc.
    #
    # Example:
    #   permit: [:name]  -> { [:name] }
    def normalize_permit_option
      option_to_proc :permit do |*fields|
        -> { fields }
      end
    end

    # Internal: Normalizes the `assign?` option to be a Proc.
    #
    # Example:
    #   assign?: false  -> { false }
    #   assign?: :update  -> { action_name == 'update' }
    #   assign?: [:edit, :update]  -> { action_name.in?(['edit', 'update']) }
    def normalize_assign_option
      bool = options[:assign?]
      options[:assign?] = -> { bool } if bool == !!bool

      option_to_proc :assign? do |*actions|
        actions = Set.new(actions.map(&:to_s))
        -> { actions.member?(action_name) }
      end
    end

    # Internal: Normalizes the `attrs` option to be a Proc.
    #
    # Example:
    #   attrs: :person_params  -> { person_params }
    def normalize_attrs_option
      option_to_proc :attrs do |params_method|
        -> { send(params_method) }
      end
    end

    # Internal: Normalizes the `id` option to be a Proc.
    #
    # Example:
    #   id: :person_id  -> { params[:person_id] }
    def normalize_id_option
      option_to_proc :id do |*ids|
        -> { ids.map { |id| params[id] }.find(&:present?) }
      end
    end

    # Internal: Normalizes the `model` option to be a Proc.
    #
    # Example:
    #   model: :electric_guitar  -> { ElectricGuitar }
    def normalize_model_option
      option_to_proc :model do |value|
        model = case value
        when String, Symbol then value.to_s.classify.constantize
        else value
        end

        -> { model }
      end
    end

    # Internal: Helper to normalize a non-proc value passed as an option.
    def option_to_proc(name)
      return unless option = options[name]
      options[name] = yield(*option) unless option.is_a?(Proc)
    end

    # Internal: Asserts that the specified options are a Proc, if present.
    def assert_proc_options(*names)
      names.each do |name|
        if options.key?(name) && !options[name].is_a?(Proc)
          raise ArgumentError, "Can't handle #{name.inspect} => #{options[name].inspect} option"
        end
      end
    end

    # Internal: Performs a basic assertion to fail early if the specified
    # options would result in undetermined behavior.
    def assert_incompatible_options_pair(key1, key2)
      if options.key?(key1) && options.key?(key2)
        raise ArgumentError, "Using #{key1.inspect} option with #{key2.inspect} does not make sense"
      end
    end
  end
end
