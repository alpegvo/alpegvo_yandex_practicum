/*Задача 1: Отобразить все записи из таблицы `company` по компаниям, которые закрылись.*/

SELECT *
FROM company
WHERE status='closed';

/*Задача 2: Отобразить количество привлечённых средств для новостных компаний США. 
Отсортировать таблицу по убыванию значений в поле `funding_total`.*/

SELECT funding_total
FROM company
WHERE country_code='USA' AND category_code='news'
ORDER BY funding_total DESC;

/*Задача 3: Найти общую сумму сделок по покупке одних компаний другими в долларах. 
 Отобрать сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.*/

SELECT SUM(price_amount)
FROM acquisition
WHERE (EXTRACT(YEAR FROM CAST(acquired_at AS date)) BETWEEN '2011' AND '2013') 
AND term_code='cash';

/*Задача 4: Отобразить имя, фамилию и названия аккаунтов людей в поле `twitter_username`, 
у которых названия аккаунтов начинаются на 'Silver'.*/

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

/*Задача 5: Вывести на экран всю информацию о людях, у которых названия аккаунтов в поле network_username
содержат подстроку 'money', а фамилия начинается на 'K'.*/

SELECT *
FROM people
WHERE twitter_username LIKE '%money%' 
AND last_name LIKE 'K%';

/*Задача 6: Для каждой страны отобразить общую сумму привлечённых инвестиций, которые получили компании, 
зарегистрированные в этой стране. Отсортировать данные по убыванию суммы.*/

SELECT country_code,
       SUM(funding_total)
FROM company       
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;

/*Задача 7: Составить таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, 
 привлечённых в эту дату. Необходимо оставить в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций 
 не равно нулю и не равно максимальному значению.*/

SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) !=0 
AND MIN(raised_amount) != MAX(raised_amount);

/*Задача 8: Создать поле с категориями:
Для фондов, которые инвестируют в 100 и более компаний - категория high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100 - категория middle_activity.
Если количество инвестируемых компаний фонда не достигает 20 - категория low_activity.
Отобразить все поля таблицы fund и новое поле с категориями.*/

SELECT *, 
      CASE
           WHEN invested_companies < 20 THEN 'low_activity'
           WHEN invested_companies >=20 AND invested_companies < 100 THEN 'middle_activity'
           WHEN invested_companies >=100 THEN 'high_activity'
      END
FROM fund;

/*Задача 9: Для каждой из категорий, назначенных в предыдущем задании, посчитать округлённое до ближайшего целого числа среднее количество 
 инвестиционных раундов, в которых фонд принимал участие. Вывести на экран категории и среднее число инвестиционных раундов. 
Отсортировать таблицу по возрастанию среднего.*/

SELECT CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds)) AS avg_investment_rounds
FROM fund
GROUP BY activity
ORDER BY avg_investment_rounds ASC;

/*Задача 10: Проверить, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны найти минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, 
основанные с 2010 по 2012 год включительно. 
Исключить страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Отобразить десять самых активных стран-инвесторов, отсортировав таблицу по среднему количеству компаний от большего к меньшему и 
добавить сортировку по коду страны в лексикографическом порядке.*/

SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) IN (2010,2011,2012)
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC,
         country_code ASC
LIMIT 10;

/*Задача 11: Отобразить имя и фамилию всех сотрудников стартапов. 
 Добавить поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.*/

SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p
LEFT OUTER JOIN education AS e ON  p.id = e.person_id;

/*Задача 12: Для каждой компании найти количество учебных заведений, которые окончили её сотрудники. 
Вывести название компании и число уникальных названий учебных заведений. Составить топ-5 компаний по количеству университетов.*/

SELECT c.name, 
       COUNT(DISTINCT e.instituition)
FROM company AS c
RIGHT OUTER JOIN people AS p ON c.id=p.company_id
RIGHT OUTER JOIN education AS e ON p.id=e.person_id
GROUP BY c.name
HAVING c.name IS NOT NULL
ORDER BY COUNT(DISTINCT e.instituition) DESC
LIMIT 5;

