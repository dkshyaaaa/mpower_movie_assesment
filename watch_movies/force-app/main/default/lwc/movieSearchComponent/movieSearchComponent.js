import { LightningElement, track } from 'lwc';

//apex methods
import searchMovies from '@salesforce/apex/MovieController.searchMovies';
import markAsWatchLaterWithDate from '@salesforce/apex/MovieController.markAsWatchLaterWithDate';
import markAsFavorite from '@salesforce/apex/MovieController.markAsFavorite';

export default class MovieSearchComponent extends LightningElement {
    @track searchTerm = '';
    @track searchResults = [];
    @track error;
    watchLaterDates = {};

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearch() {
        searchMovies({ searchTerm: this.searchTerm })
            .then(result => {
                this.searchResults = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.searchResults = [];
                console.error('Error fetching movies: ', error);
            });
    }

    handleViewDetails(event) {
        const imdbId = event.currentTarget.dataset.imdbid;
        //can be handled to view details in a separate child lwc
    }

    handleWatchLaterDateChange(event) {
        const imdbId = event.target.dataset.imdbid;
        const watchLaterDate = event.target.value;
        this.watchLaterDates[imdbId] = watchLaterDate;
    }

    handleAddToWatchLater(event) {
        const imdbId = event.currentTarget.dataset.imdbid;
        const watchLaterDate = this.watchLaterDates[imdbId];

        if (watchLaterDate) {
            markAsWatchLaterWithDate({ imdbId, watchLaterDate })
                .then(() => {
                    console.log('Added to Watch Later with desired Date');
                })
                .catch(error => {
                    console.error('Error adding to Watch Later: ', error);
                });
        } else {
            console.error('Watch Later Date is not set');
        }
    }

    handleAddToFavorites(event) {
        const imdbId = event.currentTarget.dataset.imdbid;
        markAsFavorite({ imdbId })
            .then(() => {
                console.log('Added to Favorites');
            })
            .catch(error => {
                console.error('Error adding to Favorites: ', error);
            });
    }
}
