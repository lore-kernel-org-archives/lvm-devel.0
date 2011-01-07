From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 13:07:10 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20110107130710.25105.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 13:07:10

Modified files:
	test/api       : Makefile.in 

Log message:
	Remove *.t in test/api's make clean target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/test/api/Makefile.in	2010/12/14 23:20:59	1.19
+++ LVM2/test/api/Makefile.in	2011/01/07 13:07:10	1.20
@@ -59,3 +59,6 @@
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status test/api/Makefile
+
+clean:
+	rm -f *.t


