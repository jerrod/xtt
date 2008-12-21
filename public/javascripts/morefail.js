/*


Makes 32 bit PNG's transparency work in Internet Explorer 6
 * Dependent on Prototype 1.6
 * Works on img elements and on background images of elements
 * Image tiling will not work
 * Refer to the readme

Example Usages:
 
 $('yourPNG').pngHack();
 $$('div#fixMe', 'img#andMe', 'img.andUsTo').invoke('pngHack');
 
*/

document.observe('dom:loaded', function() {
  $('logo').pngHack();
});

Element.addMethods("IMG", {
  pngHack: function(el){
    var el = $(el);
    var transparentGifPath = '/images/btns/ghost.gif';
    if (Prototype.Browser.IE){
      /* if it's an img and a png */
      if ((el.match('img')) && (el.src.include('png'))){
        var alphaImgSrc = el.src;
        var sizingMethod = 'scale';
        el.src = transparentGifPath;
        el.setStyle({width: el.getWidth() + 'px', height:el.getHeight() + 'px'});
        /* if it's an element with a background png */
      } else if (el.getStyle('backgroundImage').include('png')){
        var bgColor = el.getStyle('backgroundColor') || '';
        var elBg = el.getStyle('backgroundImage');
        var alphaImgSrc = elBg.slice(5, elBg.length - 2);
        var sizingMethod = 'crop';
        el.setStyle({ 'background': bgColor + transparentGifPath });
      }
      if (alphaImgSrc) el.runtimeStyle.filter = 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src="#{al}",sizingMethod="#{sz}")'.interpolate({ al: alphaImgSrc, sz: sizingMethod });
    }
    return el;
  }
});