/*Задача 13: Составить список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.*/

SELECT DISTINCT c.name
FROM COMPANY as c
LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
WHERE c.status='closed' 
AND fr.is_first_round=1 
AND fr.is_last_round=1;

/*Задача 14: Составить список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.*/

SELECT DISTINCT p.id
FROM people AS p
LEFT OUTER JOIN company AS c ON p.company_id=c.id
WHERE c.name IN (SELECT DISTINCT c.name
                 FROM COMPANY as c
                 LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
                 WHERE c.status='closed' 
                 AND fr.is_first_round=1 
                 AND fr.is_last_round=1);

/*Задача 15: Составить таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.*/

SELECT DISTINCT p.id,
                e.instituition
FROM people AS p
LEFT OUTER JOIN company AS c ON p.company_id=c.id
JOIN education AS e ON p.id=e.person_id
WHERE c.name IN (SELECT DISTINCT c.name
                 FROM COMPANY as c
                 LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
                 WHERE c.status='closed' 
                 AND fr.is_first_round=1 
                 AND fr.is_last_round=1);
 
/*Задача 16: Посчитайть количество учебных заведений для каждого сотрудника из предыдущего задания, учитывая,
 что некоторые сотрудники могли окончить одно и то же заведение дважды.*/

SELECT DISTINCT p.id,
                COUNT(e.instituition)
FROM people AS p
LEFT OUTER JOIN company AS c ON p.company_id=c.id
JOIN education AS e ON p.id=e.person_id
WHERE c.name IN (SELECT DISTINCT c.name
                 FROM COMPANY as c
                 LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
                 WHERE c.status='closed' 
                 AND fr.is_first_round=1 
                 AND fr.is_last_round=1)
GROUP BY p.id;

/*Задача 17: Дополнить предыдущий запрос и вывести среднее число учебных заведений (всех, не только уникальных), 
 * которые окончили сотрудники разных компаний. Нужно вывести только одну запись.*/

SELECT AVG(inst_count.ei)
FROM (SELECT DISTINCT p.id,
             COUNT(e.instituition) AS ei
	  FROM people AS p
	  LEFT OUTER JOIN company AS c ON p.company_id=c.id
	  JOIN education AS e ON p.id=e.person_id
	  WHERE c.name IN (SELECT DISTINCT c.name
                 	   FROM COMPANY as c
                 	   LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
                 	   WHERE c.status='closed' 
                 	   AND fr.is_first_round=1 
                 	   AND fr.is_last_round=1)
	  GROUP BY p.id) AS inst_count;

/*Задача 18: Вывести среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook.*/

SELECT AVG(count)
FROM (SELECT COUNT(e.instituition)
      FROM company AS c
      RIGHT OUTER JOIN people AS p ON c.id=p.company_id
      RIGHT OUTER JOIN education AS e ON p.id=e.person_id
      WHERE c.name='Facebook'
      GROUP BY p.id) AS fb_count;

/*Задача 19: Составить таблицу из полей:
'name_of_fund' — название фонда;
'name_of_company' — название компании;
'amount' — сумма инвестиций, которую привлекла компания в раунде.
В таблицу должны войти данные о компаниях, в истории которых было больше шести важных этапов, 
а раунды финансирования проходили с 2012 по 2013 год включительно.*/
     
SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount      
FROM investment AS inv
LEFT OUTER JOIN company AS c ON inv.company_id = c.id
LEFT OUTER JOIN fund AS f ON inv.fund_id=f.id
LEFT OUTER JOIN funding_round AS fr ON inv.funding_round_id=fr.id
WHERE inv.company_id IN (SELECT id
                         FROM company
                         GROUP BY id
                         HAVING milestones>6)
AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) IN ('2012', '2013') 
AND fr.raised_amount != 0;

/*Задача 20: Выгрузить таблицу, в которой будут такие поля:
- название компании-покупателя;
- сумма сделки;
- название компании, которую купили;
- сумма инвестиций, вложенных в купленную компанию;
- доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.

Не учитывать те сделки, в которых сумма покупки равна нулю, а также такие компании, сумма инвестиций в которые равна нулю.
Отсортировать таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. 
Вывести первые 10 записей.*/

SELECT DISTINCT pok_com.name AS acquiring_company_name,
       acq.price_amount,
       prod_com.name AS acquired_company_name,
       prod_com.funding_total,
       ROUND(acq.price_amount/prod_com.funding_total) AS share
FROM acquisition AS acq
LEFT OUTER JOIN company AS pok_com ON acq.acquiring_company_id=pok_com.id
LEFT OUTER JOIN company AS prod_com ON acq.acquired_company_id=prod_com.id
WHERE acq.price_amount !=0 AND prod_com.funding_total !=0
ORDER BY acq.price_amount DESC,
         prod_com.funding_total
LIMIT 10;

/*Задача 21: Выгрузить таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. 
 * Проверить, что сумма инвестиций не равна нулю. Вывести также номер месяца, в котором проходил раунд финансирования.*/

SELECT c.name,
       EXTRACT(MONTH FROM CAST(fr.funded_at AS date)) AS month
FROM company AS c
RIGHT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
WHERE c.category_code='social' 
AND fr.raised_amount != 0 
AND EXTRACT(YEAR FROM CAST(funded_at AS date)) IN ('2010', '2011', '2012', '2013');

/*Задача 22: Отобрать данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. 
Сгруппировать данные по номеру месяца и получить таблицу, в которой будут поля:
- номер месяца, в котором проходили раунды;
- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
- количество компаний, купленных за этот месяц;
- общая сумма сделок по покупкам в этом месяце.*/

WITH
t_1 AS (SELECT EXTRACT(MONTH FROM CAST(fr.funded_at AS date)) as month,
               COUNT(DISTINCT f.name) AS funds
        FROM investment AS inv
        LEFT OUTER JOIN funding_round AS fr ON inv.funding_round_id=fr.id
        LEFT OUTER JOIN fund as f ON inv.fund_id=f.id
        WHERE EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) IN ('2010', '2011', '2012', '2013') AND f.country_code='USA'
        GROUP BY month),

t_2 AS (SELECT EXTRACT(MONTH FROM CAST(acq.acquired_at AS date)) as month,
               COUNT(acq.acquired_company_id) AS bought_companies,
               SUM(acq.price_amount) AS total_price_amount
        FROM acquisition AS acq
        WHERE EXTRACT(YEAR FROM CAST(acq.acquired_at AS date)) IN ('2010', '2011', '2012', '2013')
        GROUP BY month
        ORDER BY month)

SELECT t_1.month,
       t_1.funds,
       t_2.bought_companies,
       t_2.total_price_amount
FROM t_1
INNER JOIN t_2 ON t_1.month=t_2.month
ORDER BY MONTH;

/*Задача 23: Составить сводную таблицу и вывести среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 
 Данные за каждый год должны быть в отдельном поле. Отсортировать таблицу по среднему значению инвестиций за 2011 год от большего к меньшему. */

WITH
inv_2011 AS (SELECT c.country_code,
                    AVG(c.funding_total) as avg_2011
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST(c.founded_at AS date))='2011'
            GROUP BY c.country_code),
inv_2012 AS (SELECT c.country_code,
                    AVG(c.funding_total) AS avg_2012
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST(c.founded_at AS date))='2012'
            GROUP BY c.country_code),
inv_2013 AS (SELECT c.country_code,
                    AVG(c.funding_total) AS avg_2013
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST(c.founded_at AS date))='2013'
            GROUP BY c.country_code)
SELECT inv_2011.country_code,
       inv_2011.avg_2011,
       inv_2012.avg_2012,
       inv_2013.avg_2013
FROM inv_2011
JOIN inv_2012 ON inv_2011.country_code = inv_2012.country_code
JOIN inv_2013 ON inv_2012.country_code = inv_2013.country_code
ORDER BY inv_2011.avg_2011 DESC;











