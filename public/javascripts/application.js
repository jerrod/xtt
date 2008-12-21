document.observe('dom:loaded', function() {
  // Make inputs with the class name hintable use their title attribute
  // for a hint.
  $$('input.hintable').invoke('hintable');
  
  // When pressing the return key, post the form.
  var statusMessage = $('status_code_and_message');
  if(statusMessage)
    statusMessage.observe('keypress', function(event) {
      if(event.keyCode === Event.KEY_RETURN) {
        this.up('form').submit();
      }
    });
    
  	$$('span.livetime').each(function(span) {
  	  var UTCDate = span.readAttribute('title');
  	  span.update(Date.differenceFromNow(Date.parseUTC(UTCDate)).join(":"));
  	  new Timer(span, function(time) {
    	  this.element.update(time.join(":"));
    	});
  	});
  
  /**
   * Grab all the day and time badges and if the user has their browser 
   * wide enough, show them on page load.  Also, when the user resizes 
   * their browser window, run this check again.
   */
  var dayBadges = $$('p.day-break');
  var timeBadges = $$('span.time-span');
  var showing = false;
  if(document.viewport.getWidth() > 1175) {
    [timeBadges, dayBadges].invoke('invoke', 'show');
    showing = true;
  }
  Event.observe(window, 'resize', function() {
    var vpWidth = document.viewport.getWidth();
    if(vpWidth > 1175) {
      showing = true;
      [timeBadges, dayBadges].invoke('invoke', 'show');      
    } else if(vpWidth < 1175 && showing) {
      [timeBadges, dayBadges].invoke('invoke', 'hide');            
    } 
  });

  /**
   * Format any UTC timestamp on the page to the users local timezone.
   * Use timeAgoInWords by default unless the class 'formatted' in supplied.
   * FIXME: This is to specific, modify so format can be specified.
   */
  $$('span.timestamp').each(function(span) {
		var utc = Date.parseUTC(span.innerHTML);
		var rel = span.readAttribute('rel');
		span.update(rel == 'words' ? utc.timeAgoInWords() : utc.strftime(Date.strftimeFormats[rel]))
  });
  
  $$('.text_field_options').each(function(ele) {
    new TextFieldOptions(ele);
  });
  
});

TextFieldOptions = Class.create();
TextFieldOptions.prototype = {
  initialize: function(ele) {
    this.element = $(ele)
    this.values = []
    this.targetField = $(this.element.id.replace('_options',''))
    this.element.childElements().each(function(opt) {
      opt.observe('click', this.onOptionClick.bind(this))
      this.values.push(opt.innerHTML)
    }.bind(this))
    this.targetField.observe('keyup', this.onValueChange.bind(this))
    this.getValue()
  },
  onOptionClick: function(event) {
    Event.stop(event)
    this.selectOption(event.element())
    this.setValue(event.element().innerHTML)
  },
  onValueChange: function(event) {
    Event.stop(event)
    this.getValue()
  },
  deselectOptions: function() {
    var current = this.element.down('.selected')
    if (current != null) {current.removeClassName('selected')}
  },
  selectOption: function(ele) {
    this.deselectOptions()
    if (ele != null) { ele.addClassName('selected') }
  },
  getValue: function() {
    i = this.values.indexOf(this.targetField.value)
    this.selectOption(this.element.childElements()[i])
  },
  setValue: function(val) {
    this.targetField.value = val
  }
};

(function() {
  // Get users Timezone offset and set it in a cookie.
  var date = new Date();
  var offset = date.getTimezoneOffset();
  Cookie.set({tzoffset: offset});
})();

var Timer = Class.create({
  initialize: function(element, callback) {
    this.callback = callback || Prototype.K;
    this.element = $(element);
    if(!this.element) return;
    new PeriodicalExecuter(this.incrementTimer.bind(this), 1);
  },
  
  incrementTimer: function() {
    var UTCDate = this.element.readAttribute('title');
    var diff = Date.differenceFromNow(Date.parseUTC(UTCDate));
    this.callback.call(this, diff);
  }
});


Element.addMethods('INPUT', {
  /**
   * Add hints to input elements.
   * Add the class name hintable to all elements that you want to hint.
   * Use the title attribute of the input to provide the hint.
   */
  hintable: function(element) {
    var element = $(element), title = element.readAttribute('title');
    element.setValue(title);
    element.observe('focus', function() {
      element.removeClassName('hintable');
      if($F(element) != title) return;
      element.setValue('');
    });
    element.observe('blur', function() {
      if($F(element) == "") {
        element.addClassName('hintable');
        element.setValue(title);
      }
    });
  }
});

