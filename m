From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Apr 2011 17:42:59 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20110421174259.3152.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2011-04-21 17:42:58

Modified files:
	test           : Makefile.in 

Log message:
	Add vgimportclone symlink for nightly test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/test/Makefile.in	2011/04/19 15:28:17	1.54
+++ LVM2/test/Makefile.in	2011/04/21 17:42:58	1.55
@@ -99,6 +99,7 @@
 	ln -s "$(abs_top_builddir)/tools/dmsetup" lib/dmsetup
 	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" lib/clvmd
 	ln -s "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
+	ln -s "$(abs_top_builddir)/scripts/vgimportclone.sh" lib/vgimportclone
 	touch $@
 
 clean:


