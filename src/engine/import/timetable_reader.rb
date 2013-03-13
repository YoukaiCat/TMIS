# coding: UTF-8

class TimetableReader

  def initialize(spreadsheet, week_name=:even)
    @table = spreadsheet
    week(week_name)
  end

  def week(name)
    case name
    when :even
      @table.sheet(4); self
    when :odd
      @table.sheet(3); self
    else
      raise 'No such week'
    end
  end

  def groups
    (3..@table.last_column).each_slice(2).map do |cols|
      { title: @table[7, cols.first], days: get_days(cols) }
    end
  end

private

  def get_days(cols)
    (7..84).each_slice(13).map{ |i| [i[1], i.last] }.map do |rows|
      { name: @table[rows.first, 1], studies: get_studies(rows, cols) }
    end
  end

  def get_studies(rows, cols)
    (rows.first..rows.last).each_slice(2).map do |study_rows|
      study_rows.map do |row|
        { info: parse_info(@table[row, cols.first]), cabinet: @table[row, cols.last] }
      end.reject{ |s| s[:info].nil? }
    end
  end

  def parse_info(info)
    unless info.nil?
      info[/(.*)\s{2,}(([[:alpha:]]+)\s+([[:alpha:]]).\s?([[:alpha:]])|вакансия)/i]
      if $1 && $2 && $3 && $4
        { subject: ($1.strip!), lecturer: { surname: $3, name: $4, patronymic: $5 } }
      end
    end
  end

end
