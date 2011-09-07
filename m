From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Sep 2011 13:42:01 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/pv.c
Message-ID: <20110907134201.14968.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-07 13:42:00

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : pv.c 

Log message:
	Terminate pv_attr field correctly. (2.02.86)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2099&r2=1.2100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2011/09/07 09:48:49	1.2099
+++ LVM2/WHATS_NEW	2011/09/07 13:42:00	1.2100
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Terminate pv_attr field correctly. (2.02.86)
   Fix 'not not' typo in pvcreate man page.
   Improve man page style for fsadm, lvreduce, lvremove, lvrename, lvresize.
   Support break for vgchange and vgrefresh operation.
--- LVM2/lib/metadata/pv.c	2011/06/29 14:56:33	1.10
+++ LVM2/lib/metadata/pv.c	2011/09/07 13:42:00	1.11
@@ -190,7 +190,7 @@
 {
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 3))) {
+	if (!(repstr = dm_pool_zalloc(mem, 4))) {
 		log_error("dm_pool_alloc failed");
 		return NULL;
 	}
@@ -198,6 +198,7 @@
 	repstr[0] = (pv->status & ALLOCATABLE_PV) ? 'a' : '-';
 	repstr[1] = (pv->status & EXPORTED_VG) ? 'x' : '-';
 	repstr[2] = (pv->status & MISSING_PV) ? 'm' : '-';
+
 	return repstr;
 }
 


