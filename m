From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 11:13:00 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-persistent ...
Message-ID: <20120228111300.4118.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 11:12:59

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-persistent.c 
	lib/metadata   : metadata.c 

Log message:
	Test dm_hash_insert() failures mem failures

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2323&r2=1.2324
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.490&r2=1.491

--- LVM2/WHATS_NEW	2012/02/28 11:06:56	1.2323
+++ LVM2/WHATS_NEW	2012/02/28 11:12:58	1.2324
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Test dm_hash_insert() failures in filter-persistent.c and fid_add_mda().
   Ensure clvmd message is always \0 terminated after read.
   Better detection of missing dmeventd fifo connection (2.02.93).
   Add some close() and dev_close() error path backtraces.
--- LVM2/lib/filters/filter-persistent.c	2011/12/18 21:56:04	1.52
+++ LVM2/lib/filters/filter-persistent.c	2012/02/28 11:12:58	1.53
@@ -292,7 +292,10 @@
 	if (MAJOR(dev->dev) == dm_major()) {
 		if (!l)
 			dm_list_iterate_items(sl, &dev->aliases)
-				dm_hash_insert(pf->devices, sl->str, PF_GOOD_DEVICE);
+				if (!dm_hash_insert(pf->devices, sl->str, PF_GOOD_DEVICE)) {
+					log_error("Failed to hash device to filter.");
+					return 0;
+				}
 		if (!device_is_usable(dev)) {
 			log_debug("%s: Skipping unusable device", dev_name(dev));
 			return 0;
@@ -305,7 +308,10 @@
 		l = pf->real->passes_filter(pf->real, dev) ?  PF_GOOD_DEVICE : PF_BAD_DEVICE;
 
 		dm_list_iterate_items(sl, &dev->aliases)
-			dm_hash_insert(pf->devices, sl->str, l);
+			if (!dm_hash_insert(pf->devices, sl->str, l)) {
+				log_error("Failed to hash alias to filter.");
+				return 0;
+			}
 	}
 
 	return (l == PF_BAD_DEVICE) ? 0 : 1;
--- LVM2/lib/metadata/metadata.c	2012/02/28 11:10:45	1.490
+++ LVM2/lib/metadata/metadata.c	2012/02/28 11:12:58	1.491
@@ -4283,8 +4283,11 @@
 				    full_key, sizeof(full_key)))
 		return_0;
 
-	dm_hash_insert(fid->metadata_areas_index,
-		       full_key, mda);
+	if (!dm_hash_insert(fid->metadata_areas_index,
+			    full_key, mda)) {
+		log_error("Failed to hash mda.");
+		return 0;
+	}
 
 	return 1;
 }


