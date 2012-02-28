From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 14:23:43 -0000
Subject: LVM2 ./WHATS_NEW lib/raid/raid.c lib/replicato ...
Message-ID: <20120228142343.28585.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 14:23:42

Modified files:
	.              : WHATS_NEW 
	lib/raid       : raid.c 
	lib/replicator : replicator.c 
	lib/thin       : thin.c 

Log message:
	Revert free of allocated segtype
	
	lvm_register_segtype takes ownership of segtype and call destructor
	for it in error path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2324&r2=1.2325
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW	2012/02/28 11:12:58	1.2324
+++ LVM2/WHATS_NEW	2012/02/28 14:23:41	1.2325
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Revert free of allocated segtype in init segment error path (2.02.89).
   Test dm_hash_insert() failures in filter-persistent.c and fid_add_mda().
   Ensure clvmd message is always \0 terminated after read.
   Better detection of missing dmeventd fifo connection (2.02.93).
--- LVM2/lib/raid/raid.c	2012/02/27 10:15:08	1.16
+++ LVM2/lib/raid/raid.c	2012/02/28 14:23:41	1.17
@@ -456,10 +456,9 @@
 
 	do {
 		if ((segtype = raid_segtype_fn[i](cmd)) &&
-		    !lvm_register_segtype(seglib, segtype)) {
-			dm_free(segtype);
+		    !lvm_register_segtype(seglib, segtype))
+			/* segtype is already destroyed */
 			return_0;
-		}
 	} while (raid_segtype_fn[++i]);
 
 	return 1;
--- LVM2/lib/replicator/replicator.c	2012/01/25 21:54:00	1.12
+++ LVM2/lib/replicator/replicator.c	2012/02/28 14:23:42	1.13
@@ -772,10 +772,9 @@
 	segtype->private = NULL;
 	segtype->flags = SEG_REPLICATOR;
 
-	if (!lvm_register_segtype(seglib, segtype)) {
-		dm_free(segtype);
+	if (!lvm_register_segtype(seglib, segtype))
+		/* segtype is already destroyed */
 		return_0;
-	}
 
 	log_very_verbose("Initialised segtype: " REPLICATOR_MODULE);
 
@@ -787,10 +786,9 @@
 	segtype->private = NULL;
 	segtype->flags = SEG_REPLICATOR_DEV;
 
-	if (!lvm_register_segtype(seglib, segtype)) {
-		dm_free(segtype);
+	if (!lvm_register_segtype(seglib, segtype))
+		/* segtype is already destroyed */
 		return_0;
-	}
 
 	log_very_verbose("Initialised segtype: " REPLICATOR_DEV_MODULE);
 
--- LVM2/lib/thin/thin.c	2012/02/15 13:49:52	1.46
+++ LVM2/lib/thin/thin.c	2012/02/28 14:23:42	1.47
@@ -607,10 +607,9 @@
 			segtype->flags |= SEG_MONITORED;
 #  endif /* DMEVENTD */
 #endif
-		if (!lvm_register_segtype(seglib, segtype)) {
-			dm_free(segtype);
+		if (!lvm_register_segtype(seglib, segtype))
+			/* segtype is already destroyed */
 			return_0;
-		}
 
 		log_very_verbose("Initialised segtype: %s", segtype->name);
 	}


