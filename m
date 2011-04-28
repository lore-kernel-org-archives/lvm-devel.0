From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Apr 2011 22:17:06 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20110428221706.25594.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-28 22:17:06

Modified files:
	test           : Makefile.in 

Log message:
	Add missing cleanup for vgimportclone script

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/test/Makefile.in	2011/04/21 17:42:58	1.55
+++ LVM2/test/Makefile.in	2011/04/28 22:17:06	1.56
@@ -106,6 +106,7 @@
 	for i in lvm $$(cat ../tools/.commands); do rm -f lib/$$i; done
 	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(RUN)) lvm2app.sh ; fi
 
-CLEAN_TARGETS += .lib-dir-stamp .test-stamp $(LIB) lib/dmsetup lib/clvmd lib/dmeventd
+CLEAN_TARGETS += .lib-dir-stamp .test-stamp $(LIB) \
+	lib/dmsetup lib/clvmd lib/dmeventd lib/vgimportclone
 
 .NOTPARALLEL:

