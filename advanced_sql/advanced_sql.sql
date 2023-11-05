/*Задача 1: Найти количество вопросов, которые набрали больше 300 очков 
 или как минимум 100 раз были добавлены в «Закладки».*/

SELECT COUNT(p.id)
FROM stackoverflow.posts AS p
LEFT JOIN stackoverflow.post_types AS pt ON p.post_type_id = pt.id
WHERE (p.score>300 OR p.favorites_count>=100) AND pt.type='Question';

/*Задача 2: Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно? 
 Результат округлить до целого числа.*/

SELECT ROUND(AVG(count),0)
FROM (SELECT EXTRACT(DAY FROM p.creation_date) AS day, 
             COUNT(*)
      FROM stackoverflow.posts AS p
      JOIN stackoverflow.post_types AS pt ON p.post_type_id=pt.id
      WHERE pt.type='Question' AND (p.creation_date BETWEEN '01-11-2008'::date AND '19-11-2008'::date)
      GROUP BY day
      ORDER BY day) AS qbd;

/*Задача 3: Сколько пользователей получили значки сразу в день регистрации? 
 Вывеcти количество уникальных пользователей.*/
     
SELECT COUNT(DISTINCT u.id)
FROM stackoverflow.users AS u
LEFT JOIN stackoverflow.badges AS b ON u.id=b.user_id
WHERE u.creation_date::date = b.creation_date::date;

/*Задача 4: Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос?*/
     
WITH jc_posts AS
(SELECT p.id,
       COUNT(v.id)
FROM stackoverflow.posts AS p
JOIN stackoverflow.votes AS v ON p.id=v.post_id
GROUP BY p.id
HAVING COUNT(v.id)>=1 AND p.id IN (SELECT p.id
                                   FROM stackoverflow.posts AS p
                                   LEFT JOIN stackoverflow.users AS u ON u.id=p.user_id
                                   WHERE u.display_name='Joel Coehoorn'))

SELECT COUNT(*)
FROM jc_posts;

/*Задача 5: Выгрузить все поля таблицы vote_types и добавить к таблице поле rank, 
 в которое войдут номера записей в обратном порядке. Таблица должна быть отсортирована по полю id. */

SELECT *,
      ROW_NUMBER() OVER(ORDER BY vt.id DESC) AS rank
FROM stackoverflow.vote_types AS vt
ORDER BY vt.id

/*Задача 6: Отобрать 10 пользователей, которые поставили больше всего голосов типа Close. 
 Отобразить таблицу из двух полей: идентификатора пользователя и количества голосов. 
 Отсортировать данные сначала по убыванию количества голосов, 
 потом по убыванию значения идентификатора пользователя.*/

WITH most_close_votes AS
(SELECT u.id,
       COUNT(v.id)
FROM stackoverflow.users AS u
JOIN stackoverflow.votes AS v ON u.id=v.user_id
JOIN stackoverflow.vote_types AS vt ON v.vote_type_id=vt.id 
WHERE vt.name = 'Close'
GROUP BY u.id
ORDER BY COUNT(v.id) DESC
LIMIT 10)

SELECT *
FROM most_close_votes
ORDER BY count DESC, id DESC;

/*Задача 7: Отобрать 10 пользователей с наибольшим количеством значков, 
 полученных в период с 15 ноября по 15 декабря 2008 года включительно.
Отобразить поля:
идентификатор пользователя;
число значков;
место в рейтинге — чем больше значков, тем выше рейтинг.
Пользователям, которые набрали одинаковое количество значков, присвоить одно и то же место в рейтинге.
Отсортировать записи по количеству значков по убыванию, 
а затем по возрастанию значения идентификатора пользователя.*/

WITH users_with_most_badges AS
(SELECT u.id,
       COUNT(b.id)
FROM stackoverflow.users AS u
JOIN stackoverflow.badges AS b ON u.id=b.user_id
WHERE b.creation_date::date BETWEEN '15-11-2008'::date AND '15-12-2008'::date
GROUP BY u.id
ORDER BY COUNT(b.id) DESC
LIMIT 10)

SELECT *,
       DENSE_RANK() OVER (ORDER BY count DESC)
FROM users_with_most_badges
ORDER BY count DESC, id ASC;

/*Задача 8: Сколько в среднем очков получает пост каждого пользователя?
Сформировать таблицу из следующих полей:
заголовок поста;
идентификатор пользователя;
число очков поста;
среднее число очков пользователя за пост, округлённое до целого числа.
Не учитывать посты без заголовка, а также те, что набрали ноль очков. */

SELECT p.title,
       p.user_id,
       p.score,
       ROUND(AVG(p.score) OVER(PARTITION BY p.user_id), 0) AS avg_user_score
FROM stackoverflow.posts AS p
WHERE p.title IS NOT NULL AND p.score != 0;

/*Задача 9: Отобразить заголовки постов, которые были написаны пользователями, получившими более 1000 значков. Посты без заголовков не должны попасть в список.*/

WITH users_with_100500_badges AS
(SELECT u.id,
       COUNT(b.id)
FROM stackoverflow.users AS u
JOIN stackoverflow.badges AS b ON u.id=b.user_id
GROUP BY u.id
HAVING COUNT(b.id) > 1000)

SELECT p.title
FROM stackoverflow.posts AS p
WHERE p.title IS NOT NULL
AND p.user_id IN (SELECT id
                  FROM users_with_100500_badges);
                 
/*Задача 10: Написать запрос, который выгрузит данные о пользователях из Канады (англ. Canada). 
 * Разделить пользователей на три группы в зависимости от количества просмотров их профилей:
- пользователям с числом просмотров больше либо равным 350 присвоить группу 1;
- пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу 2;
- пользователям с числом просмотров меньше 100 — группу 3.
Отобразить в итоговой таблице идентификатор пользователя, количество просмотров профиля и группу. 
Пользователи с количеством просмотров меньше либо равным нулю не должны войти в итоговую таблицу.*/
                 
SELECT u.id,
       u.views,
       CASE
           WHEN u.views < 100 THEN 3
           WHEN u.views >= 100 AND u.views < 350 THEN 2
           WHEN u.views >= 350 THEN 1
       END
FROM stackoverflow.users AS u
WHERE u.views >= 1
AND u.location LIKE '%Canada%';

/*Задача 11: Дополнить предыдущий запрос. Отобразить лидеров каждой группы — пользователей,
 которые набрали максимальное число просмотров в своей группе. Вывести поля с идентификатором пользователя,
 группой и количеством просмотров. Отсортировать таблицу по убыванию просмотров, 
 а затем по возрастанию значения идентификатора.*/

WITH views_rating AS
(SELECT u.id,
       u.views,
       CASE
           WHEN u.views < 100 THEN 3
           WHEN u.views >= 100 AND u.views < 350 THEN 2
           WHEN u.views >= 350 THEN 1
       END
FROM stackoverflow.users AS u
WHERE u.views >= 1
AND u.location LIKE '%Canada%'),

views_rating_2 AS
(SELECT *,
       MAX(vr.views) OVER(PARTITION BY vr.case)
FROM views_rating AS vr
ORDER BY vr.case DESC)

SELECT vr2.id,
       vr2.case,
       vr2.views
FROM views_rating_2 AS vr2
WHERE vr2.views = vr2.max
ORDER BY vr2.views DESC, vr2.id ASC;

/*Задача 12: Посчитать ежедневный прирост новых пользователей в ноябре 2008 года. 
Сформировать таблицу с полями:
- номер дня;
- число пользователей, зарегистрированных в этот день;
- сумма пользователей с накоплением.*/

SELECT EXTRACT(DAY FROM creation_date) AS day,
       COUNT(id),
       SUM(COUNT(id)) OVER (ORDER BY EXTRACT(DAY FROM creation_date))
FROM stackoverflow.users
WHERE creation_date::date BETWEEN '01-11-2008'::date AND '30-11-2008'::date
GROUP BY DAY;

/*Задача 13: Для каждого пользователя, который написал хотя бы один пост, найти интервал между регистрацией 
и временем создания первого поста. Отобразить:
- идентификатор пользователя;
- разницу во времени между регистрацией и первым постом.*/

WITH first_posts AS
(SELECT DISTINCT p.user_id,
       MIN(p.creation_date) OVER(PARTITION BY p.user_id)
FROM stackoverflow.posts AS p
ORDER BY p.user_id)

SELECT u.id,
       fp.min - u.creation_date
FROM first_posts AS fp
INNER JOIN stackoverflow.users AS u ON fp.user_id=u.id;

/*Задача 14: Вывести общую сумму просмотров у постов, опубликованных в каждый месяц 2008 года. 
 Если данных за какой-либо месяц в базе нет, такой месяц можно пропустить. 
 Результат отсортировать по убыванию общего количества просмотров.*/

SELECT DISTINCT CAST(DATE_TRUNC('month',creation_date) AS date) AS month,
       SUM(views_count)
FROM stackoverflow.posts
GROUP BY month
ORDER BY sum DESC;

/*Задача 15: Вывести имена самых активных пользователей, которые в первый месяц после регистрации
 (включая день регистрации) дали больше 100 ответов. Вопросы, которые задавали пользователи, учитывать не нужно. 
 Для каждого имени пользователя вывести количество уникальных значений user_id. 
 Отсортировать результат по полю с именами в лексикографическом порядке.*/

