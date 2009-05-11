From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:38 -0400
Subject: [PATCH 25/30] Update vgmdafree_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-25-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-8-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-9-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-10-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-11-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-12-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-13-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-14-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-15-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-16-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-17-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-18-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-19-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-20-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-21-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-22-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-23-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-24-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-25-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-26-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |   16 ++++++++++++++--
 lib/report/report.c          |   14 ++------------
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index 3d14ecf..63b742f 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -822,8 +822,20 @@ int lvm_vg_set_mda_count(vg_t *vg, const uint64_t value)
  */
 uint64_t lvm_vg_get_mda_free(const vg_t *vg)
 {
-	/* FIXME: implement function body */
-	return 0;
+	uint64_t freespace = UINT64_MAX, mda_free;
+	struct metadata_area *mda;
+
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+		if (!mda->ops->mda_free_sectors)
+			continue;
+		mda_free = mda->ops->mda_free_sectors(mda);
+		if (mda_free < freespace)
+			freespace = mda_free;
+	}
+
+	if (freespace == UINT64_MAX)
+		freespace = UINT64_C(0);
+	return freespace;
 }
 int lvm_vg_set_mda_free(vg_t *vg, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index 52b800e..c9deba3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1068,19 +1068,9 @@ static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint64_t freespace = UINT64_MAX, mda_free;
-	struct metadata_area *mda;
-
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
-		if (!mda->ops->mda_free_sectors)
-			continue;
-		mda_free = mda->ops->mda_free_sectors(mda);
-		if (mda_free < freespace)
-			freespace = mda_free;
-	}
+	uint64_t freespace;
 
-	if (freespace == UINT64_MAX)
-		freespace = UINT64_C(0);
+	freespace = lvm_vg_get_mda_free(vg);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
-- 
1.6.0.6


