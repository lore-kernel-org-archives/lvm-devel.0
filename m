From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Apr 2008 15:41:21 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20080404154121.25753.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-04 15:41:20

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Add check to vg_commit() to ensure lock is held before writing new VG metadata.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.824&r2=1.825
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/WHATS_NEW	2008/04/04 11:59:29	1.824
+++ LVM2/WHATS_NEW	2008/04/04 15:41:20	1.825
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add check to vg_commit() ensuring VG lock held before writing new VG metadata.
   Add validation of LV name to pvmove -n.
   Make clvmd refresh the context correctly when lvm.conf is updated.
   Add some basic internal VG lock validation.
--- LVM2/lib/metadata/metadata.c	2008/04/01 22:40:12	1.164
+++ LVM2/lib/metadata/metadata.c	2008/04/04 15:41:20	1.165
@@ -1316,6 +1316,12 @@
 	int cache_updated = 0;
 	int failed = 0;
 
+	if (!vgname_is_locked(vg->name)) {
+		log_error("Internal error: Attempt to write new VG metadata "
+			  "without locking %s", vg->name);
+		return cache_updated;
+	}
+
 	/* Commit to each copy of the metadata area */
 	list_iterate_items(mda, &vg->fid->metadata_areas) {
 		failed = 0;


