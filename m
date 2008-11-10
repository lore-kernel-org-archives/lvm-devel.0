From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Nov 2008 13:41:44 -0000
Subject: LVM2/tools Makefile.in
Message-ID: <20081110134144.3709.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-11-10 13:41:44

Modified files:
	tools          : Makefile.in 

Log message:
	Fix lvm2.static build.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/tools/Makefile.in	2008/11/04 17:25:32	1.88
+++ LVM2/tools/Makefile.in	2008/11/10 13:41:43	1.89
@@ -119,7 +119,7 @@
 LIB_PTHREAD = @LIB_PTHREAD@
 lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm-static.o -static \
-		$(LDFLAGS) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+		-L$(interfacedir) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
 liblvm2cmd.a: $(top_srcdir)/lib/liblvm.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_srcdir)/lib/liblvm.a > $@


