    function q() {    
        var left = [];
        var right = [];
        var linesListClone = [];
        var queue = [];

        for (var i = 0; i < linesList.length; i++) {
            linesListClone.push(linesList[i]);
            left.push(linesList[i].name1);
            right.push(linesList[i].name2);
        }

        while (linesListClone.length != 0) {

            var startLength = linesListClone.length;

            for (var i = 0; i < linesListClone.length; i++) {

                var name1 = linesListClone[i].name1;
                var name2 = linesListClone[i].name2;

                if (left.indexOf(name2) == -1) {

                    if (queue.indexOf(name2) == -1) {
                        queue.push(name2);
                    }
                    
                    linesListClone.splice(i, 1);
                    left.splice(i, 1);
                    right.splice(i, 1);

                    if (left.indexOf(name1) == -1) {
                        queue.push(name1);
                    }

                    i--;
                }
            }

            if (linesListClone.length == startLength) {
                if (linesListClone.length > 0) {
                    var strInfo = "Can't insert: ";
                    for (var i = 0; i < linesListClone.length; i++) {
                        strInfo += linesListClone[i].name1;
                        if (i < linesListClone.length - 1) {
                            strInfo += ", ";
                        }
                        else {
                            strInfo += ";";
                        }
                    }
                    console.log(strInfo);
                }
                break;
            }
        }

        for (var i = 0; i < queue.length; i++) {
            console.log(i + 1 + ") " + queue[i]);
        }
    }


    var linesList = [
        {name1: 'Account', field1: 'type', name2: 'Contact', field2: 'lastname'},
        {name1: 'Account', field1: 'website', name2: 'Contact', field2: 'accountid'},
        {name1: 'Account', field1: 'ownerid', name2: 'Opportunity', field2: 'name'},
        {name1: 'Opportunity', field1: 'type', name2: 'Order', field2: 'name'},
        {name1: 'Order', field1: 'Contact__c', name2: 'Contact', field2: 'lastname3'},
        {name1: 'Case', field1: 'type', name2: 'Order', field2: 'type'}
    ];

    var model = [
        {
            Name : 'Account',
            Fields : [
                {
                    Name : 'NAME56789012345', Type : 'STRING'
                },
                {
                    Name : 'type', Type : 'PICKLIST'
                },
                {
                    Name : 'parentid', Type : 'REFERENCE'
                },
                {
                    Name : 'billingstreet', Type : 'TEXTAREA'
                },
                {
                    Name : 'accountnumber', Type : 'STRING', Required : true
                },
                {
                    Name : 'website', Type : 'URL'
                },
                {
                    Name : 'ownerid', Type : 'REFERENCE'
                }
            ]
        },
        {
            Name : 'Contact',
            Fields : [
                {
                    Name : 'firstname', Type : 'STRING'
                },
                {
                    Name : 'lastname', Type : 'STRING'
                },
                {
                    Name : 'lastname2', Type : 'STRING'
                },
                {
                    Name : 'lastname3', Type : 'STRING'
                },
                {
                    Name : 'lastname4', Type : 'STRING'
                },
                {
                    Name : 'lastname5', Type : 'STRING'
                },
                {
                    Name : 'lastname6', Type : 'STRING'
                },
                {
                    Name : 'accountid', Type : 'REFERENCE'
                }
            ]
        },
        {
            Name : 'Opportunity',
            Fields : [
                {
                    Name : 'name', Type : 'STRING', Required : true
                },
                {
                    Name : 'type', Type : 'PICKLIST'
                }
            ]
        },
        {
            Name : 'Case',
            Fields : [
                {
                    Name : 'name', Type : 'STRING', Required : true
                },
                {
                    Name : 'type', Type : 'PICKLIST'
                }
            ]
        },
        {
            Name : 'Order',
            Fields : [
                {
                    Name : 'name', Type : 'STRING', Required : true
                },
                {
                    Name : 'Contact__c', Type : 'REFERENCE', Required : true
                },
                {
                    Name : 'type', Type : 'PICKLIST'
                }
            ]
        }
    ];

    //var model = ['1', '2', '3'];
