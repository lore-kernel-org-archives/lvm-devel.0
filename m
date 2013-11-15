From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:32 +0000 (UTC)
Subject: master - report: use _field_set_percent
Message-ID: <20131115113932.DD5186135C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ca832ceafe4ca599e059464faf2ef5760a29b23
Commit:        6ca832ceafe4ca599e059464faf2ef5760a29b23
Parent:        36d7c639d14e121e839b2117dcf744097e6ebfde
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 23 11:03:02 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 11:05:03 2013 +0100

report: use _field_set_percent

Use common routine for displaying percentage.
---
 lib/report/report.c |  131 ++++++++++-----------------------------------------
 1 files changed, 25 insertions(+), 106 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 5caebb2..1565aec 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -34,6 +34,7 @@ struct lvm_report_object {
 	struct pv_segment *pvseg;
 };
 
+static const uint64_t _hundred64 = UINT64_C(100);
 static const uint64_t _minusone64 = UINT64_C(-1);
 static const int32_t _minusone32 = INT32_C(-1);
 static const uint64_t _zero64 = UINT64_C(0);
@@ -851,56 +852,23 @@ static int _snpercent_disp(struct dm_report *rh __attribute__((unused)), struct
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	percent_t snap_percent;
-	uint64_t *sortval;
-	char *repstr;
-
-	/* Suppress snapshot percentage if not using driver */
-	if (!activation()) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
-
-	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
 
-	if ((!lv_is_cow(lv) && !lv_is_merging_origin(lv)) ||
-	    !lv_is_active_locally(lv)) {
-		*sortval = UINT64_C(0);
-		dm_report_field_set_value(field, "", sortval);
-		return 1;
-	}
+	if ((lv_is_cow(lv) || lv_is_merging_origin(lv)) &&
+	    lv_snapshot_percent(lv, &snap_percent)) {
+		if ((snap_percent != PERCENT_INVALID) &&
+		    (snap_percent != PERCENT_MERGE_FAILED))
+			return _field_set_percent(field, mem, snap_percent);
 
-	if (!lv_snapshot_percent(lv, &snap_percent) ||
-	    (snap_percent == PERCENT_INVALID) || (snap_percent == PERCENT_MERGE_FAILED)) {
-		if (!lv_is_merging_origin(lv)) {
-			*sortval = UINT64_C(100);
-			dm_report_field_set_value(field, "100.00", sortval);
-		} else {
-			/* onactivate merge that hasn't started yet would
-			 * otherwise display incorrect snap% in origin
-			 */
-			*sortval = UINT64_C(0);
-			dm_report_field_set_value(field, "", sortval);
-		}
-		return 1;
-	}
+		if (!lv_is_merging_origin(lv))
+			return _field_set_value(field, "100.00", &_hundred64);
 
-	if (!(repstr = dm_pool_zalloc(mem, 8))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
+		/*
+		 * on activate merge that hasn't started yet would
+		 * otherwise display incorrect snap% in origin
+		 */
 	}
 
-	if (dm_snprintf(repstr, 7, "%.2f", percent_to_float(snap_percent)) < 0) {
-		log_error("snapshot percentage too large");
-		return 0;
-	}
-
-	*sortval = (uint64_t)(snap_percent * 1000.f);
-	dm_report_field_set_value(field, repstr, sortval);
-
-	return 1;
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
@@ -910,44 +878,17 @@ static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	percent_t percent;
-	uint64_t *sortval;
-	char *repstr;
-
-	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (lv->status & RAID) {
-		if (!lv_raid_percent(lv, &percent) ||
-		    (percent == PERCENT_INVALID))
-			goto no_copypercent;
-	} else if ((!(lv->status & PVMOVE) && !(lv->status & MIRRORED)) ||
-		   !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL) ||
-		   (percent == PERCENT_INVALID))
-		goto no_copypercent;
 
-	percent = copy_percent(lv);
+	if (((lv_is_raid(lv) && lv_raid_percent(lv, &percent)) ||
 
-	if (!(repstr = dm_pool_zalloc(mem, 8))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
+	    ((lv->status & (PVMOVE | MIRRORED)) &&
+	     lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
+	    (percent != PERCENT_INVALID)) {
+		percent = copy_percent(lv);
+		return _field_set_percent(field, mem, percent);
 	}
 
-	if (dm_snprintf(repstr, 7, "%.2f", percent_to_float(percent)) < 0) {
-		log_error("copy percentage too large");
-		return 0;
-	}
-
-	*sortval = (uint64_t)(percent * 1000.f);
-	dm_report_field_set_value(field, repstr, sortval);
-
-	return 1;
-
-no_copypercent:
-	*sortval = UINT64_C(0);
-	dm_report_field_set_value(field, "", sortval);
-	return 1;
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _raidsyncaction_disp(struct dm_report *rh __attribute__((unused)),
@@ -1030,21 +971,12 @@ static int _dtpercent_disp(int metadata, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
 	percent_t percent;
-	uint64_t *sortval;
-	char *repstr;
 
-	/* Suppress data percent if not thin pool/volume or not using driver */
-	if (!lv_info(lv->vg->cmd, lv, 1, &info, 0, 0) || !info.exists) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
-
-	if (!(sortval = dm_pool_zalloc(mem, sizeof(uint64_t)))) {
-		log_error("Failed to allocate sortval.");
-		return 0;
-	}
+	/* Suppress data percent if not using driver */
+	/* cannot use lv_is_active_locally - need to check for layer -tpool */
+	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
+		return _field_set_value(field, "",  &_minusone64);
 
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, metadata, &percent))
@@ -1054,20 +986,7 @@ static int _dtpercent_disp(int metadata, struct dm_pool *mem,
 			return_0;
 	}
 
-	if (!(repstr = dm_pool_alloc(mem, 8))) {
-		log_error("Failed to allocate report buffer.");
-		return 0;
-	}
-
-	if (dm_snprintf(repstr, 8, "%.2f", percent_to_float(percent)) < 0) {
-		log_error("Data percentage too large.");
-		return 0;
-	}
-
-	*sortval = (uint64_t)(percent * 1000.f);
-	dm_report_field_set_value(field, repstr, sortval);
-
-	return 1;
+	return _field_set_percent(field, mem, percent);
 }
 
 static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,


