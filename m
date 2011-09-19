From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 12:50:18 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20110919125018.8120.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 12:50:17

Modified files:
	test           : Makefile.in 

Log message:
	Add link for fsadm script
	
	Prepare to enabling t-fsadm.sh test

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/test/Makefile.in	2011/08/31 11:31:58	1.57
+++ LVM2/test/Makefile.in	2011/09/19 12:50:17	1.58
@@ -101,6 +101,7 @@
 	ln -fs "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
 	ln -fs "$(abs_top_builddir)/daemons/lvmetad/lvmetad" lib/lvmetad
 	ln -fs "$(abs_top_builddir)/scripts/vgimportclone.sh" lib/vgimportclone
+	ln -fs "$(abs_top_builddir)/scripts/fsadm.sh" lib/fsadm
 	touch $@
 
 clean:


