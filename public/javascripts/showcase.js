var Showcase = Class.create({
  initialize: function(trigger, content) {
    this.trigger  = $(trigger);
    this.showcase = $('showcase');
    this.replaced = false;
    this.showcaseContent = $('showcase-content');
    this.contentNode = $(content);
    this.contentNode.writeAttribute('id', 'showcase-content');
    var closeBtn = new Element('a', {'class': 'closebtn'});
    closeBtn.update("close");
    closeBtn.observe('click', function() {
      this.showcase.hide();
    }.bind(this));
    this.contentNode.appendChild(closeBtn);
    this.trigger.observe('click', this.revealShowcase.bind(this));
  },
  
  revealShowcase: function(event) {
    event.stop();
    var element = event.element();
    this.showcase.fire('showcase:called', {contentNode: this.contentNode});
    this.showcaseContent.update();
    this.showcaseContent.update(this.contentNode);
    this.showcase.appendChild(this.contentNode);
    this.contentNode.show();
    this.showcase.show();
  }
});