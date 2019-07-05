1. Map of restaurants across United States

    ```sql
    select state,sum(is_open) as cnt
    from restaurants
    group by state;
    ```

    ![](https://github.com/chancethecoder/bigdata-general-practice/blob/master/assets/picture1.png)


2. Which Cities Have The Highest Number Of Restaurants?

    ```sql
    select city, count(*) as cnt from restaurants
    group by city;
    ```

3. Top 15 Sub-Categories Of Restaurants

    ```sql
    with t as (select business_id,category
    from restaurants lateral view explode(categories) tbl as category),
    t2 as (select category, count(*) as cnt
        from t
        group by category)
    select *
    from t2
    order by cnt desc
    limit 15;
    ```

4. Distribution of ratings vs categories

    ```sql
    with t as (select stars, category
        from restaurants lateral view explode(categories) tbl as category)
    select * from t;
    ```

5. What ratings do the majority of restaurants have?

6. Rating distribution in restaurant reviews

    ```sql
    select stars, count(*) as cnt
    from review
    group by stars;
    ```

7. Which restaurants get bad vs good reviews?

    * good reviews

        ```sql
        with t as (select v.stars, r.categories
            from review v join restaurants r on v.business_id = r.business_id
            where v.stars > 3),
        t1 as (select category, count(*) as cnt
            from t lateral view explode(categories) tbl as category
            group by category)
        select * from t1;
        ```

    * bad reviews

        ```sql
        with t as (select v.stars, r.categories
            from review v join restaurants r on v.business_id = r.business_id
            where v.stars < 3),
        t1 as (select category, count(*) as cnt
            from t lateral view explode(categories) tbl as category
            group by category)
        select * from t1;
        ```

8. Which restaurants have the most reviews?

    ```sql
    with t as (select r.name, count(*) as cnt
        from review v join restaurants r on v.business_id = r.business_id
        group by r.name)
    select * from t;
    ```

9. What number of yelp users are elite? Do they rate differently than non -elite users