/**
 * @description       : 
 * @author            : Diksha
 * @group             : 
 * @last modified on  : 07-10-2024
 * @last modified by  : Diksha
**/
public with sharing class MovieController {

    private static final String OMDB_API_KEY = 'c25209b8';

    /**
    * @description searches movies by title, calls OMDb API
    * @author Diksha | 07-10-2024 
    * @param searchTerm 
    * @return List<MovieResult> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<MovieResult> searchMovies(String searchTerm) {
        List<MovieResult> results = new List<MovieResult>();

        String endpoint = 'https://www.omdbapi.com/?apikey=' + OMDB_API_KEY + '&type=movie&s=' + EncodingUtil.urlEncode(searchTerm, 'UTF-8');
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        try {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

                if (Boolean.valueOf(parsedResponse.get('Response').toString())) {
                    List<Object> searchResults = (List<Object>) parsedResponse.get('Search');
                    for (Object result : searchResults) {
                        Map<String, Object> movieInfo = (Map<String, Object>) result;
                        MovieResult movie = new MovieResult();
                        movie.title = String.valueOf(movieInfo.get('Title'));
                        movie.year = String.valueOf(movieInfo.get('Year'));
                        movie.poster = String.valueOf(movieInfo.get('Poster'));
                        movie.imdbID = String.valueOf(movieInfo.get('imdbID'));
                        results.add(movie);
                    }
                } else {
                    throw new AuraHandledException('No movies found for the search term');
                }
            } else {
                throw new AuraHandledException('Failed to fetch movies from OMDB API');
            }
        } catch (Exception e) {
            System.debug('Error fetching movies from OMDB API: ' + e.getMessage());
            throw new AuraHandledException('Error fetching movies from OMDB API: ' + e.getMessage());
        }
        return results;
    }

    /**
    * @description fetches movies details from the API
    * @author Diksha | 07-10-2024 
    * @param imdbId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMovieDetails(String imdbId) {
        Map<String, Object> movieDetails = new Map<String, Object>();

        String endpoint = 'https://www.omdbapi.com/?apikey=' + OMDB_API_KEY + '&type=movie&i=' + EncodingUtil.urlEncode(imdbId, 'UTF-8');
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        try {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                movieDetails = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            } else {
                throw new AuraHandledException('Failed to fetch movie details from OMDB API');
            }
        } catch (Exception e) {
            System.debug('Error fetching movie details from OMDB API: ' + e.getMessage());
            throw new AuraHandledException('Error fetching movie details from OMDB API: ' + e.getMessage());
        }

        return movieDetails;
    }

    /**
    * @description upserts movie records with watch later date
    * @author Diksha | 07-10-2024 
    * @param imdbId 
    * @param watchLaterDate 
    **/
    @AuraEnabled
    public static void markAsWatchLaterWithDate(String imdbId, Date watchLaterDate) {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Movie__c movie = getMovieByImdbId(imdbId, currentUser.Id);

        if (movie == null) {
            movie = createMovie(imdbId, currentUser.Id);
        }

        movie.Is_Watch_Later__c = true;
        movie.Watch_Later__c = watchLaterDate;
        upsert movie;
    }

    
    /**
    * @description marks movie as favorite and update the records
    * @author Diksha | 07-10-2024 
    * @param imdbId 
    **/
    @AuraEnabled
    public static void markAsFavorite(String imdbId) {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Movie__c movie = getMovieByImdbId(imdbId, currentUser.Id);

        if (movie == null) {
            movie = createMovie(imdbId, currentUser.Id);
        }

        movie.Is_Favorite__c = true;
        update movie;
    }

    /**
    * @description fetches movie by imdb id
    * @author Diksha | 07-10-2024 
    * @param imdbId 
    * @param userId 
    * @return Movie__c 
    **/
    private static Movie__c getMovieByImdbId(String imdbId, String userId) {
        List<Movie__c> movies = [
            SELECT Id, Watch_Later__c, Is_Favorite__c
            FROM Movie__c
            WHERE IMDB_Id__c = :imdbId AND User__c = :userId
            LIMIT 1
        ];
        return (movies.isEmpty()) ? null : movies[0];
    }

    /**
    * @description server side creation of new movie record
    * @author Diksha | 07-10-2024 
    * @param imdbId 
    * @param userId 
    * @return Movie__c 
    **/
    private static Movie__c createMovie(String imdbId, String userId) {
        Map<String, Object> movieDetails = getMovieDetails(imdbId);
        Movie__c movie = new Movie__c();
        movie.IMDB_Id__c = imdbId;
        movie.Name = String.valueOf(movieDetails.get('Title'));
        movie.Year__c = String.valueOf(movieDetails.get('Year'));
        movie.Poster__c = String.valueOf(movieDetails.get('Poster'));
        movie.IMDB_Rating__c = (movieDetails.get('imdbRating') != null) ? String.valueOf(movieDetails.get('imdbRating').toString()) : null;
        movie.User__c = userId;
        insert movie;
        return movie;
    }

    // Inner class to represent movie search results for LWC
    public class MovieResult {
        @AuraEnabled public String title;
        @AuraEnabled public String year;
        @AuraEnabled public String poster;
        @AuraEnabled public String imdbID;
    }
}