﻿
Процедура ПередЗаписью(Отказ, Замещение)
	
	структДанные = ОбщийГитПовтИсп.ДанныеМетаданных();
	
	Для каждого цСтрока Из ЭтотОбъект Цикл
		
		структ = ДанныеОбъектаПоФайлу( цСтрока.ПутьКФайлу, структДанные );
		
		цСтрока.Объект = структ.Имя;
		цСтрока.ТипОбъекта = структ.Тип;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ДанныеОбъектаПоФайлу( Знач пИмяФайла, Знач пДанныеМетаданных )
	
	структОбъекта = Новый Структура( "Имя, Тип" );
	
	компоненты = СтрРазделить( пИмяФайла, "/", Ложь );
	
	Если компоненты.Количество() = 0 Тогда
		Возврат структОбъекта;
	КонецЕсли;
	
	текДанные = пДанныеМетаданных.Получить( компоненты[0] );
	
	Если текДанные = Неопределено Тогда
		Возврат структОбъекта;
	КонецЕсли;
	
	Если компоненты.Количество() = 1 Тогда
		Возврат структОбъекта;
	КонецЕсли;
	
	имяОбъекта = компоненты[1];
	
	Если СтрЗаканчиваетсяНа( НРег( имяОбъекта ), ".xml" ) Тогда
		имяОбъекта = Лев( имяОбъекта, СтрДлина( имяОбъекта )-4);
	КонецЕсли;
	
	структОбъекта.Имя = текДанные.Имя + "." + имяОбъекта;
	структОбъекта.Тип = текДанные.Тип;
	
	Если компоненты.Количество() = 2 Тогда
		Возврат структОбъекта;
	КонецЕсли;
	
	Если компоненты.Количество() >= 4
		И НРег( компоненты[2] ) = "forms" Тогда
		
		имяОбъекта = компоненты[3];
		
		Если СтрЗаканчиваетсяНа( НРег( имяОбъекта ), ".xml" ) Тогда
			имяОбъекта = Лев( имяОбъекта, СтрДлина( имяОбъекта )-4);
		КонецЕсли;
		
		структОбъекта.Имя = структОбъекта.Имя + "." + имяОбъекта;
		структОбъекта.Тип = "Управляемая форма";
		
	КонецЕсли;
	
	Возврат структОбъекта;
	
КонецФункции


