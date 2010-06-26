From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:59 -0400
Subject: [PATCH 28/38] Implement _vg_metadata_balance and call from vg_write() path.
In-Reply-To: <1277520789-6808-28-git-send-email-dwysocha@redhat.com>
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
	<1277520789-6808-20-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-21-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-22-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-23-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-24-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-25-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-26-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-27-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-28-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-29-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implement metadata balancing by comparing the value of the
newly added vg_mda_copies field (--vgmetadatacopies parameter)
with the current count of of non-ignored mdas and ignoring or
unignoring mdas as necessary to get to the target count.
Also, as a safety check before returning, ensure we have at
least one mda enabled.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   88 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 03e4a85..b9e4e39 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -58,6 +58,8 @@ static struct pv_list *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint64_t status);
 
+static int _vg_metadata_balance(struct volume_group *vg);
+
 const char _really_init[] =
     "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
 
@@ -989,6 +991,91 @@ static int _recalc_extents(uint32_t *extents, const char *desc1,
 	return 1;
 }
 
+static int _vg_ignore_mdas(struct volume_group *vg, uint32_t count)
+{
+	struct metadata_area *mda;
+
+	if (!count)
+		return 1;
+	/* FIXME: flip bits on random mdas */
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+		if (!mda_is_ignored(mda)) {
+			mda_set_ignored(mda, 1);
+			count--;
+		}
+		if (!count)
+			return 1;
+	}
+	log_error("Unable to find %"PRIu32" metadata areas to ignore "
+		  "on volume group %s", count, vg->name);
+	return 0;
+}
+
+static int _vg_unignore_mdas(struct volume_group *vg, uint32_t count)
+{
+	struct metadata_area *mda, *tmda;
+
+	if (!count)
+		return 1;
+	/* FIXME: flip bits on random mdas */
+	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_ignored) {
+		if (mda_is_ignored(mda)) {
+			mda_set_ignored(mda, 0);
+			dm_list_move(&vg->fid->metadata_areas, &mda->list);
+			count--;
+		}
+		if (!count)
+			return 1;
+	}
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+		if (mda_is_ignored(mda)) {
+			mda_set_ignored(mda, 0);
+			count--;
+		}
+		if (!count)
+			return 1;
+	}
+	log_error("Unable to find %"PRIu32" metadata areas to un-ignore "
+		  "on volume group %s", count, vg->name);
+	return 0;
+}
+
+static int _vg_metadata_balance(struct volume_group *vg)
+{
+	uint32_t mda_copies, count;
+	int ret = 1;
+
+	mda_copies = vg_mda_used_count(vg);
+	if (!vg->mda_copies)
+		goto skip_balance;
+
+	if (mda_copies > vg->mda_copies) {
+		ret = _vg_ignore_mdas(vg, mda_copies - vg->mda_copies);
+	} else if (mda_copies < vg->mda_copies) {
+		/* not an error to have vg_mda_count larger than total mdas */
+		if (vg->mda_copies >= vg_mda_count(vg))
+			count = vg_mda_count(vg) - vg_mda_used_count(vg);
+		else
+			count = vg->mda_copies - mda_copies;
+		ret = _vg_unignore_mdas(vg, count);
+	}
+	if (!ret)
+		return ret;
+
+skip_balance:
+	/*
+	 * Ensure at least one enabled mda.
+	 * FIXME: check size of fid->metadata_areas; reason is because of how
+	 * pv_setup works in the case of a pv with 2 mdas, one ignored and
+	 * another not ignored; function needs refactoring to be correct.
+	 */
+	if (!dm_list_size(&vg->fid->metadata_areas) ||
+	    !vg_mda_used_count(vg)) {
+		ret = _vg_unignore_mdas(vg, 1);
+	}
+	return ret;
+}
+
 uint32_t vg_mda_copies(const struct volume_group *vg)
 {
 	return vg->mda_copies;
@@ -2378,6 +2465,7 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
+	_vg_metadata_balance(vg);
 
 	if (dm_list_empty(&vg->fid->metadata_areas)) {
 		log_error("Aborting vg_write: No metadata areas to write to!");
-- 
1.6.0.6


