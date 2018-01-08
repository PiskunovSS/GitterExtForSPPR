﻿
#Область ВерсииХранилища

Процедура ЗагрузитьНовыеВерсии( Знач Хранилище ) Экспорт
	
	ОбщийГитКлиентСервер.ЛогОтладка( "--Загрузка новых версий " + Хранилище + "--" );
	
	НомерПоследнейВерсииВХранилище = Справочники.Хранилища.ПолучитьНомерПоследнейВерсии( Хранилище );
	
	Если Хранилище.ПослеВосстановления Тогда
		
		НомерПоследнейВерсииВХранилище = НомерПоследнейВерсииВХранилище - Хранилище.ПотеряноВерсий;
		
	КонецЕсли;
	
	РеквизитыХранилищаСППР = ПараметрыХранилища1С( Хранилище );//+СППР
	РеквизитыТранзитнойБазы = ПараметрыТранзитнойБазы( Хранилище );//+СППР
	ТаблицаВерсий = ПакетныйРежим.ПолучитьТаблицуВерсийХранилища( Хранилище,
																  ОбщийГитКлиентСервер.ПолучитьПриложение1С(),
																  РеквизитыТранзитнойБазы.ТранзитнаяБазаАдрес,
																  РеквизитыТранзитнойБазы.ТранзитнаяБазаПользователь,
																  РеквизитыТранзитнойБазы.ТранзитнаяБазаПароль,
																  РеквизитыХранилищаСППР.ХранилищеАдрес,
																  РеквизитыХранилищаСППР.ХранилищеПользователь,
																  РеквизитыХранилищаСППР.ХранилищеПароль,
																  НомерПоследнейВерсииВХранилище + 1 );
	
	Для Каждого ТекущаяСтрока Из ТаблицаВерсий Цикл
		
		НоваяВерсия = Справочники.ВерсииКонфигурацийХранилища.СоздатьЭлемент();
		НомерВерсии = ТекущаяСтрока.НомерВерсии;
		
		Если Хранилище.ПослеВосстановления Тогда
			
			НомерВерсии = НомерВерсии + Хранилище.ПотеряноВерсий;
			
		КонецЕсли;
		
		структПользователи = Справочники.ПользователиХранилища.ПараметрыПользователя( ТекущаяСтрока.ИмяПользователя, Хранилище );
		
		Если Не ЗначениеЗаполнено( структПользователи.Ссылка ) Тогда
			
			шаблонТекста   = НСтр( "ru='Для пользователя %1 не указаны параметры'" );
			текстСообщения = СтрШаблон( шаблонТекста, ТекущаяСтрока.ИмяПользователя );
			
			ВызватьИсключение текстСообщения;
			
		КонецЕсли;
		
		НоваяВерсия.Код          = НомерВерсии;
		НоваяВерсия.Владелец     = Хранилище;
		НоваяВерсия.Пользователь = структПользователи.Ссылка;
		НоваяВерсия.ДатаСоздания = ТекущаяСтрока.ДатаСоздания;
		НоваяВерсия.Комментарий  = ТекущаяСтрока.Комментарий;
		НоваяВерсия.Записать();
		
		Сообщить( " +" + НомерВерсии + ". " + НоваяВерсия.Пользователь + ": " + НоваяВерсия.Комментарий );
		
		Если Хранилище.ВыгруженАктуальныйCF Тогда
			
			об = Хранилище.ПолучитьОбъект();
			об.ВыгруженАктуальныйCF = Ложь;
			об.Записать();
			
		КонецЕсли;
		
	КонецЦикла;
	
	ОбщийГитКлиентСервер.ЛогОтладка( "++Загрузка новых версий " + Хранилище + "++" );
	
КонецПроцедуры

Функция ПолучитьНомерПоследнейВерсии( Знач Хранилище ) Экспорт
	
	НомерПоследнейВерсии = 0;
	
	Запрос       = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
		|	ВерсииКонфигурацийХранилища.Код КАК НомерВерсии
		|ИЗ
		|	Справочник.ВерсииКонфигурацийХранилища КАК ВерсииКонфигурацийХранилища
		|ГДЕ
		|	ВерсииКонфигурацийХранилища.Владелец = &Хранилище
		|
		|УПОРЯДОЧИТЬ ПО
		|	ВерсииКонфигурацийХранилища.Код УБЫВ";
	Запрос.УстановитьПараметр( "Хранилище", Хранилище );
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		
		НомерПоследнейВерсии = Выборка.НомерВерсии;
		
	КонецЕсли;
	
	Возврат НомерПоследнейВерсии;
	
