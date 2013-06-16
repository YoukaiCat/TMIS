# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/import/timetable_reader'
require_relative '../../src/engine/import/spreadsheet_roo'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe TimetableReader do
  before(:all) do
    @sheet = SpreadsheetCreater.create("./spec/import/test_data/raspisanie_2013.csv")
  end

  it "mustn't raise exception" do
    expect { TimetableReader.new(@sheet, 1) }.to_not raise_error
  end

  it 'must raise exception' do
    expect { TimetableReader.new(@sheet, 0) }.to raise_error
  end

  it 'must parse info right' do
    TimetableReader.new(@sheet, 1).parse_info(nil).should eq(nil)
    TimetableReader.new(@sheet, 1).parse_info('').should eq(nil)
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   Куплинова Е.Д.')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'Куплинова', name: 'Е', patronymic: 'Д' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   Куплинова Е.Д')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'Куплинова', name: 'Е', patronymic: 'Д' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ Куплинова Е.Д.')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'Куплинова', name: 'Е', patronymic: 'Д' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   Куплинова')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'Куплинова', name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ Куплинова')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'Куплинова', name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('История    Гурин Ю.Г.')
    res.should eq({ subject: 'История', lecturer: { surname: 'Гурин', name: 'Ю', patronymic: 'Г' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В(1п)')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В.(1п)')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В. (1п)')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В. 1п)')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В. 1п')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В. 1 п')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В.(1п')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В. (1п)')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В.1п)')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В.1п')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В.1 п')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info('Иностранный язык     Фролова О.В. (1п')
    res.should eq({ subject: 'Иностранный язык', lecturer: { surname: 'Фролова', name: 'О', patronymic: 'В' }, subgroup: '1' })
    res = TimetableReader.new(@sheet, 1).parse_info("Физическая культура \n  Сушенкова В.В.(2п)")
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: 'Сушенкова', name: 'В', patronymic: 'В' }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info("Физическая культура \nСушенкова В.В.(2п)")
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: 'Сушенкова', name: 'В', patronymic: 'В' }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info("Физическая культура\nСушенкова В.В.(2п)")
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: 'Сушенкова', name: 'В', patronymic: 'В' }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info("Физическая культура\n Сушенкова В.В.(2п)")
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: 'Сушенкова', name: 'В', patronymic: 'В' }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Физическая культура')
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: nil, name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('День проектных разработок')
    res.should eq({ subject: 'День проектных разработок', lecturer: { surname: nil, name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info(' День проектных разработок')
    res.should eq({ subject: 'День проектных разработок', lecturer: { surname: nil, name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('День проектных разработок ')
    res.should eq({ subject: 'День проектных разработок', lecturer: { surname: nil, name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info(' Химия   Байракова А.Л. ')
    res.should eq({ subject: 'Химия', lecturer: { surname: 'Байракова', name: 'А', patronymic: 'Л' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Химия   Байракова А.Л. ')
    res.should eq({ subject: 'Химия', lecturer: { surname: 'Байракова', name: 'А', patronymic: 'Л' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info(' Химия   Байракова А.Л.')
    res.should eq({ subject: 'Химия', lecturer: { surname: 'Байракова', name: 'А', patronymic: 'Л' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('ОБЖ   вакансия')
    res.should eq({ subject: 'ОБЖ', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Технология и организация турооператорской деятельности Ефремова Н.К.')
    res.should eq({ subject: 'Технология и организация турооператорской деятельности', lecturer: { surname: 'Ефремова', name: 'Н', patronymic: 'К' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Физическая культура  вакансия.(2п)')
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Физическая культура  вакансия. (2п)')
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Физическая культура  вакансия . (2п)')
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Физическая культура  вакансия .(2п)')
    res.should eq({ subject: 'Физическая культура', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('РиЭАИС  вакансия(2)')
    res.should eq({ subject: 'РиЭАИС', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   вакансия (2п)')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   вакансия(2п)')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   вакансия')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ вакансия')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Сетевые операционные системы (Технология Cisco) Белик А.И.')
    res.should eq({ subject: 'Сетевые операционные системы Технология Cisco', lecturer: { surname: 'Белик', name: 'А', patronymic: 'И' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Стратегирование в П.Д. Климович С.В.')
    res.should eq({ subject: 'Стратегирование в П Д', lecturer: { surname: 'Климович', name: 'С', patronymic: 'В' }, subgroup: nil })
  end
end
