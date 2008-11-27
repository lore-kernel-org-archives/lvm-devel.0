From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Nov 2008 18:13:51 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20081127181351.27924.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-27 18:13:51

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Don't skip updating pvid hash when lvmcache_info struct got swapped.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1000&r2=1.1001
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/WHATS_NEW	2008/11/24 13:33:16	1.1000
+++ LVM2/WHATS_NEW	2008/11/27 18:13:50	1.1001
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Don't skip updating pvid hash when lvmcache_info struct got swapped.
   Add tinfo to termcap search path for pld-linux.
   Fix startup race in clvmd.
   Generate Red Hat clvmd startup script at configuration time with correct paths.
--- LVM2/lib/cache/lvmcache.c	2008/11/03 22:14:27	1.61
+++ LVM2/lib/cache/lvmcache.c	2008/11/27 18:13:51	1.62
@@ -707,7 +707,11 @@
 
 static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 {
-	if (!strcmp(info->dev->pvid, pvid))
+	/*
+	 * Nothing to do if already stored with same pvid.
+	 */
+	if (((dm_hash_lookup(_pvid_hash, pvid)) == info) &&
+	    !strcmp(info->dev->pvid, pvid))
 		return 1;
 	if (*info->dev->pvid) {
 		dm_hash_remove(_pvid_hash, info->dev->pvid);


