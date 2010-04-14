From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Apr 2010 16:13:35 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20100414161335.24317.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-14 16:13:34

Modified files:
	test/api       : Makefile.in 

Log message:
	Add missing readline linkage to lvm2app test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/test/api/Makefile.in	2010/04/09 21:34:31	1.13
+++ LVM2/test/api/Makefile.in	2010/04/14 16:13:34	1.14
@@ -43,7 +43,7 @@
 OBJECTS = $(test_OBJECTS) $(vgtest_OBJECTS)
 
 test: $(test_OBJECTS) $(DEPLIBS)
-	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)
 
 vgtest: $(vgtest_OBJECTS) $(DEPLIBS)
 	$(CC) -o vgtest $(vgtest_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)


