

    var linesList = [
        {name1: 'Account', field1: 'type', name2: 'Contact', field2: 'lastname'},
        {name1: 'Account', field1: 'website', name2: 'Contact', field2: 'accountid'},
        {name1: 'Account', field1: 'ownerid', name2: 'Opportunity', field2: 'name'},
        {name1: 'Opportunity', field1: 'type', name2: 'Order', field2: 'name'},
        {name1: 'Order', field1: 'Contact__c', name2: 'Contact', field2: 'lastname4'},
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
