From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:30 +0000 (UTC)
Subject: master - thin: reporting of thin volumes simplified
Message-ID: <20141103132330.2DB33602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f35d42a99db9dedc3f2f6fb9f65873704a241ef
Commit:        7f35d42a99db9dedc3f2f6fb9f65873704a241ef
Parent:        897b09157922a510d6c9f5556eea4fc243b84702
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 3 12:38:24 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:32 2014 +0100

thin: reporting of thin volumes simplified

Simplify reporting of percentage.
Allows easier support for more types.

Move testing of device availability into activate.c
---
 lib/activate/activate.c |    8 ++++----
 lib/report/report.c     |   38 +++++++++-----------------------------
 2 files changed, 13 insertions(+), 33 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6ba4712..69011f7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1134,7 +1134,7 @@ int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 	int r;
 	struct dev_manager *dm;
 
-	if (!activation())
+	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking thin %sdata percent for LV %s/%s",
@@ -1160,7 +1160,7 @@ int lv_thin_percent(const struct logical_volume *lv,
 	int r;
 	struct dev_manager *dm;
 
-	if (!activation())
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking thin percent for LV %s/%s",
@@ -1187,7 +1187,7 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 	struct dev_manager *dm;
 	struct dm_status_thin_pool *status;
 
-	if (!activation())
+	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking thin percent for LV %s/%s",
@@ -1211,7 +1211,7 @@ int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id)
 	int r;
 	struct dev_manager *dm;
 
-	if (!activation())
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking device id for LV %s/%s",
diff --git a/lib/report/report.c b/lib/report/report.c
index ebf3b3f..f2ed0ae 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1143,30 +1143,6 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
-/* Called only with lv_is_thin_pool/volume */
-static int _dtpercent_disp(int metadata, struct dm_report *rh,
-			   struct dm_report_field *field,
-			   const void *data, void *private)
-{
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	dm_percent_t percent = DM_PERCENT_INVALID;
-
-	/* Suppress data percent if not using driver */
-	/* cannot use lv_is_active_locally - need to check for layer -tpool */
-	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
-		return dm_report_field_percent(rh, field, &percent);
-
-	if (lv_is_thin_pool(lv)) {
-		if (!lv_thin_pool_percent(lv, metadata, &percent))
-			return_0;
-	} else { /* thin_volume */
-		if (!lv_thin_percent(lv, 0, &percent))
-			return_0;
-	}
-
-	return dm_report_field_percent(rh, field, &percent);
-}
-
 static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)
@@ -1176,9 +1152,10 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (lv_is_cow(lv))
 		return _snpercent_disp(rh, mem, field, data, private);
-
-	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
-		return _dtpercent_disp(0, rh, field, data, private);
+	else if (lv_is_thin_pool(lv))
+		(void) lv_thin_pool_percent(lv, 0, &percent);
+	else if (lv_is_thin_volume(lv))
+		(void) lv_thin_percent(lv, 0, &percent);
 
 	return dm_report_field_percent(rh, field, &percent);
 }
@@ -1189,11 +1166,14 @@ static int _metadatapercent_disp(struct dm_report *rh,
 				 const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	if (lv_is_thin_pool(lv))
-		return _dtpercent_disp(1, rh, field, data, private);
+		(void) lv_thin_pool_percent(lv, 1, &percent);
+	else if (lv_is_thin_volume(lv))
+		(void) lv_thin_percent(lv, 1, &percent);
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return dm_report_field_percent(rh, field, &percent);
 }
 
 static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,


