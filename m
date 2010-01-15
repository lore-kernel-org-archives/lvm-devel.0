From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Jan 2010 20:24:05 -0000
Subject: LVM2 ./WHATS_NEW man/Makefile.in
Message-ID: <20100115202405.6651.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-15 20:24:05

Modified files:
	.              : WHATS_NEW 
	man            : Makefile.in 

Log message:
	initial cmirrord man page
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1392&r2=1.1393
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2010/01/15 19:49:35	1.1392
+++ LVM2/WHATS_NEW	2010/01/15 20:24:04	1.1393
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Initial version of the cmirrord man page.
   Make cluster log communication structures architecture independant.
   Fix cluster log issues with in-memory bitmaps.
   Improve target type compatibility checking in _percent_run().
--- LVM2/man/Makefile.in	2009/10/02 19:10:36	1.28
+++ LVM2/man/Makefile.in	2010/01/15 20:24:05	1.29
@@ -32,7 +32,7 @@
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
 	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
-MAN8CLUSTER=clvmd.8
+MAN8CLUSTER=clvmd.8 cmirrord.8
 MAN8DM=dmsetup.8
 MAN5DIR=${mandir}/man5
 MAN8DIR=${mandir}/man8


