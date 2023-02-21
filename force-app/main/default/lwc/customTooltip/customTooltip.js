import { LightningElement, api } from "lwc";
export default class CustomTooltip extends LightningElement {
  @api customCss;
  @api contentValue;
  top;
  left;
  position;
  isCssChanged = false;
  elemHeight;

  @api get cssProperty() {
    return (
      "position:" +
      this.position +
      ";" +
      "top:" +
      this.top +
      "px;left:" +
      this.left +
      "px;"
    );
  }

  set cssProperty(cssProperties) {
    this.isCssChanged = true;
    this.top = cssProperties.top;
    this.left = cssProperties.left;
    this.position = cssProperties.position;
  }

  renderedCallback() {
    if (this.isCssChanged) {
      const divElement = this.template.querySelector(".slds-popover");
      this.elemHeight = divElement.offsetHeight;
      this.top = this.top - this.elemHeight / 2;
    }

    this.isCssChanged = false;
  }
}