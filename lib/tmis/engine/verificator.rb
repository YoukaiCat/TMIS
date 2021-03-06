# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Verificator

  def initialize(dates)
    @dates = dates.to_a
  end

  def verify(verification)
    case verification
    when :lecturer_studies
      lecturer_studies
    when :cabinet_studies
      cabinet_studies
    when :lecturer_stubs
      lecturer_stubs
    when :cabinet_stubs
      cabinet_stubs
    when :subject_stubs
      subject_stubs
    when :group_and_subgroups
      group_and_subgroups
    when :preferred_days
      preferred_days
    when :computer_cabinets
      computer_cabinet
    else
      raise ArgumentError, 'No such verification'
    end
  end

private

  def lecturer_studies
    @dates.map do |date|
      Study.select('date, number, lecturer_id, count(*)').where(date: date).group('number, lecturer_id').having('count(*) > 1')
    end.flatten.map{|x| Study.where(date: x.date, number: x.number, lecturer_id: x.lecturer_id )}.flatten.group_by{|x| [x.date, x.lecturer_id, x.number] }
    #@dates.map{ |date| Study.select('id, date, number, lecturer_id, count(*)').where(date: date).group('number, lecturer_id').having('count(*) > 1').to_a }
  end

  def cabinet_studies
    @dates.map do |date|
      Study.select('date, number, cabinet_id, count(*)').where(date: date).group('number, cabinet_id').having('count(*) > 1')
    end.flatten.map{|x| Study.where(date: x.date, number: x.number, cabinet_id: x.cabinet_id )}.flatten.group_by{|x| [x.date, x.cabinet_id, x.number] }
  end

  def lecturer_stubs
    @dates.map do |date|
      [date, Study.joins(:lecturer).where('lecturers.stub = ?', true).where(date: date)]
    end
  end

  def cabinet_stubs
    @dates.map do |date|
      [date, Study.joins(:cabinet).where('cabinets.stub = ?', true).where(date: date)]
    end
  end

  def subject_stubs
    @dates.map do |date|
      [date, Study.joins(:subject).where('subjects.stub = ?', true).where(date: date)]
    end
  end

  def computer_cabinet
    @dates.map do |date|
      [date, Study.joins(:cabinet).where(groupable_type: 'Subgroup').where("cabinets.with_computers = ?", false).where(date: date)]
    end
  end

  def preferred_days
    @dates.map do |date|
      #[date, Study.joins(:lecturer).where(date: date).where("NOT instr(preferred_days, strftime('%w', date))")] # doesn't work on windows
      #[date, Study.joins(:lecturer).where(date: date).where("NOT preferred_days like strftime('%w', date)")]
      [date, Lecturer.all.map do |l|
        if l.preferred_days
          l.studies.where(date: date).where("NOT strftime('%w', date) in (#{l.preferred_days.split(/,\s*/).map{|s| '\'' << s << '\''  }.join(',')})", ).to_a
        end
      end.flatten.compact]
    end
  end

  #- занятия для группы и подгруппы на одной паре
  #def group_and_subgroup
  #  @dates.map do |date|
  #    Study.select('date, number, groupable_type, count(*)').where(date: date).group('number, groupable_type').having('count(*) > 1')
  #  end.flatten.map{|x| Study.where(date: x.date, number: x.number, cabinet_id: x.cabinet_id )}.flatten.group_by{|x| [x.date, x.cabinet_id, x.number] }
  #end
end

# SELECT surname, count(surname)
# FROM "lecturers"
# group by surname
# having count(surname) > 1
# Lecturer.select('surname, count(surname)').group(:surname).having('count(surname) > 1')
# select lecturer_id, number, count(*) from studies where date = '2013-06-03' group by number, lecturer_id having count(*) > 1
