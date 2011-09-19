From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 15:54:16 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20110919155416.29372.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 15:54:15

Modified files:
	test           : Makefile.in 

Log message:
	Ensure  fsadm.sh is executable
	
	When the srcdir == builddir we get the link on non-exectable file.
	So make always sure fsadm.sh is executable script file.
	
	Add cleanup target for lib/fsadm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/test/Makefile.in	2011/09/19 12:50:17	1.58
+++ LVM2/test/Makefile.in	2011/09/19 15:54:15	1.59
@@ -101,6 +101,7 @@
 	ln -fs "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
 	ln -fs "$(abs_top_builddir)/daemons/lvmetad/lvmetad" lib/lvmetad
 	ln -fs "$(abs_top_builddir)/scripts/vgimportclone.sh" lib/vgimportclone
+	chmod +x "$(abs_top_builddir)/scripts/fsadm.sh"
 	ln -fs "$(abs_top_builddir)/scripts/fsadm.sh" lib/fsadm
 	touch $@
 
@@ -109,6 +110,6 @@
 	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(RUN)) lvm2app.sh ; fi
 
 CLEAN_TARGETS += .lib-dir-stamp .test-stamp $(LIB) \
-	lib/dmsetup lib/clvmd lib/dmeventd lib/vgimportclone
+	lib/dmsetup lib/clvmd lib/dmeventd lib/vgimportclone lib/fsadm
 
 .NOTPARALLEL:


