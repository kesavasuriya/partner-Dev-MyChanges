import { LightningElement,api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';

let isDownFlag, 
    isDotFlag = false,
    prevX = 0,
    currX = 0,
    prevY = 0,
    currY = 0;            
       
let x = "#0000A0"; 
let y = 1.5;       

let canvasElement, ctx; 
let dataURL,convertedDataURI;

export default class CapturequestedEventignature extends UtilityBaseElement {
    @api resubmissionimage;
    connectedCallback() {
        this.template.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.template.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.template.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.addEventListener('mouseout', this.handleMouseOut.bind(this));
    }

   
    renderedCallback(){
        canvasElement = this.template.querySelector('canvas');
        ctx = canvasElement.getContext("2d");

    }
    
   
    handleMouseMove(event){
        this.searchCoordinatesForEvent('move', event);      
    }
    
  
    handleMouseDown(event){
        this.searchCoordinatesForEvent('down', event);         
    }
    
    
    handleMouseUp(event){
        this.searchCoordinatesForEvent('up', event);       
    }

   
    handleMouseOut(event){
        this.searchCoordinatesForEvent('out', event);         
    }
    
   
    handleSaveClick(){    
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = "#FFF"; 
        ctx.fillRect(0,0,canvasElement.width, canvasElement.height); 
        dataURL = canvasElement.toDataURL("image/png");
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
        let signImg = '<img src="data:image/jpeg;base64,'+convertedDataURI+'">';
        const signature = new CustomEvent('handlesign', {detail : signImg});
        this.dispatchEvent(signature);
        this.title = 'Success';
            this.message = 'Your signature is confirmed';
            this.type =  'success';
            this.fireToastMsg();
            
    }

    handleClearClick(){
        ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);          
    }

    searchCoordinatesForEvent(requestedEvent, event){
        event.preventDefault();
        if (requestedEvent === 'down') {
            this.setupCoordinate(event);           
            isDownFlag = true;
            isDotFlag = true;
            if (isDotFlag) {
                this.drawDot();
                isDotFlag = false;
            }
        }
        if (requestedEvent === 'up' || requestedEvent === "out") {
            isDownFlag = false;
        }
        if (requestedEvent === 'move') {
            if (isDownFlag) {
                this.setupCoordinate(event);
                this.redraw();
            }
        }
    }

    
    setupCoordinate(eventParam){
        const clientRect = canvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;
        currX = eventParam.clientX -  clientRect.left;
        currY = eventParam.clientY - clientRect.top;
    }

   
    redraw() {
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = x; 
        ctx.lineWidth = y;        
        ctx.closePath(); 
        ctx.stroke(); 
    }
    
    drawDot(){
        ctx.beginPath();
        ctx.fillStyle = x; 
        ctx.fillRect(currX, currY, y, y); 
        ctx.closePath();
    }
    disconnectedCallback() {
        this.template.removeEventListener('mousemove', this.handleMouseMove.bind(this));
        this.template.removeEventListener('mousedown', this.handleMouseDown.bind(this));
        this.template.removeEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.removeEventListener('mouseout', this.handleMouseOut.bind(this));
    }
}