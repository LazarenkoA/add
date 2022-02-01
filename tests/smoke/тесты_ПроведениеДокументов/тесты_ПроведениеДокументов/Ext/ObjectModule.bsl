﻿#Область ОписаниеПеременных

Перем КонтекстЯдра;
Перем Утверждения;
Перем УтвержденияПроверкаТаблиц;

#КонецОбласти

#Область ПрограммныйИнтерфейс

#Область ИнтерфейсТестирования

Функция КлючНастройки() Экспорт
	Возврат "ПроведениеДокументов";
КонецФункции

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	КонтекстЯдра = КонтекстЯдраПараметр;
	Утверждения = КонтекстЯдра.Плагин("БазовыеУтверждения");
	УтвержденияПроверкаТаблиц = КонтекстЯдра.Плагин("УтвержденияПроверкаТаблиц");
	
	ЗагрузитьНастройки();
КонецПроцедуры

Процедура ЗаполнитьНаборТестов(НаборТестов, КонтекстЯдраПараметр) Экспорт
	КонтекстЯдра = КонтекстЯдраПараметр;
	
	ЗагрузитьНастройки();
	
	Если Не НужноВыполнятьТест() Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого МетаОбъект Из Метаданные.Документы Цикл
		Если МетаОбъект.Проведение = Метаданные.СвойстваОбъектов.Проведение.Разрешить 
			И ПравоДоступа("Проведение", МетаОбъект) Тогда
			
			ДобавитьТестыДляДокумента(НаборТестов, МетаОбъект);
		КонецЕсли; 
	КонецЦикла; 
	
КонецПроцедуры

#КонецОбласти

#Область Тесты

Процедура ПередЗапускомТеста() Экспорт
	НачатьТранзакцию();
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	Если ТранзакцияАктивна() Тогда
	   ОтменитьТранзакцию();
	КонецЕсли;
КонецПроцедуры

Процедура Тест_ПровестиДокумент(ДокументСсылка) Экспорт
	
	ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
	
	ДвиженияДо = ПолучитьДвиженияДокумента(ДокументОбъект, Истина);
	ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
	
	ДвиженияПосле = ПолучитьДвиженияДокумента(ДокументОбъект);
		
	ПлагинНастроек = КонтекстЯдра.Плагин("Настройки");
	Для Каждого КлючИЗначение Из ДвиженияДо Цикл
		ТипДвижения = КлючИЗначение.Ключ;
		ТаблицаДвиженияДо = КлючИЗначение.Значение;
		ТаблицаДвиженияПосле = ДвиженияПосле.Получить(ТипДвижения);
		
		ИмяМетаданных = Метаданные.НайтиПоТипу(ТипДвижения).ПолноеИмя();
		
		ДопПараметры = Новый Структура();
		Если Настройки.СравнениеДвиженийБезНомераСтроки Тогда
			ДопПараметры.Вставить("НечеткоеСравнение");
		КонецЕсли;
		Если ПлагинНастроек.ЕстьНастройка(ИмяМетаданных, Настройки.ИсключенияИзПроверкиДвижений) Тогда
			ИсключенияПолей = Вычислить(СтрШаблон("Настройки.ИсключенияИзПроверкиДвижений.%1", ИмяМетаданных));    
			Если ТипЗнч(ИсключенияПолей) = Тип("Массив") Тогда
				Для Каждого ИмяКолонки Из ИсключенияПолей Цикл
					ТаблицаДвиженияДо.Колонки.Удалить(ИмяКолонки);
					ТаблицаДвиженияПосле.Колонки.Удалить(ИмяКолонки);
				КонецЦикла;                
			КонецЕсли;
		КонецЕсли;
		
		УтвержденияПроверкаТаблиц.ПроверитьРавенствоТаблиц(ТаблицаДвиженияДо, ТаблицаДвиженияПосле, 
			"Отличаются движения по регистру " + ТипДвижения, ДопПараметры);
	КонецЦикла; 
	
КонецПроцедуры

