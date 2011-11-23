From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2011 13:03:57 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20111123130357.4461.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-23 13:03:57

Modified files:
	test           : Makefile.in 

Log message:
	Swap condition order
	
	Swap condtion so the make line does not return 'false'.
	Remove cleanup of lvm2api.sh since it is not created anymore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/test/Makefile.in	2011/11/23 12:21:41	1.64
+++ LVM2/test/Makefile.in	2011/11/23 13:03:57	1.65
@@ -106,7 +106,7 @@
 	touch $@
 
 clean:
-	test "$(srcdir)" != . && $(RM) $(RUN_BASE) lvm2app.sh
+	test "$(srcdir)" = . || $(RM) $(RUN_BASE)
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
 	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone


