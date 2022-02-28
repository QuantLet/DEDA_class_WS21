 # Spatial Berlin Rent Price Analysis
> This is a project prepared during the Digital Economy and Decision Analytics - Blockchain and Cryptocurrency Seminar class at Humboldt University of Berlin.
> Check out the presentation in this repo

## Motivation and Goals
The motivation of this project came to me after I moved to Berlin and started to look more closely into the rent prices of the local market. Naturally, it was hard to get a grasp what are the rules on a market in a new country, not to even mention in a new currency. Is this apartment too expensive for what it provides? Is that a good deal, am I being ripped off or perhaps missing out on a great price? Hard to say when you can't rely on some form of passive subcounsoius price-compas that has been built up over many years. But even if you would be comfortable with any form of new currency and new prices for apartments you still might lack the idea whether an area is a place that you would enjoy living in or now. Hence I had the idea to do a research on this topic and try to figure out some form of benchmark to look up to that would help me out. In my head the benchmark should account both for the characteristics of the apartments but also what kind of area is the apartment located in. 

While thinking about the idea how to perform this kind of research I figured that I would want to have an equation that would look something like the following:

**Market Price = Weight * Model Price + Residuals**

By deriving a model for the prices based on historical data based on various apartment characteristics I could then analyse the infrastructure of Berlin on order to grade the areas by saturation by objects of interest like parks, shops etc. and create a flexible weight index that would serve me as a discount factor for the modelled price in order to account for the surrounding areas. The better the area the higher the price one would be okay with paying for that apartment, and the other way around the worse the area gets the bigger the discount a person would want for an apartment of the same parameters. This got me thining that the remaining resuduals could be viewed as a landlord premium factor. If my weighted model price would be less than the market price that would mean that the landlord has included a premium into that listed price, and in the opposite direction perhaps heor she could have undervalued the property.

***Hence the goal of my research was to create a stable benchmark model to check for price fairness and then to use that info to analyze the proposed landlord premiums.***

Some of the graphs form the research:
All polygons used:
![image](https://user-images.githubusercontent.com/92677707/154821403-cc1f8230-bbe5-4099-9720-6c54f82a78ba.png)

All multipolygons used:
![image](https://user-images.githubusercontent.com/92677707/154821417-38b49781-158a-4313-acfc-e1c12fce5a55.png)

Distribution between areas of the following infrastructural objects:
Gyms, sports objects, etc.
![image](https://user-images.githubusercontent.com/92677707/154821448-485fa9d7-6c3b-4832-9167-ecd3d24c86e9.png)

Restaurants, bars, etc.
![image](https://user-images.githubusercontent.com/92677707/154821465-939197ae-1e90-47a2-a388-4eae74e3f1fd.png)



Sightseeing, museums, etc.
![image](https://user-images.githubusercontent.com/92677707/154821476-0f774806-8cef-4f79-a2d0-ece34c0f837d.png)

Cinemas, night clubs, etc.
![image](https://user-images.githubusercontent.com/92677707/154821493-cf8eed1a-40dc-4ed7-b1ac-548d026415ef.png)

Doctors, pharmacies, etc.
![image](https://user-images.githubusercontent.com/92677707/154821515-d059060b-fa6a-439c-9766-db05c62fdd42.png)

Kitas, playgrounds, etc.
![image](https://user-images.githubusercontent.com/92677707/154821521-605f72df-f7b2-4c14-9eaa-5e0ed6dd8079.png)

Parks, dog parks, etc.
![image](https://user-images.githubusercontent.com/92677707/154821528-f1d80eda-4270-449c-8221-725e3c124317.png)

Shops, grocery stores, etc.
![image](https://user-images.githubusercontent.com/92677707/154821545-064ced78-c190-4392-8701-6998b1fe2aa6.png)

S-Bahn, U-Bahn, etc.
![image](https://user-images.githubusercontent.com/92677707/154821568-6f8a48f8-e6eb-4701-97a3-6779c99680da.png)

Initial model used for apartment prices:
![image](https://user-images.githubusercontent.com/92677707/154821587-2bc1fcee-4d78-4879-9b09-d6a604643ae7.png)
![image](https://user-images.githubusercontent.com/92677707/154821692-68e6326d-1f26-4a47-acac-bf6049896ac2.png)


Cleaned model:

<img width="842" alt="image" src="https://user-images.githubusercontent.com/92677707/154821618-842c6c29-2be4-4a47-8dfe-8745bfc071b2.png">

Diagnostic plots:
![image](https://user-images.githubusercontent.com/92677707/154821819-3887502b-5857-4470-bbe7-5940b3e0a5c5.png)


Distance measurement, scoring and normalization. The distance measurement chosen for this project is the Euclidian distance. The following formula was used to calculate the scores:

<img width="878" alt="Screenshot 2022-02-19 at 23 49 30" src="https://user-images.githubusercontent.com/92677707/154821722-397f7dd4-a459-4c4c-a89c-64deb087815f.png">

Here 10 units (meters) are added to the distance in order to set the maximum score achievable for the measurement.
After that the scores are rescaled via min-max normalisation in order to get the weights:

<img width="511" alt="Screenshot 2022-02-19 at 23 50 12" src="https://user-images.githubusercontent.com/92677707/154821735-a1741376-9585-4dda-9408-45931a802361.png">

Here 1/2 is added in order to make the minimum weight 0.5 and the maximum 1.5 (half-price discount or extra payment)

The results:
![image](https://user-images.githubusercontent.com/92677707/154821749-4638400c-fe3f-4c4a-9764-2fda94eb71a3.png)

Evaluating the landlord premiums:
<img width="887" alt="Screenshot 2022-02-19 at 23 51 01" src="https://user-images.githubusercontent.com/92677707/154821764-5f1d6f84-c92e-4074-ab47-e64e9fb38048.png">

<img width="833" alt="Screenshot 2022-02-19 at 23 51 36" src="https://user-images.githubusercontent.com/92677707/154821775-c499b4de-e927-4da6-befb-f1a06528bfc3.png">

Key takeaways:
- The size of the apartment, the presence of a kitchen, and a lift can be used as a solid foundation for a price check for the rent prices of apartments
- Infrastructural-wise Berlin tends to be a very single-centroid oriented city with few other areas of concentration emerging from different infrastructural objects
- Overall in Berlin, rent prices are not under- or overvalued based on the model used in this research, prices seem to be landlord premiums seem to be fairly normally distributed
- Overvalued properties seem to be more concentrated further outside the city centre and the more undervalued properties are located closer to the city center which can point to the lack of prestige living in the centre of the city

