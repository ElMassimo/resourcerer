class EagerStrongParametersStrategy < DefaultStrategy

  def attributes
    super || attributes_from_method
  end

  private

  def attributes_from_method
    controller.send(attributes_method)
  end

  def attributes_method
    config.attributes_method || "#{name}_params"
  end
end
