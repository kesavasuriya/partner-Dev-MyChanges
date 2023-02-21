import { LightningElement, api, track } from 'lwc';

export default class PaginationLWC extends LightningElement {
    @api totalList;
    @track visibleRecords = [];
    recordSize = '5';         //No of records want to display
    totalPages = 0;
    currentPage = 1;
    previousbuttonDisable = false;
    nextbuttonDisable = false;
    @track sizeList = [];
    @api
    refreshCmp(changedList) {

        this.totalList = changedList;
        this.handlePagination();
    }

    connectedCallback() {

        this.doInit();

    }

    doInit() {

        this.sizeList = [{label : '5' , value : '5'},{label : '10' , value : '10'},{label : '20' , value : '20'},{label : '30' , value : '30'}];
        this.recordSize = '10'; 
        this.handlePagination();
    }

    handlePagination() {

        this.totalPages = 0;
        this.currentPage = 1;
        this.previousbuttonDisable = false;
        this.nextbuttonDisable = false;
        this.visibleRecords = [];
        if(this.totalList) {
            this.totalPages = Math.ceil(this.totalList.length/this.recordSize);
        }
        
        if(this.totalPages == 0) {
            
            this.currentPage = 0;
        }
        this. nextbuttonDisable = false;
        this.previousbuttonDisable = false;
        if(this.totalPages == 1 || this.totalPages == 0 ) {

            this. nextbuttonDisable = true;
            this.previousbuttonDisable = true;
        }
        if(this.currentPage == 1 || this.currentPage == 0) {

            this.previousbuttonDisable = true;
        }
        
        this.updateRecords();
    }
    
    handleChange(event) {

        this.recordSize = event.target.value;
        this.handlePagination();
    }

    previousHandler() {
        
        this.currentPage = this.currentPage - 1;
        this.nextbuttonDisable = false;
        
        if(this.currentPage > 1) {
 
            this.previousbuttonDisable = false;
            
        } else if (this.currentPage <= 1) {

            this.previousbuttonDisable = true;
        }
        this.updateRecords();
    }

    nextHandler() {

        this.currentPage = this.currentPage + 1;
        this.previousbuttonDisable = false;
        
        if(this.currentPage < this.totalPages) {

            this.nextbuttonDisable = false;
              
        } else if (this.currentPage >= this.totalPages) {

            this.nextbuttonDisable = true;
        }
        this.updateRecords();
    }

    updateRecords() {

        if(this.totalList != null) {

            const start = (this.currentPage - 1)*this.recordSize;
            const end = this.recordSize*this.currentPage;
            this.visibleRecords = this.totalList.slice(start,end);
            const paginationEvt = new CustomEvent('update',{
                detail:{
                    records:this.visibleRecords
                }
            });
            this.dispatchEvent(paginationEvt);
        } else {

            const paginationEvt = new CustomEvent('update',{
                detail:{
                    records:this.visibleRecords
                }
            });
            this.dispatchEvent(paginationEvt);
        }
        
    }
}