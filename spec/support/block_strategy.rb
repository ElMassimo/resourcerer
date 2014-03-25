class BlockStrategy < Resourcerer::Strategy
  def resource
    config_proc.call
  end
end
