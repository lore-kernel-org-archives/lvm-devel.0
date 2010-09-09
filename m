From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Sep 2010 16:12:58 -0400
Subject: [PATCH 01/12] Add vg_attr() and lv_attr() functions.
In-Reply-To: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
References: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284063189-4908-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the creating of the 'attr' strings into a common function so
they can be called from the 'disp' functions as well as the new
'get' property functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |  171 +++++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata.h |    2 +
 lib/report/report.c     |  157 +------------------------------------------
 3 files changed, 175 insertions(+), 155 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d14c33c..094ffc1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4544,6 +4544,177 @@ uint32_t vg_mda_used_count(const struct volume_group *vg)
        return used_count;
 }
 
+static char _alloc_policy_char(alloc_policy_t alloc)
+{
+	switch (alloc) {
+	case ALLOC_CONTIGUOUS:
+		return 'c';
+	case ALLOC_CLING:
+		return 'l';
+	case ALLOC_NORMAL:
+		return 'n';
+	case ALLOC_ANYWHERE:
+		return 'a';
+	default:
+		return 'i';
+	}
+}
+
+char *vg_attr(struct dm_pool *mem, const struct volume_group *vg)
+{
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 7))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (vg->status & LVM_WRITE)
+		repstr[0] = 'w';
+	else
+		repstr[0] = 'r';
+
+	if (vg_is_resizeable(vg))
+		repstr[1] = 'z';
+	else
+		repstr[1] = '-';
+
+	if (vg_is_exported(vg))
+		repstr[2] = 'x';
+	else
+		repstr[2] = '-';
+
+	if (vg_missing_pv_count(vg))
+		repstr[3] = 'p';
+	else
+		repstr[3] = '-';
+
+	repstr[4] = _alloc_policy_char(vg->alloc);
+
+	if (vg_is_clustered(vg))
+		repstr[5] = 'c';
+	else
+		repstr[5] = '-';
+	return repstr;
+}
+
+static int _lv_mimage_in_sync(const struct logical_volume *lv)
+{
+	float percent;
+	percent_range_t percent_range;
+	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
+
+	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
+		return_0;
+
+	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
+			       &percent_range, NULL))
+		return_0;
+
+	return (percent_range == PERCENT_100) ? 1 : 0;
+}
+
+char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	float snap_percent;
+	percent_range_t percent_range;
+	struct lvinfo info;
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 7))) {
+		log_error("dm_pool_alloc failed");
+		return 0;
+	}
+
+	/* Blank if this is a "free space" LV. */
+	if (!*lv->name)
+		goto out;
+
+	if (lv->status & PVMOVE)
+		repstr[0] = 'p';
+	else if (lv->status & CONVERTING)
+		repstr[0] = 'c';
+	else if (lv->status & VIRTUAL)
+		repstr[0] = 'v';
+	/* Origin takes precedence over Mirror */
+	else if (lv_is_origin(lv)) {
+		if (lv_is_merging_origin(lv))
+			repstr[0] = 'O';
+		else
+			repstr[0] = 'o';
+	}
+	else if (lv->status & MIRRORED) {
+		if (lv->status & MIRROR_NOTSYNCED)
+			repstr[0] = 'M';
+		else
+			repstr[0] = 'm';
+	}else if (lv->status & MIRROR_IMAGE)
+		if (_lv_mimage_in_sync(lv))
+			repstr[0] = 'i';
+		else
+			repstr[0] = 'I';
+	else if (lv->status & MIRROR_LOG)
+		repstr[0] = 'l';
+	else if (lv_is_cow(lv)) {
+		if (lv_is_merging_cow(lv))
+			repstr[0] = 'S';
+		else
+			repstr[0] = 's';
+	} else
+		repstr[0] = '-';
+
+	if (lv->status & PVMOVE)
+		repstr[1] = '-';
+	else if (lv->status & LVM_WRITE)
+		repstr[1] = 'w';
+	else if (lv->status & LVM_READ)
+		repstr[1] = 'r';
+	else
+		repstr[1] = '-';
+
+	repstr[2] = _alloc_policy_char(lv->alloc);
+
+	if (lv->status & LOCKED)
+		repstr[2] = toupper(repstr[2]);
+
+	if (lv->status & FIXED_MINOR)
+		repstr[3] = 'm';	/* Fixed Minor */
+	else
+		repstr[3] = '-';
+
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
+		if (info.suspended)
+			repstr[4] = 's';	/* Suspended */
+		else if (info.live_table)
+			repstr[4] = 'a';	/* Active */
+		else if (info.inactive_table)
+			repstr[4] = 'i';	/* Inactive with table */
+		else
+			repstr[4] = 'd';	/* Inactive without table */
+
+		/* Snapshot dropped? */
+		if (info.live_table && lv_is_cow(lv) &&
+		    (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
+		     percent_range == PERCENT_INVALID)) {
+			repstr[0] = toupper(repstr[0]);
+			if (info.suspended)
+				repstr[4] = 'S'; /* Susp Inv snapshot */
+			else
+				repstr[4] = 'I'; /* Invalid snapshot */
+		}
+
+		if (info.open_count)
+			repstr[5] = 'o';	/* Open */
+		else
+			repstr[5] = '-';
+	} else {
+		repstr[4] = '-';
+		repstr[5] = '-';
+	}
+out:
+	return repstr;
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index b570cee..f3e268c 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -419,5 +419,7 @@ int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 uint64_t find_min_mda_size(struct dm_list *mdas);
 uint64_t vg_mda_size(const struct volume_group *vg);
 uint64_t vg_mda_free(const struct volume_group *vg);
