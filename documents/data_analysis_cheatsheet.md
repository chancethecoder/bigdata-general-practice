1. Map of restaurants across United States

    ```sql
    SELECT
      state,
      count (business_id) number_restaurants FROM restaurants_df
    GROUP BY state
    ORDER BY number_restaurants DESC
    LIMIT 20
    ```
    ```scala
    val USRestaurantsDF = restaurantsDF
        .groupBy("state")
        .count()
        .withColumnRenamed("count", "num_restaurants")
        .orderBy(desc("num_restaurants"))

    USRestaurantsDF.show
    ```

2. Which Cities Have The Highest Number Of Restaurants?

    ```sql
    SELECT
      city,
      count(business_id) number_city FROM restaurants_df
    GROUP BY city
    ORDER BY number_city DESC
    LIMIT 20
    ```
    ```scala
    val city_restDF = restaurantsDF
        .groupBy("city")
        .count()
        .withColumnRenamed("count","num_city")
        .orderBy(desc("num_city"))

    city_restDF.show()
    ```

3. Top 15 Sub-Categories Of Restaurants

    ```sql
    SELECT
      e.cat_exploded category,
      count(e.cat_exploded) number FROM exploded_df e JOIN restaurants_df re
    ON e.business_id = re.business_id
    WHERE e.cat_exploded not in ("Restaurants","Food")
    GROUP BY e.cat_exploded
    ORDER BY number DESC
    LIMIT 15
    ```
    ```scala
    // column expression
    val t15JoinDF = explodedDF
        .join(restaurantsDF, explodedDF("business_id") === restaurantsDF("business_id"))
    val t15JoinFilterDF = t15JoinDF
        .filter(!explodedDF("cat_exploded").isin("Restaurants","Food"))
        .select(explodedDF("cat_exploded"))
    val t15groupDF = t15JoinFilterDF
        .groupBy(explodedDF("cat_exploded"))
        .count()
        .withColumnRenamed("count","num_subcat")
        .orderBy(desc("num_subcat"))
        .limit(20)

    t15groupDF.show()

    // or chaining
    val t15JoinDF = explodedDF
        .join(restaurantsDF, explodedDF("business_id") === restaurantsDF("business_id"))
        .filter(!explodedDF("cat_exploded").isin("Restaurants","Food"))
        .select(explodedDF("cat_exploded"))
        .groupBy(explodedDF("cat_exploded"))
        .count()
        .withColumnRenamed("count","num_subcat")
        .orderBy(desc("num_subcat"))
        .limit(20)

    t15JoinDF.show()
    ```

4. Distribution of ratings vs categories

    ```sql
    SELECT
      e.cat_exploded category,
      e.stars stars,
      count(e.cat_exploded) number 
    FROM exploded_df e JOIN restaurants_df re
    ON e.business_id = re.business_id
    WHERE
      e.cat_exploded in ("Nightlife","Bars","Sandwiches","Fast Food","American (Traditional)")
    GROUP BY e.cat_exploded, e.stars
    ORDER BY stars ASC
    ```
    ```scala
    // column expression
    val rateCatDF = explodedDF
        .join(restaurantsDF, explodedDF("business_id") === restaurantsDF("business_id"))
        .filter(explodedDF("cat_exploded").isin("Nightlife","Bars","Sandwiches","Fast Food","American (Traditional)"))
        .select(explodedDF("cat_exploded"), explodedDF("stars"))
        .groupBy(explodedDF("cat_exploded"), explodedDF("stars"))
        .count()
        .withColumnRenamed("count","number")
        .orderBy("stars", "number")

    rateCatDF.show()
    ```

5. What ratings do the majority of restaurants have?

    ```sql
    SELECT
      stars,
      count (business_id) number_restaurants
    FROM restaurants_df 
    GROUP BY stars 
    ORDER BY stars
    ```
    ```scala
    // column expression
    val rRatingsDF = restaurantsDF.select("stars")
        .groupBy("stars")
        .count()
        .withColumnRenamed("count", "num_restaurants")

    rRatingsDF.show()
    ```

6. Rating distribution in restaurant reviews

    ```sql
    SELECT
      stars, 
      round(count(stars) * 100.0 / sum(count(stars)) over(),2) stars_distribution 
    FROM revRest_df
    GROUP BY stars 
    ORDER BY stars
    ```

7. Which restaurants get bad vs good reviews?

    * good reviews

        ```sql
        SELECT
          e.cat_exploded category, 
          count(e.cat_exploded) good_reviews_number 
        FROM exploded_df e JOIN restaurants_df re
        ON e.business_id = re.business_id
        WHERE
          e.cat_exploded NOT IN ("Restaurants","Food") AND re.stars>=4
        GROUP BY e.cat_exploded
        ORDER BY good_reviews_number DESC
        LIMIT 10
        ```
        ```scala
        //column expression
        val goodRevDF = explodedDF
            .join(restaurantsDF, explodedDF("business_id") === restaurantsDF("business_id"))
            .filter(!explodedDF("cat_exploded").isin("Restaurants","Food") && (restaurantsDF("stars") >= 4) )
            .select(explodedDF("cat_exploded"))
            .groupBy(explodedDF("cat_exploded"))
            .count()
            .withColumnRenamed("count","num_good")
            .orderBy(desc("num_good"))
            .limit(10)

        goodRevDF.show()
        ```

    * bad reviews

        ```sql
        SELECT
          e.cat_exploded category, count(e.cat_exploded) bad_reviews_number 
        FROM exploded_df e JOIN restaurants_df re
        ON e.business_id = re.business_id
        WHERE
          e.cat_exploded NOT IN ("Restaurants","Food") 
          AND re.stars<=2 GROUP BY e.cat_exploded
        ORDER BY bad_reviews_number DESC
        LIMIT 10
        ```
        ```scala
        // column expression
        val badRevDF = explodedDF
            .join(restaurantsDF, explodedDF("business_id") === restaurantsDF("business_id"))
            .filter(!explodedDF("cat_exploded").isin("Restaurants","Food") && (restaurantsDF("stars") <= 2) )
            .select(explodedDF("cat_exploded"))
            .groupBy(explodedDF("cat_exploded"))
            .count()
            .withColumnRenamed("count","num_bad")
            .orderBy(desc("num_bad"))
            .limit(10)

        badRevDF.show()
        ```

8. Which restaurants have the most reviews?

    ```sql
    SELECT
      name Name,
      city City,
      review_count Number_of_Reviews, 
      stars Stars,
      attributes.restaurantspricerange2 Price_Range
    FROM restaurants_df
    ORDER BY review_count DESC
    LIMIT 15
    ```
    ```scala
    // column expression
    val mostReviewDF = restaurantsDF
        .select($"name".alias("Name"), $"city".alias("City"), 
            $"review_count".alias("Number_of_Reviews"), 
            $"stars".alias("Stars"), 
            $"attributes.restaurantspricerange2".alias("Price_Range"))
        .orderBy(desc("Number_of_Reviews"))
        .limit(15)

    mostReviewDF.show()
    ```

9. What number of yelp users are elite? Do they rate differently than non -elite users

    * average rating by all user

        ```sql
        SELECT round(avg(average_stars),2) avg_rating_user
        FROM user_df
        ```

    * average rating by elite user

        ```sql
        SELECT round(avg(average_stars),2) avg_rating_elite
        FROM elite_df
        ```

    * count number of elite users by year

        ```sql
        SELECT elite_year Year, count(distinct user_id) Elite_Users FROM elite_df
        GROUP BY elite_year
        ORDER BY elite_year ASC
        ```

    * count average reviews by elite users by year

        ```sql
        SELECT elite_year Year, round(avg(average_stars),2) Avg_Rating 
        FROM elite_df
        GROUP BY Year
        ORDER BY Avg_Rating ASC
        ```