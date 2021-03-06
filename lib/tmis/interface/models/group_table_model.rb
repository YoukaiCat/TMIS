# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/group'
require 'tmis/interface/delegates'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class GroupTableModel < Qt::AbstractTableModel

  def initialize(groups, parent)
    super()
    @groups = groups
    @groups.size
    @view = parent
    @SpecialityComboBoxDelegate = ARComboBoxDelegate.new(self, Speciality, :title)
    @CourseComboBoxDelegate = ARComboBoxDelegate.new(self, Course, :number)
    @view.setItemDelegateForColumn(1, @SpecialityComboBoxDelegate)
    @view.setItemDelegateForColumn(2, @CourseComboBoxDelegate)
  end

  def refresh
    @groups = Group.all
    @SpecialityComboBoxDelegate.setup
    @CourseComboBoxDelegate.setup
    emit layoutChanged()
  end

  def rowCount(parent)
    @groups.size
  end

  def columnCount(parent)
    4
  end

  def data(index, role = Qt::DisplayRole)
    group = @groups[index.row]
    default = Qt::Variant.new
    case role
    when Qt::DisplayRole
      case index.column
      when 0
        group.title
      when 1
        group.speciality.try(:title)
      when 2
        group.course.try(:number)
      when 3
        group.emails.map(&:email).join(', ')
      else
        raise "invalid column #{index.column}"
      end.try(:to_v) || default
    when Qt::EditRole
      case index.column
      when 0
        group.title
      when 1
        group.speciality_id
      when 2
        group.course_id
      when 3
        group.emails.map(&:email).join(', ')
      else
        raise "invalid column #{index.column}"
      end.try(:to_v) || default
    else
      default
    end
  end

  def headerData(section, orientation, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole
    v = case orientation
        when Qt::Horizontal
          %w(Название Специальность Курс Email)[section]
        else
          ''
        end
    Qt::Variant.new(v)
  end

  def flags(index)
    Qt::ItemIsEditable | super(index)
  end

  def setData(index, variant, role = Qt::EditRole)
    if index.valid? and role == Qt::EditRole
      group = @groups[index.row]
      case index.column
      when 0
        group.title = variant.toString.force_encoding('UTF-8')
      when 1
        group.speciality_id = variant.toInt
      when 2
        group.course_id = variant.toInt
      when 3
        emails = variant.toString.force_encoding('UTF-8').split(/,\s*/)
        group.emails.destroy_all
        emails.each do |email|
          group.emails.create(email: email)
        end
      else
        raise "invalid column #{index.column}"
      end
      group.save
      p group
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    new_group = Group.new
    @groups.prepend(new_group)
    (1..2).map{ |i| Subgroup.create(group: new_group, number: i) }
    emit layoutChanged()
  end

  def remove_current
    if @view.currentIndex.valid?
      @groups[@view.currentIndex.row].try(:destroy)
      @groups.delete_at(@view.currentIndex.row)
      emit layoutChanged()
      @view.currentIndex = createIndex(-1, -1)
    end
  end

end
