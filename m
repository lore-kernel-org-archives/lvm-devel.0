From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Mar 2010 23:05:21 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20100331230521.3093.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-31 23:05:21

Modified files:
	test           : Makefile.in 

Log message:
	Missed to convert T -> SCRIPTS

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/test/Makefile.in	2010/03/29 15:53:11	1.32
+++ LVM2/test/Makefile.in	2010/03/31 23:05:20	1.33
@@ -55,7 +55,7 @@
 bin/harness: $(srcdir)/harness.c .bin-dir-stamp
 	$(CC) -o bin/harness $<
 
-init.sh: $(srcdir)/Makefile.in $(srcdir)/test-utils.sh .bin-dir-stamp bin/not bin/harness $(T)
+init.sh: $(srcdir)/Makefile.in .bin-dir-stamp bin/not bin/harness $(SCRIPTS)
 	rm -f $@-t $@
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t