КонецФункции

Функция ЭтоПоследняяНевыгруженнаяВерсия( Знач пТекущаяВыгружаемаяВерсия )
	
	Запрос       = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
		|	ВерсииКонфигурацийХранилища.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ВерсииКонфигурацийХранилища КАК ВерсииКонфигурацийХранилища
		|ГДЕ
		|	ВерсииКонфигурацийХранилища.Владелец = &Владелец
		|	И НЕ ВерсииКонфигурацийХранилища.ВыгруженаВЛокальныйРепозиторий
		|	И ВерсииКонфигурацийХранилища.Код > ВерсииКонфигурацийХранилища.Владелец.МинимальнаяВерсияДляВыгрузки
		|	И ВерсииКонфигурацийХранилища.Ссылка <> &ТекущаяВыгружаемаяВерсия";
	Запрос.УстановитьПараметр( "Владелец", пТекущаяВыгружаемаяВерсия.Владелец );
	Запрос.УстановитьПараметр( "ТекущаяВыгружаемаяВерсия", пТекущаяВыгружаемаяВерсия );
	
	Возврат Запрос.Выполнить().Пустой();
	
КонецФункции

Процедура УстановитьПризнакВыгруженностиВерсииВЛокальныйРепозиторий( Знач Версия )
	
	ВерсияОбъект = Версия.ПолучитьОбъект();
	ВерсияОбъект.ВыгруженаВЛокальныйРепозиторий = Истина;
	ВерсияОбъект.Записать();
	
КонецПроцедуры

Процедура УстановитьВерсиюВВерсию( Знач Версия )
	
	ВерсияОбъект = Версия.ПолучитьОбъект();
	ВерсияОбъект.ВерсияКонфигурации = ОпределитьВерсиюКонфигурации( Версия.Владелец );
	ВерсияОбъект.Записать();
	
КонецПроцедуры

Функция ОпределитьВерсиюКонфигурации( Знач пХранилище )
	
	каталог = ПолучитьКаталогКонфигурации( пХранилище );
	
	файлКонфигурации = каталог + "\Configuration.xml";
	
	Если Не ОбщийГитКлиентСервер.ФайлСуществует( файлКонфигурации ) Тогда
		
		Возврат Неопределено;
	
	КонецЕсли;
	
	чтениеXML = Новый ЧтениеXML;
	
	чтениеXML.ОткрытьФайл( файлКонфигурации );
	
	ВерсияКонфигурации = Неопределено;
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента
			И ВРег( ЧтениеXML.Имя ) = ВРег( "Version" ) Тогда
			
			Если Не ЧтениеXML.Прочитать() Тогда
				
				Продолжить;
				
			КонецЕсли;
			
			Если Не ЧтениеXML.ТипУзла = ТипУзлаXML.Текст Тогда
				
				Продолжить;
				
			КонецЕсли;
			
			ВерсияКонфигурации = ЧтениеXML.Значение;
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЧтениеXML.Закрыть();
	
	Возврат ВерсияКонфигурации;
	
КонецФункции

Процедура УстановитьНовуюВерсиюКонфигурации( Знач Хранилище, ВерсияКонфигурации )
	
	Если Хранилище.ТекущаяВерсияКонфигурации = ВерсияКонфигурации Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено( Хранилище.СкриптПриСменеВерсии ) Тогда
		
		началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
		
		ОбщийГитКлиентСервер.ЛогОтладка( "--Начало выполнения скрипта при смене версии на " + ВерсияКонфигурации + "--" );
		
		командаСкрипта = Вычислить( Хранилище.СкриптПриСменеВерсии );
		
		командныйФайл = ПолучитьИмяВременногоФайла( "bat" );
		
		записьТекста = Новый ЗаписьТекста( командныйФайл, "cp866" );
		//записьТекста.ЗаписатьСтроку( "set path=C:\Program Files\Git\cmd;%path%" );//!!!Удалить после рестарта сервера
		записьТекста.ЗаписатьСтроку( командаСкрипта );
		записьТекста.Закрыть();
		
		КодВозврата = ОбщийГитКлиентСервер.ВыполнитьКомандныйФайл( Хранилище.ЛокальныйРепозиторийАдрес, командныйФайл );
		
		УдалитьФайлы( командныйФайл );
		
		Если КодВозврата <> 0 Тогда
			
			ОписаниеОшибки = "При выполнении скрипта на смену версии произошла ошибка";
			ВызватьИсключение ОписаниеОшибки + "(" + командаСкрипта + ")";
			
		КонецЕсли;
		
		затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузки;
		
		ОбщийГитКлиентСервер.логИнформация( "Выполнен скрипт при смене версии на " + ВерсияКонфигурации + ". " + затрачено + "мс" );
		
	КонецЕсли;
	
	об = Хранилище.ПолучитьОбъект();
	об.ТекущаяВерсияКонфигурации = ВерсияКонфигурации;
	об.Записать();
	