Object.extend(Date.prototype, {
  /**
   * Given a formatted string, replace the necessary items and return.
   * Example: Time.now().strftime("%B %d, %Y") => February 11, 2008
   * @param {String} format The formatted string used to format the results
   */
  strftime: function(format) {
    var day = this.getDay(), month = this.getMonth();
    var hours = this.getHours(), minutes = this.getMinutes();
    function pad(num) { return num.toPaddedString(2); };

    return format.gsub(/\%([aAbBcdHImMpSwyY])/, function(part) {
      switch(part[1]) {
        case 'a': return $w("Sun Mon Tue Wed Thu Fri Sat")[day]; break;
        case 'A': return $w("Sunday Monday Tuesday Wednesday Thursday Friday Saturday")[day]; break;
        case 'b': return $w("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec")[month]; break;
        case 'B': return $w("January February March April May June July August September October November December")[month]; break;
        case 'c': return this.toString(); break;
        case 'd': return pad(this.getDate()); break;
        case 'H': return pad(hours); break;
        case 'I': return pad((hours + 12) % 12); break;
        case 'm': return pad(month + 1); break;
        case 'M': return pad(minutes); break;
        case 'p': return hours > 12 ? 'PM' : 'AM'; break;
        case 'S': return pad(this.getSeconds()); break;
        case 'w': return day; break;
        case 'y': return pad(this.getFullYear() % 100); break;
        case 'Y': return this.getFullYear().toString(); break;
      }
    }.bind(this));
  },
  
  timeAgoInWords: function() {
    var relative_to = (arguments.length > 0) ? arguments[1] : new Date();
    return Date.distanceOfTimeInWords(this, relative_to, arguments[2]);
  }
});

Object.extend(Date, {
  /**
   * Common formats passed to strftime
   */
  strftimeFormats: {
    time: "%I:%M %p",
  	day:  "%B %d",
  	short: '%b %d',
  	dayName: "%A"
  },
  
  /**
   * Get an array back with hours, minutes and seconds from now to a future date.
   * @param {Date} to The future time used to get equate the difference
   * @return {Array} [hours, minutes, seconds]
   */
  differenceFromNow: function(to) {
    var seconds = Math.ceil((new Date().getTime() - to.getTime()) / 1000);
    var hours   = Math.floor(seconds / 3600).toPaddedString(2);
    seconds     = Math.floor(seconds % 3600);
    var minutes = Math.floor(seconds / 60).toPaddedString(2);
    seconds = (seconds % 60).toPaddedString(2);
    return [hours, minutes, seconds];
  },
  
  /**
   * Parse a string date and return a UTC date
   * @param {String} value Formatted date string
   * @return Date
   */
  parseUTC: function(value) {
    var localDate = new Date(value);
    var utcSeconds = Date.UTC(localDate.getFullYear(), localDate.getMonth(), localDate.getDate(), localDate.getHours(), localDate.getMinutes(), localDate.getSeconds())
    return new Date(utcSeconds);
  },
  
  /**
   * Return the distance of time in words between two Dates
   * Example: '5 days ago', 'about an hour ago'
   * @param {Date} fromTime The start date to use in the calculation
   * @param {Date} toTime The end date to use in the calculation
   * @param {Boolean} Include the time in the output
   */
  distanceOfTimeInWords: function(fromTime, toTime, includeTime) {
    var delta = parseInt((toTime.getTime() - fromTime.getTime()) / 1000);
    if(delta < 60) {
        return 'less than a minute ago';
    } else if(delta < 120) {
        return 'about a minute ago';
    } else if(delta < (45*60)) {
        return (parseInt(delta / 60)).toString() + ' minutes ago';
    } else if(delta < (120*60)) {
        return 'about an hour ago';
    } else if(delta < (24*60*60)) {
        return 'about ' + (parseInt(delta / 3600)).toString() + ' hours ago';
    } else if(delta < (48*60*60)) {
        return '1 day ago';
    } else {
      var days = (parseInt(delta / 86400)).toString();
      if(days > 5) {
        var fmt  = '%B %d'
        if(toTime.getYear() != fromTime.getYear()) { fmt += ', %Y' }
        if(includeTime) fmt += ' %I:%M %p'
        return fromTime.strftime(fmt);
      } else {
        return days + " days ago"
      }
    }
  }
});