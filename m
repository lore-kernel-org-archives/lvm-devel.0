From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:48:39 -0000
Subject: LVM2 lib/report/report.c man/lvs.8.in
Message-ID: <20100113014839.17685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:48:38

Modified files:
	lib/report     : report.c 
	man            : lvs.8.in 

Log message:
	Report merging snapshot as 'S' instead of 's':
	This is useful for when the snapshot is still active and merging hasn't
	started yet; it shows a merge is pending.  Once merging starts the
	merging snapshot will be hidden but can still be displayed with 'lvs -a'
	
	Report snapshot origin with merging snapshot as 'O' instead of 'o':
	Before merge starts this shows that a merge is pending.  While merging
	the snapshot will be hidden, 'O' enables a user to see that there is a
	snapshot merging.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/lib/report/report.c	2010/01/07 14:37:12	1.107
+++ LVM2/lib/report/report.c	2010/01/13 01:48:38	1.108
@@ -305,8 +305,12 @@
 	else if (lv->status & VIRTUAL)
 		repstr[0] = 'v';
 	/* Origin takes precedence over Mirror */
-	else if (lv_is_origin(lv))
-		repstr[0] = 'o';
+	else if (lv_is_origin(lv)) {
+		if (lv->merging_snapshot)
+			repstr[0] = 'O';
+		else
+			repstr[0] = 'o';
+	}
 	else if (lv->status & MIRRORED) {
 		if (lv->status & MIRROR_NOTSYNCED)
 			repstr[0] = 'M';
@@ -319,9 +323,12 @@
 			repstr[0] = 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
-	else if (lv_is_cow(lv))
-		repstr[0] = 's';
-	else
+	else if (lv_is_cow(lv)) {
+		if (find_cow(lv)->status & SNAPSHOT_MERGE)
+			repstr[0] = 'S';
+		else
+			repstr[0] = 's';
+	} else
 		repstr[0] = '-';
 
 	if (lv->status & PVMOVE)
--- LVM2/man/lvs.8.in	2009/10/26 14:37:09	1.11
+++ LVM2/man/lvs.8.in	2010/01/13 01:48:38	1.12
@@ -68,9 +68,9 @@
 The lv_attr bits are: 
 .RS
 .IP 1 3
-Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin, (p)vmove,
-(s)napshot, invalid (S)napshot, (v)irtual, mirror (i)mage, mirror (I)mage
-out-of-sync, under (c)onversion
+Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin,
+(O)rigin with merging snapshot, (s)napshot, merging (S)napshot, (p)vmove,
+(v)irtual, mirror (i)mage, mirror (I)mage out-of-sync, under (c)onversion
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only
 .IP 3 3


