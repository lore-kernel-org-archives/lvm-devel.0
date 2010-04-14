From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Apr 2010 20:03:17 -0000
Subject: LVM2 ./WHATS_NEW scripts/Makefile.in
Message-ID: <20100414200317.11837.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-14 20:03:16

Modified files:
	.              : WHATS_NEW 
	scripts        : Makefile.in 

Log message:
	fix broken 'make install' for lvm_dump.sh

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1523&r2=1.1524
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2010/04/14 18:10:30	1.1523
+++ LVM2/WHATS_NEW	2010/04/14 20:03:15	1.1524
@@ -1,5 +1,6 @@
 Version 2.02.63 - 14th April 2010
 =================================
+  Rename lvm_dump.sh to lvmdump.sh.
   Allow incomplete mirror restore in lvconvert --repair upon insufficient space.
   Do not reset position in metadata ring buffer on vgrename and vgcfgrestore.
   Allow VGs with active LVs to be renamed.
--- LVM2/scripts/Makefile.in	2010/04/09 21:42:51	1.15
+++ LVM2/scripts/Makefile.in	2010/04/14 20:03:16	1.16
@@ -17,7 +17,7 @@
 
 include $(top_builddir)/make.tmpl
 
-SCRIPTS = lvm_dump.sh vgimportclone.sh
+SCRIPTS = lvmdump.sh vgimportclone.sh
 ifeq ("@FSADM@", "yes")
 	SCRIPTS += fsadm.sh
 endif


