﻿#Область ОписаниеПеременных

Перем КонтекстЯдра;
Перем Утверждения;

#КонецОбласти

#Область ПрограммныйИнтерфейс

#Область ИнтерфейсТестирования

Функция КлючНастройки() Экспорт
	Возврат Метаданные().Имя;
КонецФункции

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	КонтекстЯдра = КонтекстЯдраПараметр;
	Утверждения = КонтекстЯдра.Плагин("БазовыеУтверждения");
	
	ЗагрузитьНастройки();
КонецПроцедуры

Процедура ЗаполнитьНаборТестов(НаборТестов, КонтекстЯдраПараметр) Экспорт
	
	Если ТекущийРежимЗапуска() = РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение Then
		Возврат;	
	КонецЕсли;
	
	КонтекстЯдра = КонтекстЯдраПараметр;
	ЗагрузитьНастройки();
	
	Если Не НужноВыполнятьТест() Тогда
		Возврат;
	КонецЕсли;

	ДобавитьОбщиеМакеты(НаборТестов);
	ДобавитьМакетМетаданных(НаборТестов);	
	
КонецПроцедуры

#КонецОбласти

#Область Тесты

Процедура ТестДолжен_ПроверитьМакетСКД(ИмяМенеджера, ИмяОбьекта, ИмяМакета) Экспорт
	
	Менеджер = МенеджерОбьектаПоИмени(ИмяМенеджера);
	
	СхемаКомпоновкиДанных = Менеджер[ИмяОбьекта].ПолучитьМакет(СокрЛП(ИмяМакета));
	
	ПроверитьСхемуСКД(СхемаКомпоновкиДанных);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьОбщийМакетСКД(ИмяМакета) Экспорт
	
	СхемаКомпоновкиДанных = ПолучитьОбщийМакет(ИмяМакета);
	
	ПроверитьСхемуСКД(СхемаКомпоновкиДанных);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьВложенныйМакетСКД(ИмяМенеджера, ИмяОбьекта, ИменаМакетов) Экспорт
	
	ИменаМакетов = РазложитьСтрокуВМассивПодстрок(ИменаМакетов, "->");
	
	Если ИмяОбьекта = ТекстОбщиеМакеты() Тогда
		СхемаКомпоновкиДанных = ПолучитьОбщийМакет(ИменаМакетов[0]);
	Иначе
		Менеджер = МенеджерОбьектаПоИмени(ИмяМенеджера);
		СхемаКомпоновкиДанных = Менеджер[ИмяОбьекта].ПолучитьМакет(ИменаМакетов[0]);
	КонецЕсли;
	
	Для ВложенностьМакета = 1 По ИменаМакетов.Количество() - 1 Цикл
		ВложенныеСхемыКомпоновкиДанных = СхемаКомпоновкиДанных.ВложенныеСхемыКомпоновкиДанных;
		СхемаКомпоновкиДанных = ВложенныеСхемыКомпоновкиДанных.Найти(ИменаМакетов[ВложенностьМакета]).Схема;
	КонецЦикла;
	
	ПроверитьСхемуСКД(СхемаКомпоновкиДанных);
	
КонецПроцедуры

Процедура ТестДолжен_ПропуститьМакетСКД(ТекстСообщения) Экспорт
	Утверждения.ПропуститьТест(ТекстСообщения);	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Настройки

Процедура ЗагрузитьНастройки()
	Если ЗначениеЗаполнено(Настройки) Тогда
		Возврат;
	КонецЕсли;

    ПлагинНастройки = КонтекстЯдра.Плагин("Настройки");
    ПлагинНастройки.Инициализация(КонтекстЯдра);
    
    Настройки = ПлагинНастройки.ПолучитьНастройку(КлючНастройки());	
	НастройкиПоУмолчанию = НастройкиПоУмолчанию();
    Если ТипЗнч(Настройки) <> Тип("Структура") Then
        Настройки = НастройкиПоУмолчанию;
	Иначе
		ЗаполнитьЗначенияСвойств(НастройкиПоУмолчанию, Настройки);
        Настройки = НастройкиПоУмолчанию;
	КонецЕсли;

КонецПроцедуры

Функция НастройкиПоУмолчанию()
	
	Результат = Новый Структура;
	
	Результат.Вставить("Используется", Истина);
	Результат.Вставить("ИсключенияОбщихМакетов", Новый Массив);
	Результат.Вставить("ИсключенияПоИмениМетаданных", Новый Массив);
	Результат.Вставить("ИсключенияПоИмениМакетов", Новый Массив);
	Результат.Вставить("ОтборПоПрефиксу", Ложь);
	Результат.Вставить("Префикс", "");
	
	Возврат Результат;
