From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 Jun 2008 11:49:47 -0000
Subject: LVM2 ./WHATS_NEW tools/vgchange.c
Message-ID: <20080612114947.31490.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-06-12 11:49:46

Modified files:
	.              : WHATS_NEW 
	tools          : vgchange.c 

Log message:
	Fix vgchange to not activate mirror leg and log volumes directly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.899&r2=1.900
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/WHATS_NEW	2008/06/11 12:14:41	1.899
+++ LVM2/WHATS_NEW	2008/06/12 11:49:45	1.900
@@ -1,6 +1,8 @@
 Version 2.02.39 -
 ================================
-
+  Fix vgchange to not activate mirror leg and log volumes directly.
+  Fix test directory clean up in make distclean.
+ 
 Version 2.02.38 - 11th June 2008
 ================================
   Fix tracking of validity of PVs with no mdas in lvmcache.
--- LVM2/tools/vgchange.c	2008/04/10 17:09:32	1.64
+++ LVM2/tools/vgchange.c	2008/06/12 11:49:46	1.65
@@ -66,10 +66,14 @@
 		if ((lv->status & SNAPSHOT) || lv_is_cow(lv))
 			continue;
 
-		/* Can't deactive a pvmove or log LV */
+		/* Only request activation of mirror LV */
+		if ((lv->status & MIRROR_IMAGE) || (lv->status & MIRROR_LOG))
+			continue;
+
+		/* Can't deactivate a pvmove LV */
 		/* FIXME There needs to be a controlled way of doing this */
 		if (((activate == CHANGE_AN) || (activate == CHANGE_ALN)) &&
-		    ((lv->status & PVMOVE) || (lv->status & MIRROR_LOG)))
+		    ((lv->status & PVMOVE) ))
 			continue;
 
 		if (activate == CHANGE_AN) {


