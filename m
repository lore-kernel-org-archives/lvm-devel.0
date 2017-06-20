From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 20 Jun 2017 11:28:31 -0400
Subject: master - lvconvert: enhance disable reshaping of open RAID LV
Message-ID: <201706201528.v5KFSV5J025895@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=601ad1c73faa5fe3d74ff5b06cc47073b40a1850
Commit:        601ad1c73faa5fe3d74ff5b06cc47073b40a1850
Parent:        31cd01c9b31c2c4e63797edd673fca8dc53da022
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 20 17:27:58 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 20 17:27:58 2017 +0200

lvconvert: enhance disable reshaping of open RAID LV

Enhance commit 9e9163618ab36a6b046b6380d6ef58429b219ef8
to use dev_open_flags/dev_close API.

Related: rhbz1447812
---
 lib/metadata/raid_manip.c |   36 +++++++++++++++++++++++++-----------
 1 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 56cc592..f787ad0 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6210,6 +6210,26 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 	return r;
 }
 
+/* BZ1447812: try opening LV exclusively */
+static int _lv_open_excl(struct logical_volume *lv, struct device **dev) {
+	char *dev_path;
+	size_t sz = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) + strlen(lv->name) + 2;
+
+	*dev = NULL;
+	if (!(dev_path = dm_pool_alloc(lv->vg->cmd->mem, sz)))
+		return_0;
+	if (dm_snprintf(dev_path, sz, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
+		return_0;
+	if (!(*dev = dev_create_file(dev_path, NULL, NULL, 0)))
+		return_0;
+	if (!dev_open_flags(*dev, O_EXCL, 1, 1)) {
+		log_error("Reshape of open %s not supported.", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * lv_raid_convert
  *
@@ -6259,8 +6279,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	uint32_t region_size;
 	uint32_t data_copies = seg->data_copies;
 	uint32_t available_slvs, removed_slvs;
-	char *dev_path;
-	size_t sz;
+	struct device *dev;
 	takeover_fn_t takeover_fn;
 
 	/* FIXME If not active, prompt and activate */
@@ -6331,24 +6350,19 @@ int lv_raid_convert(struct logical_volume *lv,
 			return 0;
 		}
 
-		/* BZ1447812 */
-		sz = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) + strlen(lv->name) + 2;
-		if (!(dev_path = dm_pool_alloc(lv->vg->cmd->mem, sz)))
-			return_0;
-		if (dm_snprintf(dev_path, sz, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
-			return_0;
-		if (open(dev_path, O_RDONLY|O_EXCL) && errno) {
-			log_error("Reshape of open %s not supported.", display_lvname(lv));
+		/* BZ1447812: reject reshape on open LV */
+		if (!_lv_open_excl(lv, &dev))
 			return 0;
-		}
 
 		if (!_raid_reshape(lv, new_segtype, yes, force,
 				   data_copies, region_size,
 				   stripes, stripe_size, allocate_pvs)) {
+			dev_close(dev);
 			log_error("Reshape request failed on LV %s.", display_lvname(lv));
 			return 0;
 		}
 
+		dev_close(dev);
 		return 1;
 	case 2:
 		log_error("Invalid conversion request on %s.", display_lvname(lv));


