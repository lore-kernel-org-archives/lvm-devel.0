From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 19 Jun 2017 16:30:51 -0400
Subject: master - lvconvert: disable reshaping of open RAID LV
Message-ID: <201706192030.v5JKUp7b010963@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e9163618ab36a6b046b6380d6ef58429b219ef8
Commit:        9e9163618ab36a6b046b6380d6ef58429b219ef8
Parent:        e1a1c20e95974811ffa541f02723a9390132d10b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jun 19 22:25:54 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jun 19 22:25:54 2017 +0200

lvconvert: disable reshaping of open RAID LV

Disable until we have a proper fix for reshape space allocation,
switching it to begin/end of rimages and activation.

Related: rhbz1447812
---
 lib/metadata/raid_manip.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 95ce3b5..8fc04fb 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6267,6 +6267,8 @@ int lv_raid_convert(struct logical_volume *lv,
 	uint32_t region_size;
 	uint32_t data_copies = seg->data_copies;
 	uint32_t available_slvs, removed_slvs;
+	char *dev_path;
+	size_t sz;
 	takeover_fn_t takeover_fn;
 
 	/* FIXME If not active, prompt and activate */
@@ -6331,6 +6333,17 @@ int lv_raid_convert(struct logical_volume *lv,
 			return 0;
 		}
 
+		/* BZ1447812 */
+		sz = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) + strlen(lv->name) + 2;
+		if (!(dev_path = dm_pool_alloc(lv->vg->cmd->mem, sz)))
+			return_0;
+		if (dm_snprintf(dev_path, sz, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
+			return_0;
+		if (open(dev_path, O_RDONLY|O_EXCL) && errno) {
+			log_error("Reshape of open %s not supported.", display_lvname(lv));
+			return 0;
+		}
+
 		if (!_raid_reshape(lv, new_segtype, yes, force,
 				   data_copies, region_size,
 				   stripes, stripe_size, allocate_pvs)) {


