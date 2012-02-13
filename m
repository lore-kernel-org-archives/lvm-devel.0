From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:16:43 -0000
Subject: LVM2 lib/filters/filter-regex.c ./WHATS_NEW
Message-ID: <20120213111643.17448.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:16:42

Modified files:
	lib/filters    : filter-regex.c 
	.              : WHATS_NEW 

Log message:
	Add check for allocation failure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2289&r2=1.2290

--- LVM2/lib/filters/filter-regex.c	2011/08/30 14:55:17	1.32
+++ LVM2/lib/filters/filter-regex.c	2012/02/13 11:16:42	1.33
@@ -110,16 +110,17 @@
 		count++;
 	}
 
-	/*
-	 * allocate space for them
-	 */
-	if (!(regex = dm_pool_alloc(scratch, sizeof(*regex) * count)))
-		goto_out;
+	/* Allocate space for them */
+	if (!(regex = dm_pool_alloc(scratch, sizeof(*regex) * count))) {
+		log_error("Failed to allocate regex.");
+		goto out;
+	}
 
-	/*
-	 * create the accept/reject bitset
-	 */
-	rf->accept = dm_bitset_create(rf->mem, count);
+	/* Create the accept/reject bitset */
+	if (!(rf->accept = dm_bitset_create(rf->mem, count))) {
+		log_error("Failed to create bitset.");
+		goto out;
+	}
 
 	/*
 	 * fill the array back to front because we
--- LVM2/WHATS_NEW	2012/02/13 11:10:37	1.2289
+++ LVM2/WHATS_NEW	2012/02/13 11:16:42	1.2290
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Add check for allocation failure in _build_matcher().
   Add check for rimage name allocation failure in _raid_add_images().
   Add check for mda_copy failure in _text_pv_setup().
   Add check for _mirrored_init_target failure.


