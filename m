From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 14 Jan 2014 03:48:44 +0000 (UTC)
Subject: master - pvs: fix segfaults with orphans
Message-ID: <20140114034844.0C5E3610BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a450eab6a9fef7793066864ff58857d827b903f
Commit:        5a450eab6a9fef7793066864ff58857d827b903f
Parent:        4c2b4c37e72b74553125664364efcda0e0758bf7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 14 03:17:27 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 14 03:17:27 2014 +0000

pvs: fix segfaults with orphans

Several fields used to display 0 if undefined.  Recent changes
to the way the fields are reported threw away some tests for
valid pointers, leading to segfaults with 'pvs -o all'.

Reinstate the original behaviour.
---
 lib/cache/lvmcache.c |    3 +++
 lib/metadata/pv.c    |    3 ++-
 lib/report/report.c  |    8 +++-----
 tools/reporter.c     |   16 +++++++++-------
 4 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6719e99..ec8699b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1958,6 +1958,9 @@ int lvmcache_uncertain_ownership(struct lvmcache_info *info) {
 
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info)
 {
+	if (!info)
+		return UINT64_C(0);
+
 	return find_min_mda_size(&info->mdas);
 }
 
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 349048e..6f5fca4 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -245,7 +245,8 @@ uint64_t lvmcache_info_mda_free(struct lvmcache_info *info)
 {
 	uint64_t freespace = UINT64_MAX;
 
-	lvmcache_foreach_mda(info, _pv_mda_free, &freespace);
+	if (info)
+		lvmcache_foreach_mda(info, _pv_mda_free, &freespace);
 
 	if (freespace == UINT64_MAX)
 		freespace = UINT64_C(0);
diff --git a/lib/report/report.c b/lib/report/report.c
index 3626769..bd4b725 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -693,13 +693,11 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
+	const struct device *dev = *(const struct device * const *) data;
 	uint64_t size;
 
-	if (!data)
-		return _field_set_value(field, "", NULL);
-
-	if (!dev_get_size(*(const struct device **) data, &size))
-		return_0;
+	if (!dev || !dev->dev || !dev_get_size(dev, &size))
+		size = _zero64;
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index a36fcb3..602f173 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -141,8 +141,8 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	struct volume_group *old_vg = vg;
 	char uuid[64] __attribute__((aligned(8)));
 	struct label *label;
-	struct label _dummy_label = { .dev = 0 };
-	struct device _dummy_device = { .dev = 0 };
+	struct label dummy_label = { .dev = 0 };
+	struct device dummy_device = { .dev = 0 };
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
@@ -183,14 +183,16 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	/* FIXME workaround for pv_label going through cache; remove once struct
 	 * physical_volume gains a proper "label" pointer */
 	if (!(label = pv_label(pv))) {
-		_dummy_label.labeller = pv->fmt->labeller;
+		if (pv->fmt)
+			dummy_label.labeller = pv->fmt->labeller;
+
 		if (pv->dev)
-			_dummy_label.dev = pv->dev;
+			dummy_label.dev = pv->dev;
 		else {
-			_dummy_label.dev = &_dummy_device;
-			memcpy(_dummy_device.pvid, &pv->id, ID_LEN);
+			dummy_label.dev = &dummy_device;
+			memcpy(dummy_device.pvid, &pv->id, ID_LEN);
 		}
-		label = &_dummy_label;
+		label = &dummy_label;
 	}
 
 	if (!report_object(handle, vg, NULL, pv, NULL, NULL, label)) {