КонецПроцедуры

#КонецОбласти

#Область Выгрузка

Процедура ВыгрузитьВерсииВЛокальныйРепозиторий( Знач Хранилище, КоличествоВерсийВыгружаемыхЗаРаз = 0 ) Экспорт
	
	ОбщийГитКлиентСервер.ЛогОтладка( "--Выгрузка версий в локальный репозиторий " + Хранилище + "--" );
	
	ТекстЗапроса = "ВЫБРАТЬ ПЕРВЫЕ 1
		|	Версии.Ссылка КАК Версия,
		|	Версии.Код КАК НомерВерсии,
		|	Версии.ДатаСоздания КАК ДатаСоздания,
		|	Версии.Комментарий КАК Комментарий,
		|	Версии.Пользователь,
		|	Версии.Владелец.ЛокальныйРепозиторийАдрес КАК ЛокальныйРепозиторийАдрес,
		|	Версии.Владелец.ВыгружатьВУдаленныйРепозиторий КАК ВыгружатьВУдаленныйРепозиторий,
		|	Версии.Пользователь.УчетнаяЗапись.СкриптДляPush КАК СкриптДляPush,
		|	Версии.Пользователь.УчетнаяЗапись.СкриптДляPush.хзДвоичныеДанные КАК ХранилищеДвоичныхДанныхСкрипта,
		|	Версии.Пользователь.УчетнаяЗапись.СкриптДляPush.Наименование КАК ИмяСкрипта,
		|	Версии.Пользователь.УчетнаяЗапись КАК УчетнаяЗапись
		|ИЗ
		|	Справочник.ВерсииКонфигурацийХранилища КАК Версии
		|ГДЕ
		|	Версии.Владелец = &Хранилище
		|	И НЕ Версии.ВыгруженаВЛокальныйРепозиторий
		|	И Версии.Владелец.МинимальнаяВерсияДляВыгрузки <= Версии.Код
		|
		|УПОРЯДОЧИТЬ ПО
		|	Версии.Код";
	
	Если ЗначениеЗаполнено( КоличествоВерсийВыгружаемыхЗаРаз ) Тогда
		
		ТекстЗапроса = СтрЗаменить( ТекстЗапроса,
									"ПЕРВЫЕ 1",
									"ПЕРВЫЕ " + Формат( КоличествоВерсийВыгружаемыхЗаРаз, "ЧГ=0" ) );
		
	Иначе
		
		ТекстЗапроса = СтрЗаменить( ТекстЗапроса, "ПЕРВЫЕ 1", "" );
		
	КонецЕсли;
	
	Запрос = Новый Запрос( ТекстЗапроса );
	Запрос.УстановитьПараметр( "Хранилище", Хранилище );
	
	результатЗапроса = Запрос.Выполнить();
	
	Если результатЗапроса.Пустой() Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Выборка = результатЗапроса.Выбрать();
	
	Попытка
		
		РегистрыСведений.СтатусыВыгрузки.Выгружается( Хранилище );
		
		текУчетка = Неопределено;
		
		Пока Выборка.Следующий() Цикл
			
			Если Не текУчетка = Неопределено
				И Не текУчетка = выборка.УчетнаяЗапись
				И выборка.ВыгружатьВУдаленныйРепозиторий
				И ЗначениеЗаполнено( выборка.СкриптДляPush ) Тогда
				
				ВыгрузитьВУдаленныйРепозиторийПроизвольнымСкриптом( выборка, Хранилище );
				
			КонецЕсли;
			
			ВыгрузитьВерсию( Выборка, Хранилище );
			
			текУчетка = выборка.УчетнаяЗапись;
			
		КонецЦикла;
		
		ОбщийГитКлиентСервер.ЛогОтладка( "++Выгрузка версий в локальный репозиторий++" );
		
		РегистрыСведений.СтатусыВыгрузки.Выгружено( Хранилище );
		
	Исключение
		
		подробноеОписаниеОшибки = ПодробноеПредставлениеОшибки( ИнформацияОбОшибке() );
		
		РегистрыСведений.СтатусыВыгрузки.ЗавершеноСОшибками( Хранилище, подробноеОписаниеОшибки );
		
		ОбщийГитКлиентСервер.логОшибка( подробноеОписаниеОшибки );
		
	КонецПопытки;
	
	ОбслужитьРепозиторий( Хранилище );
	
