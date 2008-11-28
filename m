From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Nov 2008 15:51:40 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20081128155140.26223.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-28 15:51:40

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Suppress 'duplicate PV' message when it's only a cache update not a real
	duplicate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/lib/cache/lvmcache.c	2008/11/27 18:13:51	1.62
+++ LVM2/lib/cache/lvmcache.c	2008/11/28 15:51:40	1.63
@@ -713,9 +713,8 @@
 	if (((dm_hash_lookup(_pvid_hash, pvid)) == info) &&
 	    !strcmp(info->dev->pvid, pvid))
 		return 1;
-	if (*info->dev->pvid) {
+	if (*info->dev->pvid)
 		dm_hash_remove(_pvid_hash, info->dev->pvid);
-	}
 	strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid));
 	if (!dm_hash_insert(_pvid_hash, pvid, info)) {
 		log_error("_lvmcache_update: pvid insertion failed: %s", pvid);
@@ -1140,11 +1139,15 @@
 			//else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				 //dm_is_dm_major(MAJOR(dev->dev)))
 				 //
-			else
+			else if (!strcmp(pvid_s, existing->dev->pvid)) 
 				log_error("Found duplicate PV %s: using %s not "
 					  "%s", pvid, dev_name(dev),
 					  dev_name(existing->dev));
 		}
+		if (strcmp(pvid_s, existing->dev->pvid)) 
+			log_debug("Updating pvid cache to %s (%s) from %s (%s)",
+				  pvid_s, dev_name(dev),
+				  existing->dev->pvid, dev_name(existing->dev));
 		/* Switch over to new preferred device */
 		existing->dev = dev;
 		info = existing;


