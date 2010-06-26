From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:50 -0400
Subject: [PATCH 19/38] Refactor vg_commit() to add _vg_commit_mdas().
In-Reply-To: <1277520789-6808-19-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-19-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-20-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Factor out calling mda->ops->vg_commit() for each mda.
No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5ec78f0..398f149 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2424,18 +2424,11 @@ int vg_write(struct volume_group *vg)
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
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
@@ -2451,6 +2444,21 @@ int vg_commit(struct volume_group *vg)
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
-- 
1.6.0.6


