$(function () {

    // *******************************************************************
    // **      global variables and onload functionality                **
    // *******************************************************************

    var rightContainer = $('.rightContainer');
    var leftContainer = $('.leftContainer');
    // filling right container
    model.forEach(function(item, i) {
        attachItemToRightContainer(item.Name);
    });
    sortRightContainer();

    var rightFieldItem = $('.rightFieldItem').first();
    var itemHeight = parseInt(rightFieldItem.css('height')) + 3;
    var a = 0;
    var cursor = {x : 0, y : 0};
    var canvas = document.getElementById("canvas");
    var context = canvas.getContext("2d");

    $('.rightContainer').niceScroll({cursorwidth: '5px', autohidemode: false, zindex: 999});

    // *******************************************************************
    // **                        events                                 **
    // *******************************************************************

    // move item from left container to right
    leftContainer.dblclick(function(event){
    	var batya = $(getLeftParent(event.target));
    	if(batya.hasClass('leftItem')) {
    		var name = batya.children().first().html();
    		attachItemToRightContainer(name);
    		batya.parent().remove();
    		sortRightContainer();
    	}
        drawLines();
    });

    // need to fix
    rightContainer.bind('dragend', function(event){
		$(event.target).css('opacity', '1');
		var name = $(event.target).html();
		var leftItem = $(attachItemToLeftContainer(name)).parent();
		$(event.target).remove();
    	
    	var itemDragLength = parseInt(leftItem.css('width'));
    	var itemDragHeight = parseInt(leftItem.css('height'));

	    leftContainer.on('mousemove' , function(event){
		    leftContainer.unbind('mousemove');
	        leftItem.offset({
		    	top: event.pageY - itemDragHeight/2,
		    	left: event.pageX - itemDragLength/2
		    });
			resizeRightContainer(rightContainer.children().length, itemHeight);
	    });
    });

    rightContainer.bind('dragstart', function(event){
    	$(event.target).css('opacity', '0.5');
    });

    // bottom arrow functionality
    leftContainer.bind('click', function(event){
        if ($(event.target).hasClass('bottomArrow')) {
            var fieldsContainer = $(event.target).prev().children().last();
            var fieldsHolder = fieldsContainer.children().first();
            if (fieldsHolder.css('height') != '0px') {                
                $(event.target).attr('height', fieldsHolder.css('height'));
                $(event.target).attr('border-top', fieldsContainer.css('border-top'));
                fieldsContainer.css({'border-top': 'none'});
                fieldsHolder.css({'height': 0});
                $(event.target).css('background-image', 'url(images/arrow-down.png)');
            }
            else {
                $(event.target).css('background-image', 'url(images/arrow-top.png)');
                fieldsHolder.css('height', $(event.target).attr('height'));
                fieldsContainer.css('border-top', $(event.target).attr('border-top'));
            }
            drawLines();
        }
    });

    // dragging left container's item
    leftContainer.bind('mousedown', function(event){

        if(getLeftParent(event.target) == undefined) return;

        var elementToMove = getLeftParent(event.target).parentNode;

        elementToMove.style.zIndex = 1000;
        moveAt(event);
        var shiftX = event.pageX - $(elementToMove).offset().left;
        var shiftY = event.pageY - $(elementToMove).offset().top;

        function moveAt(event) {
            $(elementToMove).offset({
                top: event.pageY - shiftY,
                left: event.pageX - shiftX
            });
            drawLines();
        }

        document.onmousemove = function(event) {
            moveAt(event);
        }

        elementToMove.onmouseup = function(event) {
            document.onmousemove = null;
            elementToMove.onmouseup = null;

            var leftItem = getLeftParent(event.target);
            var name = $(leftItem).children().first().html();

            if (isOverRight($(leftItem))) {
                attachItemToRightContainer(name);
                $(leftItem).parent().remove();
                sortRightContainer();
            }
        }

        elementToMove.ondragstart = function() {
            return false;
        };
    });

    // pulling item from right containet to left
    rightContainer.bind('click', function(event){
        if($(event.target).hasClass('objectItem')) {
            var name = $(event.target).html();
            attachItemToLeftContainer(name);
            $(event.target).remove();
            resizeRightContainer(rightContainer.children().length, itemHeight);
        }
        drawLines();
    });

    // *******************************************************************
    // **                        methods                                **
    // *******************************************************************

    function resizeRightContainer(count, sizeItem) {
        var sizeComtainer = rightContainer.css('height');
        rightContainer.css('height', count*sizeItem + 30);
        if (count == 0) {
            rightContainer.css("visibility", "hidden");
        }
        else {
            rightContainer.css("visibility", "");
        }
        drawLines();
    }
    // cheking if left item is over right container
	function isOverRight(leftItem) {
		var r_x = rightContainer.offset().left;
		var r_y = rightContainer.offset().top;
		var r_z = r_y + parseInt(rightContainer.css('height'));

		var l_x = leftItem.offset().left + parseInt(leftItem.css('width'));
		var l_y = leftItem.offset().top;
		var l_z = leftItem.offset().top + parseInt(leftItem.css('height'));

		if (l_x > r_x && ((l_y < r_z && l_y > r_y) || (l_z < r_z && l_z > r_y) || (l_z > r_z && l_y < r_y))) {
			return true;
		}
	}

    function getLeftParent(target) {
    	var parents = $(target).parents();
    	for (var i = 0; i < parents.length; i++) {
    		if ($(parents[i]).hasClass('leftItem')) {
    			return parents[i];
    		}
    	}
    }

    function SortByName(a, b){
		var aName = a.toLowerCase();
		var bName = b.toLowerCase(); 
		return ((aName < bName) ? -1 : ((aName > bName) ? 1 : 0));
	}

	function sortRightContainer() {
		var childNodes = rightContainer.children();
		var nodesArray = [];
		for (var i = 0; i < childNodes.length; i++) {
			nodesArray.push($(childNodes[i]).html());
		}
		nodesArray.sort(SortByName);
		rightContainer.empty();
		nodesArray.forEach(function(item, i) {
	    	attachItemToRightContainer(item);
	    });
	    resizeRightContainer(nodesArray.length, itemHeight);
	}

    function attachItemToRightContainer(text) {
    	var contaner = createElement("objectItem noselect rightFieldItem", {name: "draggable", value: "true"});
    	$(contaner).html(text);
    	rightContainer.append(contaner);
        drawLines();
    }

    // getting object from model
    function getObjectByName(name) {
    	for (var i = 0; i < model.length; i++) {
	    	if(model[i].Name == name) {
	    		return {object : model[i], index: i};
	    	}
	    }
    }
    // doesn't work
    function showToolTip(item, text) {
        var messageBox = document.createElement('div');
        var triangle = document.createElement('div');
        var contaner = document.createElement('div');

        messageBox.className = "alert";
        messageBox.innerHTML = text;

        triangle.className = "triangle";
        contaner.className = "alert-contaner";
        contaner.appendChild(triangle);
        contaner.appendChild(messageBox);
        item.appendChild(contaner);

        setTimeout(function() { $(contaner).fadeOut(500, function() { contaner.remove(); }) }, 500);
    }

    function createElement(className, attribute) {
        var elem = document.createElement('div');
        elem.className = className;
        if (attribute != undefined) {
            var att = document.createAttribute(attribute.name);
            att.value = attribute.value;
            elem.setAttributeNode(att); 
        }
        return elem;
    }

    function attachItemToLeftContainer(text) {

        var dataObject = getObjectByName(text).object;
        var contaner            = createElement("objectItem leftItem noselect", {name: "name", value: text});
        var mainContaner        = createElement("mainContaner", {name: "draggable", value: "true"});
        var nameHolder          = createElement("nameHolder", undefined);
        var fieldHolder         = createElement("field");
        var leftFieldItemHolder = createElement("leftFieldItemHolder");
        var bottomArrow         = createElement("bottomArrow");

        mainContaner.onmouseover = function(event) {
            bottomArrow.style.visibility = 'visible';
        }
        mainContaner.onmouseleave = function(event) {
            bottomArrow.style.visibility = 'hidden';
        }

        $(nameHolder).html(text);

        // creating "field-type" section
        for (var i = 0; i < dataObject.Fields.length; i++) {
            var fieldName = createElement("fieldItem leftFieldItem", {name: "name", value: dataObject.Fields[i].Name});
            if (dataObject.Fields[i].Name.length < 13) {
                $(fieldName).html(dataObject.Fields[i].Name);
            }
            else {
                $(fieldName).html(dataObject.Fields[i].Name.substring(0, 10) + '...');
                //need to add toolTip
                /*$(fieldName).on('mouseover', function(event){
                    showToolTip(fieldName, dataObject.Fields[i].Name);
                });*/
            }

            var fieldType = createElement("fieldItem rightFieldItem");
            $(fieldType).html(dataObject.Fields[i].Type);

            leftFieldItemHolder.appendChild(fieldName);
            leftFieldItemHolder.appendChild(fieldType);
        }

        fieldHolder .appendChild(leftFieldItemHolder);
        contaner    .appendChild(nameHolder);
        contaner    .appendChild(fieldHolder);
        mainContaner.appendChild(contaner);
        mainContaner.appendChild(bottomArrow);
        leftContainer.append(mainContaner);

        var leftItems = $('.leftItem');
        var lastLeftItem = leftItems.first();

        for (var i = 1; i < leftItems.length; i++) {
            if ($(leftItems[i]).offset().top > $(lastLeftItem).offset().top) {
                lastLeftItem = $(leftItems[i]);
            }
        }

        $(mainContaner).css('position', 'absolute');

        if ($('.leftItem').length > 1) {
            var offset = lastLeftItem.offset();
            var height = parseInt(lastLeftItem.css('height'));
            $(mainContaner).offset({ top: offset.top + height + 30, left: offset.left });
        }

        return contaner;
    }

    function drawLines() {

        if (context == undefined) return;

        context.clearRect(0, 0, canvas.width, canvas.height);

        for(var i = 0; i < linesList.length; i++) {

            var container1 = $("[name='" + linesList[i].name1 + "']");
            var container2 = $("[name='" + linesList[i].name2 + "']");

            var field1 = container1.find("[name='" + linesList[i].field1 + "']");
            var field2 = container2.find("[name='" + linesList[i].field2 + "']");

            if (field1.length == 0 || field2.length == 0) continue;

            var width1 = parseInt(field1.parent().css('width')) - 10;
            var width2 = parseInt(field2.parent().css('width'));

            if ($("[name='" + linesList[i].name1 + "']").find(".leftFieldItemHolder").css('height') != '0px') {
                var x1 = field1.parent().offset().left + width1;
                var y1 = field1.offset().top - 20;
            }
            else {
                var x1 = container1.offset().left + width1;
                var y1 = container1.offset().top - 14;
            }

            if ($("[name='" + linesList[i].name2 + "']").find(".leftFieldItemHolder").css('height') != '0px') {
                var x2 = field2.parent().offset().left - 14;
                var y2 = field2.offset().top - 20;
            }
            else {
                var x2 = container2.offset().left - 14;
                var y2 = container2.offset().top - 14;
            }

            width1 += 12;

            drowLine(x1, y1, x2, y2, width1, width2);
        }

        function drowLine(x1, y1, x2, y2, width1, width2) {
            context.lineWidth = 3;
            context.strokeStyle = "#333";
            context.beginPath();
            context.moveTo(x1, y1);
            if (x1 <= x2) {
                context.bezierCurveTo((x1 - x2)/2 + x2, y1, (x1 - x2)/2 + x2, y2, x2, y2);
            }
            else {
                x2 += width2;
                if (x1 < x2) {
                    context.bezierCurveTo(-(x1 - x2)/2 + x2, y1, -(x1 - x2)/2 + x2, y2, x2, y2);
                }
                else {
                    x1 -= width1;
                    x2 -= width2;
                    context.moveTo(x1, y1);
                    if (x2 + width2 > x1){
                        context.bezierCurveTo(-(x1 - x2)/2 + x2, y1, -(x1 - x2)/2 + x2, y2, x2, y2);
                    }
                    else {
                        x2 += width2;
                        context.bezierCurveTo((x1 - x2)/2 + x2, y1, (x1 - x2)/2 + x2, y2, x2, y2);
                    }
                }
            }
            context.stroke();

            drawCircle(context, x1, y1);
            drawCircle(context, x2, y2);
        }

        function drawCircle(context, x, y) {
            context.beginPath();
            context.arc(x, y, 3, 0, 2 * Math.PI, false);
            context.fillStyle = 'green';
            context.fill();
            context.lineWidth = 1;
            context.strokeStyle = '#003300';
            context.stroke();
        }
    }

});
