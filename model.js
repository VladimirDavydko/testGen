
    var model = [
        {
            Name : 'Account',
            Fields : [
                {
                    Name : 'NAME56789012345', Type : 'STRING', Required : true
                },
                {
                    Name : 'type', Type : 'PICKLIST'
                },
                {
                    Name : 'parentid', Type : 'REFERENCE', Required : true
                },
                {
                    Name : 'billingstreet', Type : 'TEXTAREA', Required : true
                },
                {
                    Name : 'accountnumber', Type : 'STRING', Required : true
                },
                {
                    Name : 'website', Type : 'URL', Required : true
                },
                {
                    Name : 'ownerid', Type : 'REFERENCE', Required : true
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
                    Name : 'lastname', Type : 'STRING', Required : true
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
                    Name : 'type', Type : 'PICKLIST'
                }
            ]
        }
    ];

    //var model = ['1', '2', '3'];
