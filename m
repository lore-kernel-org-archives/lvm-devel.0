From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Feb 2009 11:08:00 -0000
Subject: LVM2/tools Makefile.in
Message-ID: <20090217110800.18393.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-02-17 11:08:00

Modified files:
	tools          : Makefile.in 

Log message:
	Fix lvm.static build dependence (to properly propagate changes in libdevmapper).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/tools/Makefile.in	2008/11/14 20:59:57	1.90
+++ LVM2/tools/Makefile.in	2009/02/17 11:07:59	1.91
@@ -117,7 +117,7 @@
 		$(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic
 
 LIB_PTHREAD = @LIB_PTHREAD@
-lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm.a
+lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm.a  $(interfacedir)/libdevmapper.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm-static.o -static \
 		-L$(interfacedir) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 


