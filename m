From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Dec 2010 22:26:47 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20101212222647.11529.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-12 22:26:47

Modified files:
	test/api       : Makefile.in 

Log message:
	Remove a redundant %.o: %.c rule from test/api/Makefile.in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/test/api/Makefile.in	2010/12/12 21:08:00	1.17
+++ LVM2/test/api/Makefile.in	2010/12/12 22:26:47	1.18
@@ -51,9 +51,6 @@
 test: $(test_OBJECTS) $(DEPLIBS)
 	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)
 
-%.o: $(srcdir)/%.c
-	$(CC) -o $@ $(CFLAGS) $(INCLUDES)
-
 %.t: %.o $(DEPLIBS)
 	$(CC) -o $@ $(<) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
 


