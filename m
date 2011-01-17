From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jan 2011 15:18:11 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20110117151811.20511.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-17 15:18:10

Modified files:
	test           : Makefile.in 

Log message:
	Remove -f from list of targets for cleanup
	
	rm -f is already in used for this cleanup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/test/Makefile.in	2011/01/13 14:58:59	1.52
+++ LVM2/test/Makefile.in	2011/01/17 15:18:10	1.53
@@ -104,6 +104,6 @@
 	for i in lvm $$(cat ../tools/.commands); do rm -f lib/$$i; done
 	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(RUN)) lvm2app.sh ; fi
 
-CLEAN_TARGETS += .lib-dir-stamp .test-stamp -f $(LIB) lib/dmsetup lib/clvmd lib/dmeventd
+CLEAN_TARGETS += .lib-dir-stamp .test-stamp $(LIB) lib/dmsetup lib/clvmd lib/dmeventd
 
 .NOTPARALLEL:


