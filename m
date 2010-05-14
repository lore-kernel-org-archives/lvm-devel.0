From: agk@sourceware.org <agk@sourceware.org>
Date: 14 May 2010 13:36:56 -0000
Subject: LVM2/daemons/dmeventd Makefile.in
Message-ID: <20100514133656.5924.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-14 13:36:56

Modified files:
	daemons/dmeventd: Makefile.in 

Log message:
	Fix static build.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/daemons/dmeventd/Makefile.in	2010/05/11 08:57:02	1.43
+++ LVM2/daemons/dmeventd/Makefile.in	2010/05/14 13:36:56	1.44
@@ -62,7 +62,7 @@
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
-	dmeventd.o $(DL_LIBS) $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
+	dmeventd.o $(DL_LIBS) $(LVMLIBS) $(LIBS) $(STATIC_LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig


