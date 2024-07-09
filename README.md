# mpower_movie_assesment

Overview :

This application leverages the OMDb API to search and organize movie details within Salesforce. It allows users to search for movies by title, view details, mark movies as "Watch Later" with a specific date, and add movies to favorites. The app enhances user experience by combining data from OMDb API with personalized movie lists stored in Salesforce.

Features :

Search Movies: Search movies and view details like title, year, poster, and IMDb rating.
Organize Movies: Mark movies as "Watch Later" and set a specific date for viewing.
Favorite Movies: Add movies to favorites for quick access.
Integration: Seamlessly integrates with OMDb API for movie data retrieval.

Usage :

Search: Enter a movie title to search and view results.
Actions: Use buttons to mark movies as "Watch Later" or add them to favorites.
Notifications: Users receive notifications on the day a movie is set for "Watch Later".


Installation : 

To run this project in your system, do the following:

1. Clone this repository in your local

2. Authorize Dev Hub
   sfdx force:auth:web:login -d -a myhuborg

3. Create a scratch org using the config/project-scratch-def.json file and provide it with an alias
   sfdx force:org:create -s -f config/project-scratch-def.json -a <scratchOrgName>

4. Now, push the code to the scratch org
   sfdx force:source:push

How to Run : 

1. Go to the Movie tab
2. Click on Edit page and then add the MovieSearchComponent from custom component
3. Now, enjoy the feature with searching for movies such as : Harry Potter, Titanic, and so on