WITH only_answers AS
(SELECT p.creation_date,
       p.user_id,
       p.id as post_id,
       pt.type
FROM stackoverflow.posts AS p
JOIN stackoverflow.post_types AS pt ON p.post_type_id=pt.id
WHERE pt.type='Answer')

SELECT u.display_name,
       COUNT(DISTINCT u.id)
FROM stackoverflow.users AS u
JOIN only_answers AS oa ON u.id = oa.user_id
WHERE oa.creation_date::date <= (u.creation_date + INTERVAL '1 month')::date
GROUP BY u.display_name
HAVING COUNT(oa.post_id)>100;

/*Задача 16: Вывеcти количество постов за 2008 год по месяцам. Отберать посты от пользователей, 
 которые зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре того же года. 
 Отсортировать таблицу по значению месяца по убыванию.*/

SELECT CAST(DATE_TRUNC('month', p.creation_date) AS date) AS month,
       COUNT(p.id)
FROM stackoverflow.posts AS p
WHERE p.user_id IN (SELECT DISTINCT u.id
                    FROM stackoverflow.users AS u
                    JOIN stackoverflow.posts AS p ON u.id=p.user_id
                    WHERE (u.creation_date::date BETWEEN '01-09-2008'::date AND '30-09-2008'::date)
                    AND u.id IN (SELECT DISTINCT p.user_id
                                 FROM stackoverflow.posts AS p
                                 WHERE p.creation_date::date BETWEEN '01-12-2008'::date AND '31-12-2008'::date))
GROUP BY month
ORDER BY month DESC;

/*Задача 17: Используя данные о постах, вывести несколько полей:
- идентификатор пользователя, который написал пост;
- дата создания поста;
- количество просмотров у текущего поста;
- сумма просмотров постов автора с накоплением.
Данные в таблице должны быть отсортированы по возрастанию идентификаторов пользователей, 
а данные об одном и том же пользователе — по возрастанию даты создания поста.*/

SELECT p.user_id,
       p.creation_date,
       p.views_count,
       SUM(p.views_count) OVER(PARTITION BY p.user_id ORDER BY p.creation_date ASC)
FROM stackoverflow.posts AS p
ORDER BY p.user_id ASC;

/*Задача 18: Сколько в среднем дней в период с 1 по 7 декабря 2008 года включительно 
пользователи взаимодействовали с платформой? Для каждого пользователя отобрать дни, 
в которые он или она опубликовали хотя бы один пост.*/

WITH ad AS
(SELECT p.user_id,
       COUNT(DISTINCT(CAST(DATE_TRUNC('day', p.creation_date) AS date))) AS active_days
FROM stackoverflow.posts AS p
WHERE p.creation_date::date BETWEEN '01-12-2008'::date AND '07-12-2008'::date 
GROUP BY p.user_id)

SELECT ROUND(AVG(active_days))
FROM ad;

/*Задача 19: 
На сколько процентов менялось количество постов ежемесячно с 1 сентября по 31 декабря 2008 года? 
Отобразить таблицу со следующими полями:
- номер месяца.
- количество постов за месяц.
- процент, который показывает, насколько изменилось количество постов в текущем месяце по сравнению с предыдущим.
Если постов стало меньше, значение процента должно быть отрицательным, если больше — положительным. 
Округлить значение процента до двух знаков после запятой.*/

WITH posts_by_month AS
(SELECT EXTRACT(MONTH FROM creation_date) AS month,
       COUNT(id)
FROM stackoverflow.posts
WHERE creation_date::date BETWEEN '01-09-2008'::date AND '31-12-2008'::date
GROUP BY month)

SELECT month,
       count,
       ROUND(((count::numeric/LAG(count) OVER(ORDER BY month)::numeric)*100-100),2)
FROM posts_by_month;

/*Задача 20: Найти пользователя, который опубликовал больше всего постов за всё время с момента регистрации. 
Вывести данные его активности за октябрь 2008 года в таком виде:
- номер недели;
- дата и время последнего поста, опубликованного на этой неделе.*/

SELECT DISTINCT (EXTRACT(WEEK FROM p.creation_date)) AS week,
       MAX(p.creation_date) OVER(PARTITION BY (EXTRACT(WEEK FROM p.creation_date)))
FROM stackoverflow.posts AS p
WHERE p.creation_date::date BETWEEN '01-10-2008'::date AND '31-10-2008'::date
AND p.user_id IN (SELECT cool_user.user_id
                  FROM (SELECT user_id,
                               COUNT(id)
                        FROM stackoverflow.posts
                        GROUP BY user_id
                        ORDER BY count DESC
                        LIMIT 1) AS cool_user);
                       



