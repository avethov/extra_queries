class QueryAssociationColumn < QueryColumn
  def initialize(name, association, options={})
    super(name, options)
    @association = association
  end

  def value_object(object)
    if assoc = object.send(@association)
      super(assoc)
    end
  end

  def value(object)
    if assoc = object.send(@association)
      super(assoc)
    end
  end

  def css_classes
    @css_classes ||= "#{@association}_#{name}"
  end
end