+char *vg_attr(struct dm_pool *mem, const struct volume_group *vg);
+char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index 703060b..2de78a1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -34,22 +34,6 @@ struct lvm_report_object {
 	struct pv_segment *pvseg;
 };
 
-static char _alloc_policy_char(alloc_policy_t alloc)
-{
-	switch (alloc) {
-	case ALLOC_CONTIGUOUS:
-		return 'c';
-	case ALLOC_CLING:
-		return 'l';
-	case ALLOC_NORMAL:
-		return 'n';
-	case ALLOC_ANYWHERE:
-		return 'a';
-	default:
-		return 'i';
-	}
-}
-
 static const uint64_t _minusone64 = UINT64_C(-1);
 static const int32_t _minusone32 = INT32_C(-1);
 
@@ -264,124 +248,16 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	return dm_report_field_int32(rh, field, &_minusone32);
 }
 
-static int _lv_mimage_in_sync(const struct logical_volume *lv)
-{
-	float percent;
-	percent_range_t percent_range;
-	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
-
-	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
-		return_0;
-
-	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
-			       &percent_range, NULL))
-		return_0;
-
-	return (percent_range == PERCENT_100) ? 1 : 0;
-}
-
 static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
 	char *repstr;
-	float snap_percent;
-	percent_range_t percent_range;
 
-	if (!(repstr = dm_pool_zalloc(mem, 7))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = lv_attr(mem, lv)))
 		return 0;
-	}
-
-	/* Blank if this is a "free space" LV. */
-	if (!*lv->name)
-		goto out;
-
-	if (lv->status & PVMOVE)
-		repstr[0] = 'p';
-	else if (lv->status & CONVERTING)
-		repstr[0] = 'c';
-	else if (lv->status & VIRTUAL)
-		repstr[0] = 'v';
-	/* Origin takes precedence over Mirror */
-	else if (lv_is_origin(lv)) {
-		if (lv_is_merging_origin(lv))
-			repstr[0] = 'O';
-		else
-			repstr[0] = 'o';
-	}
-	else if (lv->status & MIRRORED) {
-		if (lv->status & MIRROR_NOTSYNCED)
-			repstr[0] = 'M';
-		else
-			repstr[0] = 'm';
-	}else if (lv->status & MIRROR_IMAGE)
-		if (_lv_mimage_in_sync(lv))
-			repstr[0] = 'i';
-		else
-			repstr[0] = 'I';
-	else if (lv->status & MIRROR_LOG)
-		repstr[0] = 'l';
-	else if (lv_is_cow(lv)) {
-		if (lv_is_merging_cow(lv))
-			repstr[0] = 'S';
-		else
-			repstr[0] = 's';
-	} else
-		repstr[0] = '-';
 
-	if (lv->status & PVMOVE)
-		repstr[1] = '-';
-	else if (lv->status & LVM_WRITE)
-		repstr[1] = 'w';
-	else if (lv->status & LVM_READ)
-		repstr[1] = 'r';
-	else
-		repstr[1] = '-';
-
-	repstr[2] = _alloc_policy_char(lv->alloc);
-
-	if (lv->status & LOCKED)
-		repstr[2] = toupper(repstr[2]);
-
-	if (lv->status & FIXED_MINOR)
-		repstr[3] = 'm';	/* Fixed Minor */
-	else
-		repstr[3] = '-';
-
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
-		if (info.suspended)
-			repstr[4] = 's';	/* Suspended */
-		else if (info.live_table)
-			repstr[4] = 'a';	/* Active */
-		else if (info.inactive_table)
-			repstr[4] = 'i';	/* Inactive with table */
-		else
-			repstr[4] = 'd';	/* Inactive without table */
-
-		/* Snapshot dropped? */
-		if (info.live_table && lv_is_cow(lv) &&
-		    (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
-		     percent_range == PERCENT_INVALID)) {
-			repstr[0] = toupper(repstr[0]);
-			if (info.suspended)
-				repstr[4] = 'S'; /* Susp Inv snapshot */
-			else
-				repstr[4] = 'I'; /* Invalid snapshot */
-		}
-
-		if (info.open_count)
-			repstr[5] = 'o';	/* Open */
-		else
-			repstr[5] = '-';
-	} else {
-		repstr[4] = '-';
-		repstr[5] = '-';
-	}
-
-out:
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
@@ -419,37 +295,8 @@ static int _vgstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 	const struct volume_group *vg = (const struct volume_group *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 7))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = vg_attr(mem, vg)))
 		return 0;
-	}
-
-	if (vg->status & LVM_WRITE)
-		repstr[0] = 'w';
-	else
-		repstr[0] = 'r';
-
-	if (vg_is_resizeable(vg))
-		repstr[1] = 'z';
-	else
-		repstr[1] = '-';
-
-	if (vg_is_exported(vg))
-		repstr[2] = 'x';
-	else
-		repstr[2] = '-';
-
-	if (vg_missing_pv_count(vg))
-		repstr[3] = 'p';
-	else
-		repstr[3] = '-';
-
-	repstr[4] = _alloc_policy_char(vg->alloc);
-
-	if (vg_is_clustered(vg))
-		repstr[5] = 'c';
-	else
-		repstr[5] = '-';
 
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
-- 
1.7.2.1


