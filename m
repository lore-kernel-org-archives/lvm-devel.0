From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 12:26:03 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20110107122603.22389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 12:26:02

Modified files:
	test           : Makefile.in 

Log message:
	Fix up the make clean target in test/.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/test/Makefile.in	2011/01/05 00:16:18	1.50
+++ LVM2/test/Makefile.in	2011/01/07 12:26:02	1.51
@@ -101,6 +101,9 @@
 
 clean:
 	rm -rf bin .lib-dir-stamp .test-stamp
+	rm -f $(LIB)
+	rm -f lib/dmsetup lib/clvmd lib/dmeventd
+	for i in lvm $$(cat ../tools/.commands); do rm -f lib/$$i; done
 	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(RUN)) lvm2app.sh ; fi
 
 distclean: clean