КонецПроцедуры

Процедура ВыгрузитьВерсию( Знач пДанные, Знач пХранилище )
	
	#Если Клиент Тогда
	
	ОбработкаПрерыванияПользователя();
	
	#КонецЕсли
	
	НомерВерсииВХранилище = пДанные.НомерВерсии;
	
	Если пХранилище.ПослеВосстановления Тогда
		
		НомерВерсииВХранилище = НомерВерсииВХранилище - пХранилище.ПотеряноВерсий;
		
	КонецЕсли;
	
	каталогКонфигурации = ПолучитьКаталогКонфигурации( пХранилище );
	
	началоВыгрузкиОбщая = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ОбщийГитКлиентСервер.ЛогИнформация( "Версия: " + НомерВерсииВХранилище + ", " + пДанные.Пользователь + ": " + пДанные.Комментарий );
	
	началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ОбщийГитКлиентСервер.ЛогОтладка( "Загрузка из хранилища версии " + НомерВерсииВХранилище );
	
	РеквизитыХранилищаСППР = ПараметрыХранилища1С( пХранилище );//+СППР
	РеквизитыТранзитнойБазы = ПараметрыТранзитнойБазы( пХранилище );//+СППР
	ПакетныйРежим.ЗагрузитьКонфигурациюИзХранилища( пХранилище,
													ОбщийГитКлиентСервер.ПолучитьПриложение1С(  ),
													РеквизитыТранзитнойБазы.ТранзитнаяБазаАдрес,
													РеквизитыТранзитнойБазы.ТранзитнаяБазаПользователь,
													РеквизитыТранзитнойБазы.ТранзитнаяБазаПароль,
													РеквизитыХранилищаСППР.ХранилищеАдрес,
													РеквизитыХранилищаСППР.ХранилищеПользователь,
													РеквизитыХранилищаСППР.ХранилищеПароль,
													НомерВерсииВХранилище );
	
	затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузки;
	ОбщийГитКлиентСервер.ЛогОтладка( "Выгружена " + НомерВерсииВХранилище + ". " + затрачено + "мс" );
	
	ПакетныйРежим.ВыгрузитьКонфигурациюВФайлы( пХранилище,
											   ОбщийГитКлиентСервер.ПолучитьПриложение1С(  ),
											   РеквизитыТранзитнойБазы.ТранзитнаяБазаАдрес,
											   РеквизитыТранзитнойБазы.ТранзитнаяБазаПользователь,
											   РеквизитыТранзитнойБазы.ТранзитнаяБазаПароль,
											   каталогКонфигурации );
	
	затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузки;
	ОбщийГитКлиентСервер.ЛогОтладка( "Выгружены файлы. " + затрачено + "мс" );
	
	РаспаковатьОбычныеФормы( каталогКонфигурации, пХранилище );
	
	УстановитьВерсиюВВерсию( пДанные.Версия );
	
	ВыгрузитьАктуальныйCF( пХранилище, пДанные.Версия ); // Выгружаем cf до коммита, т.к. cf может выгружаться как раз в репо
	УстановитьНовуюВерсиюКонфигурации( пХранилище, пДанные.Версия.ВерсияКонфигурации ); // Аналогично скрипт при смене запускает до коммита
	
	ОбщийГитКлиентСервер.ЛогОтладка( "Включение отслеживания и коммит" );
	
	Git.ВыполнитьИндексированиеИКоммит( пХранилище.ЛокальныйРепозиторийАдрес, пДанные, пХранилище );
	Git.СохранитьСписокИзменений( пХранилище.ЛокальныйРепозиторийАдрес, пХранилище, пДанные.Версия );
	
	УстановитьПризнакВыгруженностиВерсииВЛокальныйРепозиторий( пДанные.Версия );
	
	затраченоВсего = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузкиОбщая;
	ОбщийГитКлиентСервер.логИнформация( "Обработана версия " + НомерВерсииВХранилище + ". " + затраченоВсего + "мс" );
	
