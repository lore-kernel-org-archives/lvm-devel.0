From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jan 2010 16:01:23 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20100105160123.1697.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-05 16:01:22

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Do not set precommitted flag in cache when precommitted metadata does not exist.
	
	The use_precommitted flag indicates, that we want to use precommitted metadata
	(used in suspend call to preload table with precommitted data).
	
	But if there are no such data, committed metadata are read but the cache
	still contains that precommitted flag.
	
	(The problem is that later possible drop_metadata call will not invalidate
	device in cache.)
	
	The wrong precommitted state is stored in on remote nodes during normal
	suspend/resume cycle _without_ vg_write/commit.
	
	Use the PRECOMMITTED status flag here instead (which is always set if using
	precommited metadata here).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1355&r2=1.1356
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.306&r2=1.307

--- LVM2/WHATS_NEW	2010/01/05 15:58:11	1.1355
+++ LVM2/WHATS_NEW	2010/01/05 16:01:22	1.1356
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Properly handle precommitted flag in cache when commited data only present.
   Resume renamed volumes in reverse order to preserve memlock pairing.
   Drop metadata cache after device was autorepaired and removed from VG.
   Remove missing flag in metadata if PV reappeared and is empty.
--- LVM2/lib/metadata/metadata.c	2009/12/18 12:45:41	1.306
+++ LVM2/lib/metadata/metadata.c	2010/01/05 16:01:22	1.307
@@ -2620,7 +2620,11 @@
 			if (!inconsistent_pvs) {
 				log_debug("Updating cache for PVs without mdas "
 					  "in VG %s.", vgname);
-				lvmcache_update_vg(correct_vg, use_precommitted);
+				/*
+				 * If there is no precommitted metadata, committed metadata
+				 * is read and stored in the cache even if use_precommitted is set
+				 */
+				lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
 
 				if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
 					return_NULL;
@@ -2721,7 +2725,11 @@
 			return_NULL;
 	}
 
-	lvmcache_update_vg(correct_vg, use_precommitted);
+	/*
+	 * If there is no precommitted metadata, committed metadata
+	 * is read and stored in the cache even if use_precommitted is set
+	 */
+	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
 
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */


