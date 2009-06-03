From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jun 2009 11:40:24 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20090603114024.18257.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-03 11:40:23

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-string.c 

Log message:
	Make mempool optional in dm_split_lvm_name()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.269&r2=1.270
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW_DM	2009/05/22 15:23:11	1.269
+++ LVM2/WHATS_NEW_DM	2009/06/03 11:40:23	1.270
@@ -1,5 +1,6 @@
 Version 1.02.33 - 
 ===============================
+  Make mempool optional in dm_split_lvm_name().
 
 Version 1.02.32 - 21st May 2009
 ===============================
--- LVM2/libdm/libdevmapper.h	2009/05/20 09:52:37	1.87
+++ LVM2/libdm/libdevmapper.h	2009/06/03 11:40:23	1.88
@@ -819,6 +819,8 @@
 /*
  * Break up the name of a mapped device into its constituent
  * Volume Group, Logical Volume and Layer (if present).
+ * If mem is supplied, the result is allocated from the mempool.
+ * Otherwise the strings are changed in situ.
  */
 int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer);
--- LVM2/libdm/libdm-string.c	2008/11/03 18:59:59	1.10
+++ LVM2/libdm/libdm-string.c	2009/06/03 11:40:23	1.11
@@ -93,7 +93,7 @@
 int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer)
 {
-	if (!(*vgname = dm_pool_strdup(mem, dmname)))
+	if (mem && !(*vgname = dm_pool_strdup(mem, dmname)))
 		return 0;
 
 	_unquote(*layer = _unquote(*lvname = _unquote(*vgname)));