КонецПроцедуры

Процедура ВыгрузитьАктуальныйCF( Знач Хранилище, Знач пТекущаяВыгружаемаяВерсия ) Экспорт
	
	началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ОбщийГитКлиентСервер.ЛогОтладка( "---Выгрузка актуального cf " + Хранилище + "---" );
	
	Если Хранилище.ВыгруженАктуальныйCF Тогда
		
		ОбщийГитКлиентСервер.ЛогОтладка( "+++Актуальный cf " + Хранилище + " уже выгружен+++" );
		
		Возврат;
	
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено( Хранилище.ПутьКАктуальномуCF ) Тогда
		
		ОбщийГитКлиентСервер.ЛогОтладка( "+++Путь к актуальному cf " + Хранилище + " не указан. Выгрузка отменена+++" );
		
		Возврат;
	
	КонецЕсли;
	
	Если Не ЭтоПоследняяНевыгруженнаяВерсия( пТекущаяВыгружаемаяВерсия ) Тогда
		
		ОбщийГитКлиентСервер.ЛогОтладка( "+++Есть невыгруженные версии " + Хранилище + ". Выгрузка отменена+++" );
		
		Возврат;
	
	КонецЕсли;
	
	РеквизитыТранзитнойБазы = ПараметрыТранзитнойБазы( Хранилище );//+СППР
	ПакетныйРежим.ВыгрузитьКонфигурациюВCF( Хранилище,
											ОбщийГитКлиентСервер.ПолучитьПриложение1С(  ),
											РеквизитыТранзитнойБазы.ТранзитнаяБазаАдрес,
											РеквизитыТранзитнойБазы.ТранзитнаяБазаПользователь,
											РеквизитыТранзитнойБазы.ТранзитнаяБазаПароль,
											Хранилище.ПутьКАктуальномуCF );
	
	об = Хранилище.ПолучитьОбъект();
	об.ВыгруженАктуальныйCF = Истина;
	об.Записать();
	
	затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузки;
	ОбщийГитКлиентСервер.ЛогИнформация( "+++Выгружен актуальный cf. " + затрачено + "мс  +++" );
	
КонецПроцедуры

Процедура РаспаковатьОбычныеФормы( Знач каталогКонфигурации, Знач Хранилище )
	
	Если Не ( Хранилище.РаспаковыватьОбычныеФормы ) Тогда
		
		Возврат;
	
	КонецЕсли;
	
	файлРаспаковщика = Константы.ПрограммаРаспаковки.Получить();
	
	Если Не ОбщийГитКлиентСервер.ФайлСуществует( файлРаспаковщика ) Тогда
		
		ВызватьИсключение "Файл распаковщика не найден по пути " + файлРаспаковщика;
		
	КонецЕсли;
	
	началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ОбщийГитКлиентСервер.ЛогОтладка( "		Начало распаковки обычных форм." );
	
	формыКРаспаковке = НайтиФайлы( каталогКонфигурации, "form.bin", Истина );
	
	ОбщийГитКлиентСервер.ЛогОтладка( "		Форм к распаковке: " + формыКРаспаковке.Количество() );
	
	ц = 0;
	
	Для каждого цФайл Из формыКРаспаковке Цикл
		
		ц = ц + 1;
		
		каталогРаспаковки = СтрЗаменить( цФайл.ПолноеИмя, "\Ext\Form.bin", "" );
		СтрокаЗапуска     = """" + файлРаспаковщика + """ -parse """ + цФайл.ПолноеИмя + """ """ + каталогРаспаковки + """";
		
		ОбщийГитКлиентСервер.ВыполнитьКоманду( каталогКонфигурации, СтрокаЗапуска, , Истина );
		
		Попытка
			УдалитьФайлы( каталогРаспаковки + "\Form" );
		Исключение
			КонецПопытки;
		
		Попытка
			ПереместитьФайл( каталогРаспаковки + "\module", каталогРаспаковки + "\module.bsl" );
		Исключение
			КонецПопытки;
		
		Попытка
			УдалитьФайлы( цФайл.ПолноеИмя );
		Исключение
			КонецПопытки;
		
		Если ц%100 = 0 Тогда
			
			ОбщийГитКлиентСервер.ЛогОтладка( "		Распаковано форм: " + ц );
			
		КонецЕсли;
		
	КонецЦикла;
	
	затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузки;
	ОбщийГитКлиентСервер.ЛогОтладка( "		Завершена распаковка обычных форм. " + затрачено + "мс" );
	
КонецПроцедуры

#КонецОбласти

#Область Команды1С

Процедура ЗагрузитьПользователейХранилища( Хранилище ) Экспорт
	
	РеквизитыХранилищаСППР = ПараметрыХранилища1С( Хранилище );//+СППР
	РеквизитыТранзитнойБазы = ПараметрыТранзитнойБазы( Хранилище );//+СППР
	ТаблицаВерсий = ПакетныйРежим.ПолучитьТаблицуВерсийХранилища( Хранилище,
																  ОбщийГитКлиентСервер.ПолучитьПриложение1С(  ),
																  РеквизитыТранзитнойБазы.ТранзитнаяБазаАдрес,
																  РеквизитыТранзитнойБазы.ТранзитнаяБазаПользователь,
																  РеквизитыТранзитнойБазы.ТранзитнаяБазаПароль,
																  РеквизитыХранилищаСППР.ХранилищеАдрес,
																  РеквизитыХранилищаСППР.ХранилищеПользователь,
																  РеквизитыХранилищаСППР.ХранилищеПароль );
	
	ТаблицаВерсий.Свернуть( "ИмяПользователя" );
	
	Для Каждого ТекущаяСтрока Из ТаблицаВерсий Цикл
		
		НайденныйПользователь = Справочники.ПользователиХранилища.НайтиПоНаименованию( ТекущаяСтрока.ИмяПользователя,
																					   Истина,
																					   ,
																					   Хранилище );
		
		Если Не ЗначениеЗаполнено( НайденныйПользователь ) Тогда
			
			НовыйПользователь = Справочники.ПользователиХранилища.СоздатьЭлемент();
			НовыйПользователь.Владелец     = Хранилище;
			НовыйПользователь.Наименование = ТекущаяСтрока.ИмяПользователя;
			НовыйПользователь.Записать();
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область КомандыГит

Процедура ОбслужитьРепозиторий( Хранилище ) Экспорт
	
	Сообщить( "" + ТекущаяДата() + "  --Обслуживание " + Хранилище + "--" );
	
	Git.Обслужить( Хранилище.ЛокальныйРепозиторийАдрес );
	
	Сообщить( "" + ТекущаяДата() + "  ++Выполнено обслуживание " + Хранилище + "++" );
	
КонецПроцедуры

Процедура ВыгрузитьВерсииВУдаленныйРепозиторий( Знач Хранилище ) Экспорт
	
	Запрос       = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
		|	Хранилища.УчетнаяЗаписьДляPush.СкриптДляPush КАК СкриптДляPush,
		|	Хранилища.ВыгружатьВУдаленныйРепозиторий,
		|	Хранилища.УчетнаяЗаписьДляPush.СкриптДляPush.хзДвоичныеДанные КАК ХранилищеДвоичныхДанныхСкрипта,
		|	Хранилища.ЛокальныйРепозиторийАдрес,
		|	Хранилища.УчетнаяЗаписьДляPush.СкриптДляPush.Наименование КАК ИмяСкрипта
		|ИЗ
		|	Справочник.Хранилища КАК Хранилища
		|ГДЕ
		|	Хранилища.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр( "Ссылка", Хранилище );
	
	выборка = Запрос.Выполнить().Выбрать();
	
	Если Не выборка.Следующий() Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если Не выборка.ВыгружатьВУдаленныйРепозиторий Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено( выборка.СкриптДляPush ) Тогда
		
		ВыгрузитьВУдаленныйРепозиторийПроизвольнымСкриптом( выборка, Хранилище );
		
	Иначе
		
		Сообщить( "" + ТекущаяДата() + "  --Начало выгрузки в удаленный репозиторий " + Хранилище + "--" );
		
		Git.Push( выборка.ЛокальныйРепозиторийАдрес );
		
		Сообщить( "" + ТекущаяДата() + "  ++Конец выгрузки в удаленный репозиторий " + Хранилище + "++" );
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыгрузитьВУдаленныйРепозиторийПроизвольнымСкриптом( Знач пДанные, Знач пХранилище )
	
	Сообщить( "" + ТекущаяДата() + "  --Начало выполнения произвольного скрипта для выгрузки в удаленный репозиторий " + пХранилище + "--" );
	
	времКаталог = ЗавершитьРазделителемПутьДоКаталога( пДанные.ЛокальныйРепозиторийАдрес );
	времКаталог = времКаталог + ".tmp";
	
	ОбщийГитКлиентСервер.ОбеспечитьКаталог( времКаталог );
	
	скрипт = ЗавершитьРазделителемПутьДоКаталога( времКаталог ) + пДанные.ИмяСкрипта;
	
	пДанные.ХранилищеДвоичныхДанныхСкрипта.Получить().Записать( скрипт );
	
	файлВыводаСкрипта = скрипт + ".out";
	
	командаЗапуска = """%1"" ""%2"" ""%3""";
	командаЗапуска = СтрШаблон( командаЗапуска,
								скрипт,
								пДанные.ЛокальныйРепозиторийАдрес,
								файлВыводаСкрипта );
	
	ОбщийГитКлиентСервер.ВыполнитьКоманду( пДанные.ЛокальныйРепозиторийАдрес, командаЗапуска );
	
	ОбщийГитКлиентСервер.ЛогВыводКомандыИзФайла( файлВыводаСкрипта );
	
	УдалитьФайлы( скрипт );
	
	Сообщить( "" + ТекущаяДата() + "  ++Конец выполнения произвольного скрипта для выгрузки в удаленный репозиторий " + пХранилище + "++" );
	
КонецПроцедуры

Процедура ЗагрузитьИзмененияИзУдаленногоРепозитория( Хранилище ) Экспорт
	
	Если Хранилище.ВыгружатьВУдаленныйРепозиторий Тогда
		
		ОбщийГитКлиентСервер.ЛогОтладка( "--Получение изменений из удаленного репозитория " + Хранилище + "--" );
		
		Git.Pull( Хранилище.ЛокальныйРепозиторийАдрес );
		
		ОбщийГитКлиентСервер.ЛогОтладка( "++Получение изменений из удаленного репозитория " + Хранилище + "++" );
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ИнициироватьЛокальныйРепозиторий( Хранилище ) Экспорт
	
	ОбщийГитКлиентСервер.ОбеспечитьКаталог( Хранилище.ЛокальныйРепозиторийАдрес );
	
	Git.ИнициироватьЛокальныйРепозиторий( Хранилище.ЛокальныйРепозиторийАдрес );
	СоздатьКаталог( ПолучитьКаталогКонфигурации( Хранилище ) );
	
	Если Хранилище.ВыгружатьВУдаленныйРепозиторий Тогда
		
		Git.ДобавитьУдаленныйРепозиторий( Хранилище.ЛокальныйРепозиторийАдрес, Хранилище.УдаленныйРепозиторийАдрес );
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область Каталог

Функция ПолучитьКаталогКонфигурации( Знач Хранилище ) Экспорт
	
	каталогКонфигурации = ЗавершитьРазделителемПутьДоКаталога( Хранилище.ЛокальныйРепозиторийАдрес ) + ОтносительныйПутьККаталогуИсходныхКодов( Хранилище );
	
	ОбщийГитКлиентСервер.ОбеспечитьКаталог( каталогКонфигурации );
	
	каталог            = Новый Файл( каталогКонфигурации ); // Для обрезания всяких /../ и /./
	каталогРепозитория = Новый Файл( Хранилище.ЛокальныйРепозиторийАдрес );
	
	Если каталог.ПолноеИмя = каталогРепозитория.ПолноеИмя Тогда
		
		ВызватьИсключение НСтр( "ru='Каталог репозитория и каталог исходных кодов не могут совпадать. Это приведет к уничтожению папки .git'" );
		
	КонецЕсли;
	
	Возврат ЗавершитьРазделителемПутьДоКаталога( каталог.ПолноеИмя );
	
КонецФункции

Функция ОтносительныйПутьККаталогуИсходныхКодов( Знач Хранилище ) Экспорт
	
	адресИсходников = Хранилище.КаталогСИсходнымКодом;
	
	Если Не ЗначениеЗаполнено( адресИсходников ) Тогда
		
		адресИсходников = ПолучитьИмяКаталогаКонфигурации();
		
	КонецЕсли;
	
	Возврат ЗавершитьРазделителемПутьДоКаталога( адресИсходников );
	
КонецФункции // ОтносительныйПутьККаталогуИсходныхКодов()

Процедура УдалитьВсеФайлыВКаталоге( Знач Каталог ) Экспорт
	
	Каталог = ЗавершитьРазделителемПутьДоКаталога( Каталог );
	УдалитьФайлы( Каталог, "*" );
	
КонецПроцедуры

Функция ЗавершитьРазделителемПутьДоКаталога( Знач Каталог )
	
	РазделительПути = ПолучитьРазделительПути();
	
	Если Прав( Каталог, 1 ) <> РазделительПути Тогда
		
		Каталог = Каталог + РазделительПути;
		
	КонецЕсли;
	
	Возврат Каталог;
	
КонецФункции

#КонецОбласти

#Область ВолшебныеКонстанты

Функция ПолучитьИмяКаталогаКонфигурации() Экспорт
	
	Возврат "src";
	
КонецФункции

Функция ИмяФайлаИзменений( Знач Хранилище ) Экспорт
	
	каталог = ПолучитьКаталогКонфигурации( Хранилище );
	
	Возврат ЗавершитьРазделителемПутьДоКаталога( Каталог ) + "Changes.1c";
	
КонецФункции

#КонецОбласти

#Область РасширениеСППР

//Возвращает структуру с ключами: ХранилищеАдрес, ХранилищеПользователь, ХранилищеПароль 
// Данные подхватываются из Владельца: проекта или тех проекта СППР
Функция ПараметрыХранилища1С( Знач Хранилище )
	РеквизитыХранилища = Новый Структура;
	РеквизитыХранилища.Вставить("ХранилищеАдрес", "Владелец.КаталогХранилищаДляЗагрузкиМетаданных");
	РеквизитыХранилища.Вставить("ХранилищеПользователь", "Владелец.ИмяПользователяХранилищаДляЗагрузкиМетаданных");
	РеквизитыХранилища.Вставить("ХранилищеПароль", "Владелец.ПарольПользователяХранилищаДляЗагрузкиМетаданных");
	
	РеквизитыХранилища = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Хранилище, РеквизитыХранилища);
	
	Возврат РеквизитыХранилища;
КонецФункции

//Возвращает структуру с ключами: ТранзитнаяБазаАдрес, ТранзитнаяБазаПользователь, ТранзитнаяБазаПароль
//Если в настройках Хранилища установлен флаг "ИспользоватьПараметрыТранзитнойБазыПроекта", тогда эти данные берутся из Владельца
//Иначе - из самого справочника Хранилища
Функция ПараметрыТранзитнойБазы( Знач Хранилище ) Экспорт
	
	РеквизитыБазы = Новый Структура;
	РеквизитыБазы.Вставить( "ТранзитнаяБазаАдрес" );
	РеквизитыБазы.Вставить( "ТранзитнаяБазаПользователь" );
	РеквизитыБазы.Вставить( "ТранзитнаяБазаПароль" );
	РеквизитыБазы.Вставить( "ИспользоватьСобственнуюТранзитнуюБазу" );
	
	РеквизитыБазы = ОбщегоНазначения.ЗначенияРеквизитовОбъекта( Хранилище, РеквизитыБазы );
	
	Если РеквизитыБазы.ИспользоватьСобственнуюТранзитнуюБазу Тогда
		Возврат РеквизитыБазы;
	КонецЕсли;
	
	РеквизитыБазы = Новый Структура;
	РеквизитыБазы.Вставить( "ТранзитнаяБазаАдрес", "Владелец.КаталогИБДляЗагрузкиМетаданных" );
	РеквизитыБазы.Вставить( "ТранзитнаяБазаПользователь", "Владелец.ИмяПользователяИБДляЗагрузкиМетаданных" );
	РеквизитыБазы.Вставить( "ТранзитнаяБазаПароль", "Владелец.ПарольПользователяИБДляЗагрузкиМетаданных" );
	
	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта( Хранилище, РеквизитыБазы );
	
КонецФункции
 

#КонецОбласти