From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:35:34 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100628203534.16765.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:35:34

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Refactor vg_commit() to add _vg_commit_mdas().
	
	Factor out calling mda->ops->vg_commit() for each mda.
	No functional change.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.355&r2=1.356

--- LVM2/lib/metadata/metadata.c	2010/06/28 20:35:17	1.355
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:35:33	1.356
@@ -2424,18 +2424,11 @@
 	return 1;
 }
 
-/* Commit pending changes */
-int vg_commit(struct volume_group *vg)
+static int _vg_commit_mdas(struct volume_group *vg)
 {
 	struct metadata_area *mda;
-	int cache_updated = 0;
 	int failed = 0;
-
-	if (!vgname_is_locked(vg->name)) {
-		log_error(INTERNAL_ERROR "Attempt to write new VG metadata "
-			  "without locking %s", vg->name);
-		return cache_updated;
-	}
+	int cache_updated = 0;
 
 	/* Commit to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
@@ -2451,6 +2444,21 @@
 			cache_updated = 1;
 		}
 	}
+	return cache_updated;
+}
+
+/* Commit pending changes */
+int vg_commit(struct volume_group *vg)
+{
+	int cache_updated = 0;
+
+	if (!vgname_is_locked(vg->name)) {
+		log_error(INTERNAL_ERROR "Attempt to write new VG metadata "
+			  "without locking %s", vg->name);
+		return cache_updated;
+	}
+
+	cache_updated = _vg_commit_mdas(vg);
 
 	if (cache_updated) {
 		/* Instruct remote nodes to upgrade cached metadata. */


