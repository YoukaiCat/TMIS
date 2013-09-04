# encoding: UTF-8

class RadioButtonDelegate < Qt::ItemDelegate
  def initialize(parent)
    super
  end

  def createEditor(parent, option, index)
    Qt::CheckBox.new(parent)
  end

  def setEditorData(editor, index)
    value = index.data(Qt::EditRole).toBool #index.model.data(index, Qt::EditRole)
    button = editor
    button.checked = value # button.setValue(value)
  end

  def setModelData(editor, model, index)
    button = editor
    value = button.isChecked # button.value
    model.setData(index, value.to_v, Qt::EditRole)
  end

  def updateEditorGeometry(editor, option, index)
    editor.setGeometry(option.rect)
  end
end

class ARComboBoxDelegate < Qt::ItemDelegate
  def initialize(parent, klass, attribute_name)
    # Метод super(), в отличии от ключевого слова super, позволяет
    # определять какие аргументы передать родительскому методу
    super(parent)
    @class = klass
    @attribute = attribute_name.to_sym
    setup
  end

  def setup
    @entities = @class.all.sort_by(&@attribute)
  end

  def createEditor(parent, option, index)
    editor = Qt::ComboBox.new(parent)
    @entities.each{ |x| editor.addItem(x.send(@attribute).to_s, x.id.to_v) }
    editor
  end

  def setEditorData(editor, index)
    value = index.data(Qt::EditRole)
    editor.setCurrentIndex(editor.findData(value))
  end

  def setModelData(editor, model, index)
    if editor.currentIndex > -1
      value = editor.itemData(editor.currentIndex)
      model.setData(index, value, Qt::EditRole)
    end
  end

  def updateEditorGeometry(editor, option, index)
    editor.setGeometry(option.rect)
  end
end
