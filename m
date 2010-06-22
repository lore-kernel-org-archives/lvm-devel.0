From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 20:39:24 -0400
Subject: error using the lvm library in C++
In-Reply-To: <201006211640.13309.benscott@nwlink.com>
References: <201006211640.13309.benscott@nwlink.com>
Message-ID: <1277167164.10260.37.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-06-21 at 16:40 -0700, ben scott wrote:
> I am still running into trouble using the lvm library. Following the example 
> in lvm2app.h I tried:
> 
> 
>     dm_list *vgnames;
>     lvm_str_list *strl;
> 
>     vgnames = lvm_list_vg_names( lvm_pointer );
> 
>     dm_list_iterate_items(strl, vgnames) {
>         qDebug() << QString( strl->str );
>     }
> 
> I get this error:
> 
> masterlist.cpp:83: error: ?typeof? was not declared in this scope
> masterlist.cpp:83: error: expected primary-expression before ?)? token
> masterlist.cpp:83: error: expected primary-expression before ?)? token
> masterlist.cpp:83: error: expected ?)? before numeric constant
> masterlist.cpp:83: error: expected ?)? before ?;? token
> etc...
> 
> Is it coming from the file libdevmapper.h?
> 

Can you post your code?

Attached is a sample C++ hack that works for me with upstream lvm + dm
CVS.  Make sure you are pointing at the right header files and linking
to the correct libraries.


-------------- next part --------------
A non-text attachment was scrubbed...
Name: masterlist.cpp
Type: text/x-c++src
Size: 812 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100621/2b221678/attachment.bin>
