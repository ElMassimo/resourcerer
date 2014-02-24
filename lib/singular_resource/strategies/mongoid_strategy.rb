require 'singular_resource/strategy'
require 'active_support/core_ext/module/delegation'

module SingularResource
  class MongoidStrategy < Strategy
    delegate :get?, :delete?, :to => :request
    delegate :parameter,      :to => :inflector

    def id
      @id ||= params[parameter] || params[finder_parameter]
    end

    def finder_parameter
      options[:finder_parameter] || :id
    end

    def resource
      if id
        options[:optional] ? model.where(id: id).first : model.find(id)
      else
        scope.new
      end
    end
  end
end