КонецФункции

Функция НужноВыполнятьТест()
	
	ЗагрузитьНастройки();
	
	Если Не ЗначениеЗаполнено(Настройки) Тогда
		Возврат Истина;
	КонецЕсли;
	
	КлючНастройки = КлючНастройки();
	
	ВыполнятьТест = Истина;
	Если ТипЗнч(Настройки) = Тип("Структура") 
		И Настройки.Свойство("Используется", ВыполнятьТест) Тогда

			Возврат ВыполнятьТест = Истина;	
	КонецЕсли;
	
	Возврат Истина;

КонецФункции

#КонецОбласти

Процедура ДобавитьОбщиеМакеты(НаборТестов)
	
	мОбщиеМакеты = ОбщиеМакеты(Настройки.ОтборПоПрефиксу, Настройки.Префикс);
			
	Если мОбщиеМакеты.Количество() > 0 Тогда
		
		НаборТестов.НачатьГруппу(ТекстОбщиеМакеты(), Ложь);
		
		Для Каждого ОбщийМакет Из мОбщиеМакеты Цикл
			
			Сообщение = "Пропускаем из-за исключения по имени общего макета - " + 
			КонтекстЯдра.СтрШаблон_(ШаблонПредставления(), ТекстОбщиеМакеты(), ОбщийМакет.Представление);
			Если ДобавитьТестИсключениеЕслиЕстьВИсключаемойКоллекции(ОбщийМакет.Представление, 
						Настройки.ИсключенияОбщихМакетов, Сообщение, НаборТестов) Тогда
				Продолжить;
			КонецЕсли;
			
			НаборТестов.Добавить(ОбщийМакет.ИмяПроцедуры, ОбщийМакет.Параметры, ОбщийМакет.Представление);
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьМакетМетаданных(НаборТестов)
	
	ГруппыМакетовМетаданных = ГруппыМакетовМетаданных(Настройки.ОтборПоПрефиксу, Настройки.Префикс);
	
	Для Каждого ГруппаМакетовМетаданных Из ГруппыМакетовМетаданных Цикл
		
		Если ГруппаМакетовМетаданных.Значение.Количество() > 0 Тогда
			
			НаборТестов.НачатьГруппу(ГруппаМакетовМетаданных.Ключ, Ложь);
			
			Для Каждого МакетМетаданных Из ГруппаМакетовМетаданных.Значение Цикл
				
				НаборТестов.Добавить(
					МакетМетаданных.ИмяПроцедуры, 
					МакетМетаданных.Параметры, 
					МакетМетаданных.Представление);
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ДобавитьВложенныеМакеты(МассивТестов, Родитель, ИмяРодителя, ИмяОбъекта = "", ИмяМенеджера = "")
	
	Если ТипЗнч(Родитель) = Тип("ВложеннаяСхемаКомпоновкиДанных") Тогда
		Макет = Родитель.Схема;
	ИначеЕсли ЗначениеЗаполнено(ИмяМенеджера) Тогда
		Менеджер = МенеджерОбьектаПоИмени(ВРег(ИмяМенеджера));
		Макет = Менеджер[ИмяОбъекта].ПолучитьМакет(СокрЛП(Родитель.Имя));
	Иначе
		Макет = ПолучитьОбщийМакет(Родитель.Имя);
	КонецЕсли;
	
	Для Каждого ВложенныйМакет Из Макет.ВложенныеСхемыКомпоновкиДанных Цикл
		
		ИмяМакета = СтрШаблон_("%1->%2", ИмяРодителя, ВложенныйМакет.Имя);	
		Представление = СтрШаблон_(ШаблонПредставления(), ИмяОбъекта, ИмяМакета);
		
		ПараметрыТеста = Новый Массив;
		ПараметрыТеста.Добавить(ИмяМенеджера);
		ПараметрыТеста.Добавить(ИмяОбъекта);
		ПараметрыТеста.Добавить(ИмяМакета);
		
		СтруктураТеста = Новый Структура;
		СтруктураТеста.Вставить("ИмяПроцедуры", "ТестДолжен_ПроверитьВложенныйМакетСКД");
		СтруктураТеста.Вставить("Параметры", ПараметрыТеста);
		СтруктураТеста.Вставить("Представление", Представление);
		МассивТестов.Добавить(СтруктураТеста);			
		
		ДобавитьВложенныеМакеты(МассивТестов, ВложенныйМакет, ИмяМакета, ИмяОбъекта, ИмяМенеджера);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьСхемуСКД(СхемаКомпоновкиДанных)

	ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных;
	
	КомпоновщикНастроекКомпоновкиДанных = Новый КомпоновщикНастроекКомпоновкиДанных;
	ИсточникДоступныхНастроекКомпоновкиДанных = Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновкиДанных);
	
	// Тут проходит синтаксический анализ запроса.
    КомпоновщикНастроекКомпоновкиДанных.Инициализировать(ИсточникДоступныхНастроекКомпоновкиДанных);
	
КонецПроцедуры

Функция ПроверяемыеМетаданные()
	
	ПроверяемыеОбъекты = Новый Массив();
	ПроверяемыеОбъекты.Добавить("Справочники");
	ПроверяемыеОбъекты.Добавить("Документы");
	ПроверяемыеОбъекты.Добавить("Обработки");
	ПроверяемыеОбъекты.Добавить("Отчеты");
	ПроверяемыеОбъекты.Добавить("Перечисления");
	ПроверяемыеОбъекты.Добавить("ПланыВидовХарактеристик");
	ПроверяемыеОбъекты.Добавить("ПланыСчетов");
	ПроверяемыеОбъекты.Добавить("ПланыВидовРасчета");
	ПроверяемыеОбъекты.Добавить("РегистрыСведений");
	ПроверяемыеОбъекты.Добавить("РегистрыНакопления");
	ПроверяемыеОбъекты.Добавить("РегистрыБухгалтерии");
	ПроверяемыеОбъекты.Добавить("РегистрыРасчета");
	ПроверяемыеОбъекты.Добавить("БизнесПроцессы");
	ПроверяемыеОбъекты.Добавить("Задачи");
	
	Возврат ПроверяемыеОбъекты;
	
КонецФункции

Функция МенеджерОбьектаПоИмени(Знач ИмяМенеджера)
	
	Попытка
	    Менеджер = Вычислить(ИмяМенеджера);
	Исключение
		Менеджер = Неопределено;	
	КонецПопытки;
		
	Возврат Менеджер;
	
КонецФункции

Функция ШаблонПредставления()
	Возврат НСтр("ru = 'Валидация корректности запроса СКД в %1: %2'");
КонецФункции

Функция ТекстОбщиеМакеты() Экспорт
	Возврат "ОбщиеМакеты";
КонецФункции

Функция ДобавитьТестИсключениеЕслиЕстьВИсключаемойКоллекции(Знач ЧтоИщем, 
															Знач КоллекцияДляПоиска, 
															Знач Сообщение, 
															Знач НаборТестов)
			
	Если КонтекстЯдра.ЕстьВИсключаемойКоллекции(ЧтоИщем, КоллекцияДляПоиска) Тогда
		
		КонтекстЯдра.Отладка(Сообщение);
		ПараметрыТеста = НаборТестов.ПараметрыТеста(Сообщение);
		
		НаборТестов.Добавить("Тест_ПропуститьМакетСКД", ПараметрыТеста, Сообщение);	
		
		Возврат Истина;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Функция ОбщиеМакеты(ОтборПоПрефиксу, ПрефиксОбъектов) Экспорт
	
	мОбщиеМакеты = Новый Массив;
	
	Для Каждого ОбщийМакет Из Метаданные.ОбщиеМакеты Цикл
		
		Если ОбщийМакет.ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.СхемаКомпоновкиДанных Тогда
			Продолжить;
		КонецЕсли;
		Если ОтборПоПрефиксу И Не СтрНачинаетсяС(ВРег(ОбщийМакет.Имя), ВРег(ПрефиксОбъектов)) Тогда
			Продолжить;
		КонецЕсли;
		
		ПараметрыТеста = Новый Массив;
		ПараметрыТеста.Добавить(ОбщийМакет.Имя);
		
		мОбщиеМакеты.Добавить(
			Новый Структура("ИмяПроцедуры, Параметры, Представление",
				"ТестДолжен_ПроверитьОбщийМакетСКД",
				ПараметрыТеста,
				СтрШаблон_(ШаблонПредставления(), ТекстОбщиеМакеты(), ОбщийМакет.Имя)));	
				
		ДобавитьВложенныеМакеты(мОбщиеМакеты, ОбщийМакет, ОбщийМакет.Имя, ТекстОбщиеМакеты());
				
	КонецЦикла;
	
	Возврат мОбщиеМакеты;
	
КонецФункции

Функция ГруппыМакетовМетаданных(ОтборПоПрефиксу, ПрефиксОбъектов) Экспорт
	
	ГруппыМакетовМетаданных = Новый Соответствие;
	
	ПроверяемыеОбъекты = ПроверяемыеМетаданные();
	
	Для Каждого ПроверяемыйОбъект Из ПроверяемыеОбъекты Цикл
		
		МакетыМетаданных = Новый Массив;
		
		Для Каждого ТекОбъект Из Метаданные[ПроверяемыйОбъект] Цикл
			Если ОтборПоПрефиксу И Не СтрНачинаетсяС(ВРег(ТекОбъект.Имя), ВРег(ПрефиксОбъектов)) Тогда
				Продолжить;
			КонецЕсли;
			
			ИмяМенеджера = ВРЕГ(ПроверяемыйОбъект);
			Для Каждого ТекДанныеМакета Из ТекОбъект.Макеты Цикл
				
				Если ТекДанныеМакета.ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.СхемаКомпоновкиДанных Тогда
					Продолжить;
				КонецЕсли;
				
				ПараметрыТеста = Новый Массив;
				ПараметрыТеста.Добавить(ИмяМенеджера);
				ПараметрыТеста.Добавить(ТекОбъект.Имя);
				ПараметрыТеста.Добавить(ТекДанныеМакета.Имя);
				
				МакетыМетаданных.Добавить(
					Новый Структура("ИмяПроцедуры, Параметры, Представление",
						"ТестДолжен_ПроверитьМакетСКД",
						ПараметрыТеста,
						СтрШаблон_(ШаблонПредставления(), ТекОбъект.Имя, ТекДанныеМакета.Имя)));
											
				ДобавитьВложенныеМакеты(
					МакетыМетаданных, 
					ТекДанныеМакета, 
					ТекДанныеМакета.Имя, 
					ТекОбъект.Имя, 
					ИмяМенеджера);
						
			КонецЦикла;
			
		КонецЦикла;
		
		Если МакетыМетаданных.Количество() Тогда
			ГруппыМакетовМетаданных.Вставить(ПроверяемыйОбъект, МакетыМетаданных);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ГруппыМакетовМетаданных;
	
КонецФункции

Функция СтрШаблон_(СтрокаШаблон, 
				Парам1 = Неопределено, 
				Парам2 = Неопределено,
				Парам3 = Неопределено, 
				Парам4 = Неопределено, 
				Парам5 = Неопределено)

	Если КонтекстЯдра = Неопределено Тогда
		СтроковыеУтилиты = ВнешниеОбработки.Создать("СтроковыеУтилиты");
		Возврат СтроковыеУтилиты.ПодставитьПараметрыВСтроку(СтрокаШаблон, Парам1, Парам2, Парам3, Парам4, Парам5);
	Иначе
		Возврат КонтекстЯдра.СтрШаблон_(СтрокаШаблон, Парам1, Парам2, Парам3, Парам4, Парам5);
	КонецЕсли;

КонецФункции

Функция РазложитьСтрокуВМассивПодстрок(Строка, Разделитель = ",", ПропускатьПустыеСтроки = Неопределено)
	
	Если КонтекстЯдра = Неопределено Тогда
		СтроковыеУтилиты = ВнешниеОбработки.Создать("СтроковыеУтилиты");
		Возврат СтроковыеУтилиты.РазложитьСтрокуВМассивПодстрок(Строка, Разделитель, ПропускатьПустыеСтроки);
	Иначе
		Возврат КонтекстЯдра.РазложитьСтрокуВМассивПодстрок(Строка, Разделитель, ПропускатьПустыеСтроки);
	КонецЕсли;

КонецФункции

Процедура ЗаписатьИнформациюВЖурналРегистрации(Знач Комментарий)
	ЗаписьЖурналаРегистрации(ИмяСобытия(), УровеньЖурналаРегистрации.Информация,,, Комментарий);
КонецПроцедуры

Функция ИмяСобытия()
	Возврат "VanessaADD.Дымовые.тесты_ПроверкаМакетовСКД"; // по аналогии с другими тестами
КонецФункции
  
Процедура ЗаписатьПредупреждениеВЖурналРегистрацииСервер(Комментарий)
	ЗаписьЖурналаРегистрации(ИмяСобытия(), УровеньЖурналаРегистрации.Предупреждение, , , Комментарий);
КонецПроцедуры
	
Процедура ЗаписатьОшибкуВЖурналРегистрации(Комментарий)
	ЗаписьЖурналаРегистрации(ИмяСобытия(), УровеньЖурналаРегистрации.Ошибка, , , Комментарий);
КонецПроцедуры


#КонецОбласти