Процедура Тест_ПропуститьПроведениеДокумента(Знач Сообщение) Экспорт
	КонтекстЯдра.ПропуститьТест(Сообщение);
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
	Результат.Вставить("КоличествоДокументов", 2);
	Результат.Вставить("ВыводитьИсключения", Ложь);
	Результат.Вставить("Исключения", Новый Массив);
	Результат.Вставить("Отбор", Новый Массив);
	Результат.Вставить("СравнениеДвиженийБезНомераСтроки", Истина); 
	Результат.Вставить("ИсключенияИзПроверкиДвижений", Новый Структура()); 
	
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

Процедура ДобавитьТестыДляДокумента(НаборТестов, МетаОбъект)

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Ссылка,
	|	Представление
	|ИЗ
	|	Документ." + МетаОбъект.Имя + "
	|ГДЕ
	|	Проведен //{Отбор}
	|
	|УПОРЯДОЧИТЬ ПО
	|	МоментВремени Убыв";

	Запрос.Текст = СтрЗаменить(Запрос.Текст, 
		"ВЫБРАТЬ ПЕРВЫЕ 1", 
		"ВЫБРАТЬ ПЕРВЫЕ " + Формат(Настройки.КоличествоДокументов, "ЧГ=")
	);
	
	СформироватьОтбор(Запрос, МетаОбъект, Настройки.Отбор, "
	|	И ", "//{Отбор}");
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;	
	КонецЕсли; 
	
	ПредставлениеТеста = "Проведение и проверка движений до и после - " + МетаОбъект.Имя;
	Сообщение = "Пропускаем из-за исключения по имени документа - " + ПредставлениеТеста;
	ЭтоИсключение = Ложь;  
	
	Если КонтекстЯдра.ЕстьВИсключаемойКоллекции(МетаОбъект.Имя, Настройки.Исключения) Тогда
		КонтекстЯдра.Отладка(Сообщение); 
		
		Если Не Настройки.ВыводитьИсключения Тогда
		    Возврат;
		КонецЕсли;	
		
		ЭтоИсключение = Истина;
	КонецЕсли;  

	НаборТестов.НачатьГруппу(МетаОбъект.Синоним + " - Документ."  + МетаОбъект.Имя);
		
	Если ЭтоИсключение Тогда
		ПараметрыТеста = НаборТестов.ПараметрыТеста(Сообщение);
		НаборТестов.Добавить("Тест_ПропуститьПроведениеДокумента", ПараметрыТеста, Сообщение);
	Иначе
		Выборка = РезультатЗапроса.Выбрать();
		Пока Выборка.Следующий() Цикл
			ПараметрыТеста = НаборТестов.ПараметрыТеста(Выборка.Ссылка);
			ПредставлениеТеста = "Проведение и проверка движений до и после - " + Выборка.Представление;
			
			НаборТестов.Добавить("Тест_ПровестиДокумент", ПараметрыТеста, ПредставлениеТеста);			
		КонецЦикла; 
	КонецЕсли;	
		
КонецПроцедуры

Процедура СформироватьОтбор(Запрос, МетаОбъект, Отбор, Префикс, ЗаменяемыйТекстЗапроса)
	Если Отбор = Неопределено ИЛИ Отбор.Количество() = 0 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, ЗаменяемыйТекстЗапроса, "");
		Возврат;
	КонецЕсли;
	
	МассивУсловий = Новый Массив;
	Для Каждого ЭлОтбора Из Отбор Цикл
		ИмяДокумента = ЭлОтбора["ИмяДокумента"];
		Если ИмяДокумента <> Неопределено И НЕ КонтекстЯдра.СтрокаСоответствуетШаблону(МетаОбъект.Имя, ИмяДокумента) Тогда
			Продолжить;
		КонецЕсли;
		
		Для Каждого ЭлОтб Из ЭлОтбора Цикл
			Если ЭлОтб.Ключ = "ИмяДокумента" Тогда
				Продолжить;
			КонецЕсли;
			
			Рекв = НайтиРеквизит(МетаОбъект, ЭлОтб.Ключ);
			Если Рекв = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			Для Каждого Эл Из ЭлОтб.Значение Цикл
				ИмяПрм = "Прм_" + Формат(МассивУсловий.ВГраница()+1, "ЧДЦ=0; ЧН=0; ЧГ=");
				Знч = ПривестиЗначение(Рекв.Тип, Эл.Значение);
				СтрУсл = ПолучитьУсловие(Эл.Ключ);
				
				Запрос.УстановитьПараметр(ИмяПрм, Знч);
				МассивУсловий.Добавить(СтрШаблон("%1 %2 &%3", ЭлОтб.Ключ, СтрУсл, ИмяПрм));
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Если МассивУсловий.Количество() = 0 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, ЗаменяемыйТекстЗапроса, "");
		Возврат;
	КонецЕсли;
	
	НаЧтоМеняем = Префикс + СтрСоединить(МассивУсловий, "
	|	И ");
	Запрос.Текст = СтрЗаменить(Запрос.Текст, ЗаменяемыйТекстЗапроса, НаЧтоМеняем);
КонецПроцедуры

Функция ПривестиЗначение(КТипу, Знч)
	Если КТипу.СодержитТип(Тип("Дата")) И ТипЗнч(Знч) = Тип("Строка") Тогда
		МассивДаты = СтрРазделить(СокрЛП(Знч), "."); 
		Если МассивДаты.Количество() = 3 Тогда
			Возврат Дата(Число(МассивДаты[2]), Число(МассивДаты[1]), Число(МассивДаты[0]));
		КонецЕсли;
		Возврат XMLЗначение(Тип("Дата"), Знч);
	КонецЕсли;
	Возврат КТипу.ПривестиЗначение(Знч);
КонецФункции

Функция НайтиРеквизит(МетаОбъект, Имя)
	Для Каждого Рекв Из МетаОбъект.СтандартныеРеквизиты Цикл
		Если Рекв.Имя = Имя Тогда
			Возврат Рекв;
		КонецЕсли;
	КонецЦикла;
	Возврат МетаОбъект.Реквизиты.Найти(Имя);
КонецФункции

Функция ПолучитьУсловие(Текст)
	СтрУсл = НРег(СокрЛП(Текст));
	Если СтрУсл = "lt" Тогда // меньше чем
		Возврат "<";
	ИначеЕсли СтрУсл = "le" Тогда // меньше или равно
		Возврат "<=";
	ИначеЕсли СтрУсл = "eq" Тогда // равно 
		Возврат "=";
	ИначеЕсли СтрУсл = "ne" Тогда // не равно
		Возврат "<>";
	ИначеЕсли СтрУсл = "ge" Тогда // больше или равно
		Возврат ">=";
	ИначеЕсли СтрУсл = "gt" Тогда // больше чем
		Возврат ">";
	ИначеЕсли СтрУсл = "lk" Тогда // на подобии like
		Возврат "ПОДОБНО";
	Иначе
		Возврат СокрЛП(Текст);
	КонецЕсли;
КонецФункции

Функция ПолучитьДвиженияДокумента(ДокументОбъект, ОчищатьДвижения = Ложь)
	
	Результат = Новый Соответствие; 
	
	Для Каждого Движение Из ДокументОбъект.Движения Цикл
		ТипДвижения = ТипЗнч(Движение);
		Движение.Прочитать();
		ТаблицаДвижения = Движение.Выгрузить();
		Если Настройки.СравнениеДвиженийБезНомераСтроки Тогда
			Кол = ТаблицаДвижения.Колонки.Найти("НомерСтроки");
			ТаблицаДвижения.Колонки.Удалить(Кол);
		КонецЕсли;
		Результат.Вставить(ТипДвижения, ТаблицаДвижения);       
		Если ОчищатьДвижения Тогда
			Движение.Очистить(); // имеет смысл очищать если у документа режим проведения стоит "Удалять автоматически при отмене проведения"   
		КонецЕсли;
	КонецЦикла; 
	
	Возврат Результат;
	
КонецФункции

Функция ИмяТеста()
	Возврат Метаданные().Имя;
КонецФункции

#КонецОбласти
