From: ben scott <benscott@nwlink.com>
Date: Mon, 21 Jun 2010 16:40:13 -0700
Subject: error using the lvm library in C++
Message-ID: <201006211640.13309.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I am still running into trouble using the lvm library. Following the example 
in lvm2app.h I tried:


    dm_list *vgnames;
    lvm_str_list *strl;

    vgnames = lvm_list_vg_names( lvm_pointer );

    dm_list_iterate_items(strl, vgnames) {
        qDebug() << QString( strl->str );
    }

I get this error:

masterlist.cpp:83: error: ?typeof? was not declared in this scope
masterlist.cpp:83: error: expected primary-expression before ?)? token
masterlist.cpp:83: error: expected primary-expression before ?)? token
masterlist.cpp:83: error: expected ?)? before numeric constant
masterlist.cpp:83: error: expected ?)? before ?;? token
etc...

Is it coming from the file libdevmapper.h?


