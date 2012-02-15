From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2012 13:49:53 -0000
Subject: LVM2 ./WHATS_NEW lib/thin/thin.c
Message-ID: <20120215134953.12598.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-15 13:49:52

Modified files:
	.              : WHATS_NEW 
	lib/thin       : thin.c 

Log message:
	Initialize monitoring support only for thin pools

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2293&r2=1.2294
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2012/02/13 20:13:39	1.2293
+++ LVM2/WHATS_NEW	2012/02/15 13:49:51	1.2294
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Initialize monitoring support only for thin pools and skip thin volumes.
   Make conversion from a synced 'mirror' to 'raid1' not cause a full resync.
   Properly test buffer for unit check in units_to_bytes().
   Add configure --with-systemdsystemunitdir.
--- LVM2/lib/thin/thin.c	2012/01/25 21:54:00	1.45
+++ LVM2/lib/thin/thin.c	2012/02/15 13:49:52	1.46
@@ -602,7 +602,8 @@
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-		if (_get_thin_dso_path(cmd))
+		if ((reg_segtypes[i].flags & SEG_THIN_POOL) &&
+		    _get_thin_dso_path(cmd))
 			segtype->flags |= SEG_MONITORED;
 #  endif /* DMEVENTD */
 #endif


