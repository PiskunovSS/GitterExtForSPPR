﻿
Процедура ЛогОтладка( Знач пТекст ) Экспорт
	
	Сообщить( "" + ТекущаяДата() + ". " + пТекст, СтатусСообщения.БезСтатуса );
	
КонецПроцедуры

Процедура ЛогИнформация( Знач пТекст ) Экспорт
	
	Сообщить( "" + ТекущаяДата() + ". " + пТекст, СтатусСообщения.Информация );
	
КонецПроцедуры

Процедура ЛогОшибка( Знач пТекст ) Экспорт
	
	Сообщить( "" + ТекущаяДата() + ". " + пТекст, СтатусСообщения.ОченьВажное );
	
КонецПроцедуры

Процедура ЛогКоманда( Знач пТекст ) Экспорт
	
	Сообщить( " > " + пТекст );
	
КонецПроцедуры

Процедура ЛогВыводКоманды( Знач пТекст ) Экспорт

	Сообщить( "		>> " + пТекст );

КонецПроцедуры

Процедура ЛогВыводКомандыИзФайла( имяФайлаВывода ) Экспорт
	
	Если Не ФайлСуществует( имяФайлаВывода ) Тогда
		
		Возврат;
	
	КонецЕсли;
	
	чтениеФайла = Новый ЧтениеТекста( имяФайлаВывода, КодировкаТекста.UTF8 );
	
	текСтрока = чтениеФайла.ПрочитатьСтроку();
	
	Пока текСтрока <> Неопределено Цикл
		
		ЛогВыводКоманды( текСтрока );
		
		текСтрока = чтениеФайла.ПрочитатьСтроку();
		
	КонецЦикла;
	
	чтениеФайла.Закрыть();
	
	УдалитьФайлы( имяФайлаВывода );
	
КонецПроцедуры


Функция ФайлСуществует( Знач пИмяФайла ) Экспорт
	
	Если Не ЗначениеЗаполнено( пИмяФайла ) Тогда
		
		Возврат Ложь;
	
	КонецЕсли;
	
	Файл = Новый Файл( пИмяФайла );
	
	Возврат Файл.Существует() И Файл.ЭтоФайл();
	
КонецФункции

Процедура ОбеспечитьТекстовыйФайл( Знач пИмяФайла ) Экспорт
	
	Если Не ЗначениеЗаполнено( пИмяФайла ) Тогда
		
		Возврат;
	
	КонецЕсли;
	
	Если Не ФайлСуществует( пИмяФайла ) Тогда
		
		записьФайла = Новый ЗаписьТекста( пИмяФайла );
		записьФайла.Закрыть();
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбеспечитьКаталог( Знач Путь ) Экспорт
	
	Объект = Новый Файл( Путь );
	
	Если Не Объект.Существует() Тогда
		
		СоздатьКаталог( Путь );
		
	ИначеЕсли НЕ Объект.ЭтоКаталог() Тогда
		
		ВызватьИсключение "Не удается создать каталог " + Путь + ". По данному пути уже существует файл.";
		
	КонецЕсли;
	
КонецПроцедуры

Функция Экранировать( Значение ) Экспорт
	
	Возврат СтрЗаменить( Значение, """", """""" );
	
КонецФункции


#Если Не ВебКлиент Тогда

Функция ВыполнитьКоманду( Знач пРабочийКаталог,
						  Знач ТекстКоманды,
						  Знач пОжидатьЗавершения = Истина,
						  Знач пПропуститьВыводЛога = Ложь ) Экспорт
	
	СтрокаЗапуска = "cmd.exe /c """ + ТекстКоманды + """";
	
	Если Не пПропуститьВыводЛога Тогда
		
		ФайлРезультата = Новый Файл( ПолучитьИмяВременногоФайла( "txt" ) );
		СтрокаЗапуска  = СтрокаЗапуска + " > """ + ФайлРезультата.ПолноеИмя + """";
		СтрокаЗапуска  = СтрокаЗапуска + " 2>&1"; //stderr
		
	КонецЕсли;
	
	ИмяКомандногоФайла = ОбщийГитКлиентСервер.СоздатьСамоудаляющийсяКомандныйФайлЛкс( СтрокаЗапуска );
	
	второйПараметр = "";
	
	ОбщийГитПовтИсп.ВКОбщая().Run( ИмяКомандногоФайла, второйПараметр, пРабочийКаталог, пОжидатьЗавершения, Ложь );
	//ЗапуститьПриложение( ИмяКомандногоФайла, пРабочийКаталог, пОжидатьЗавершения);
	
	Если Не пПропуститьВыводЛога
		И пОжидатьЗавершения
		И ФайлРезультата.Существует() Тогда
		
		ЛогВыводКомандыИзФайла( ФайлРезультата.ПолноеИмя );
		
	КонецЕсли;
	
	Возврат 0;
	
КонецФункции


Функция ВыполнитьКомандныйФайл( Знач пРабочийКаталог,
								Знач пИмяФайла,
								Знач пОжидатьЗавершения = Истина ) Экспорт
	
	КодВозврата = Неопределено;
	
	запускальщик = ОбщийГитПовтИсп.Запускальщик();
	
	Если запускальщик = Неопределено Тогда
		
		ЗапуститьПриложение( пИмяФайла, пРабочийКаталог, пОжидатьЗавершения, КодВозврата );
		
	Иначе
		
		запускальщик.CurrentDirectory = пРабочийКаталог;
		
		КодВозврата = запускальщик.Run( пИмяФайла, 0, Истина );
		
	КонецЕсли;
	
	Возврат КодВозврата;
	
КонецФункции


#КонецЕсли

#Область РасширениеСППР

//Возвращает путь к исполняемому файлу
Функция ПолучитьПриложение1С() Экспорт
	
	КаталогИсполняемогоФайла = "";
	КаталогПрограммы = "";
	ВерсияПлатформы = "";
	
	#Если Сервер ИЛИ ВнешнееСоединение Тогда
		
		КаталогИсполняемогоФайла = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(КаталогПрограммы());
		ПутьКВерсиямПлатформыНаСервере = Константы.ПутьКВерсиямПлатформыНаСервере.Получить();
		Если ЗначениеЗаполнено(ПутьКВерсиямПлатформыНаСервере) Тогда
			
			Если Не ЗначениеЗаполнено(ВерсияПлатформы) Тогда
				СисИнфо = Новый  СистемнаяИнформация;
				ВерсияПлатформы = СисИнфо.ВерсияПриложения;
			КонецЕсли; 
			ПутьКВерсиямПлатформыНаСервере = СтрЗаменить(ПутьКВерсиямПлатформыНаСервере, "%ВерсияПлатформы%", ВерсияПлатформы);
			Файл = Новый Файл(ПутьКВерсиямПлатформыНаСервере);
			Если Файл.Существует() Тогда
				КаталогИсполняемогоФайла = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПутьКВерсиямПлатформыНаСервере);
			Иначе
				ТекстОшибки = НСтр("ru = 'Не найдена указанная версия платформы: %ВерсияПлатформы% на сервере: %ИмяСервера%.
				|Путь к 1С:Конфигуратору на сервере: %Путь%.'");
				ТекстОшибки = СтрЗаменить(ТекстОшибки, "%ВерсияПлатформы%", ВерсияПлатформы);
				ТекстОшибки = СтрЗаменить(ТекстОшибки, "%ИмяСервера%", ИмяКомпьютера());
				ТекстОшибки = СтрЗаменить(ТекстОшибки, "%Путь%", ПутьКВерсиямПлатформыНаСервере);
				ВызватьИсключение ТекстОшибки;
			КонецЕсли;
			
		КонецЕсли; 
	
	#Иначе
	
		ВерсияУказана = ЗначениеЗаполнено(КаталогИсполняемогоФайла);
		
		Если НЕ ЗначениеЗаполнено(КаталогПрограммы) Тогда
			КаталогПрограммы = СокрЛП(КаталогПрограммы());
		КонецЕсли;
		
		КаталогПрограммы = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(КаталогПрограммы);
		
		Если ЗначениеЗаполнено(ВерсияПлатформы) 
			И НЕ ЗначениеЗаполнено(КаталогИсполняемогоФайла) Тогда
			
			КаталогИсполняемогоФайла = КаталогПрограммы;
			
			СистемнаяИнформация = Новый СистемнаяИнформация;
			
			ТекущаяВерсияПриложения = СистемнаяИнформация.ВерсияПриложения;
			Если Найти(КаталогПрограммы, ТекущаяВерсияПриложения) > 0 Тогда
				
				КаталогПроверки = СтрЗаменить(КаталогПрограммы, ТекущаяВерсияПриложения, ВерсияПлатформы);
				Файл = Новый Файл(КаталогПроверки);
				Если Файл.Существует() Тогда
					ВерсияУказана = Истина;
					КаталогИсполняемогоФайла = КаталогПроверки;
				КонецЕсли;
			КонецЕсли; 
		ИначеЕсли НЕ ЗначениеЗаполнено(КаталогИсполняемогоФайла) Тогда
			КаталогИсполняемогоФайла = КаталогПрограммы;
		КонецЕсли;
	
	#КонецЕсли
	
	Возврат (КаталогИсполняемогоФайла + "1cv8.exe");

КонецФункции

Функция СоздатьСамоудаляющийсяКомандныйФайлЛкс(Знач ТекстКомандногоФайла = "", Знач КраткоеИмяФайла = "") Экспорт
	
	Если ЗначениеЗаполнено(КраткоеИмяФайла) Тогда
		ПолноеИмяФайла = КаталогВременныхФайлов() + КраткоеИмяФайла + ".bat";
	Иначе
		ПолноеИмяФайла = ПолучитьИмяВременногоФайла("bat");
	КонецЕсли;
	//ТекстКомандногоФайла = "set path=C:\Program Files\Git\cmd;%path%" + Символы.ПС + ТекстКомандногоФайла;//!!!Удалить после рестарта службы рабочего сервера
	ТекстКомандногоФайла = ТекстКомандногоФайла + "
	|del """ + ПолноеИмяФайла + """
	|";
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(ТекстКомандногоФайла);
	ТекстовыйДокумент.Записать(ПолноеИмяФайла, КодировкаТекста.OEM);
	Результат = ПолноеИмяФайла;
	Возврат Результат;
	
КонецФункции

#КонецОбласти




