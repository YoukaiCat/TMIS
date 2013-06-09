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
    #when :cabinet_stubs
    #  cabinet_stubs
    #when :subject_stubs
    #  subject_stubs
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
end

# SELECT surname, count(surname)
# FROM "lecturers"
# group by surname
# having count(surname) > 1
# Lecturer.select('surname, count(surname)').group(:surname).having('count(surname) > 1')
# select lecturer_id, number, count(*) from studies where date = '2013-06-03' group by number, lecturer_id having count(*) > 1
