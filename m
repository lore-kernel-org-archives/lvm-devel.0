From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  2 Nov 2022 13:00:20 +0000 (GMT)
Subject: main - dev_manager: accept misalined vdo pools.
Message-ID: <20221102130020.6B2623856DFB@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e79b005c2013fb03d8a48a3cfd8e70a982dd65b
Commit:        2e79b005c2013fb03d8a48a3cfd8e70a982dd65b
Parent:        829ab017082eaad253ebd28ad7d7ae7f3936dbcb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 26 14:38:29 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 2 13:59:34 2022 +0100

dev_manager: accept misalined vdo pools.

Since lvm2 may create VDO pool virtual size aligned only on extent size
while VDO itself is just 4K aligned - we need to support such misalign.
---
 lib/activate/dev_manager.c |  8 +++++---
 lib/metadata/vdo_manip.c   | 10 ++--------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5fec52a2a..cafb94ad5 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -277,7 +277,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	int dmtask;
 	int with_flush; /* TODO: arg for _info_run */
 	void *target = NULL;
-	uint64_t target_start, target_length, start, length, length_crop = 0;
+	uint64_t target_start, target_length, start, extent_size, length, length_crop = 0;
 	char *target_name, *target_params;
 	const char *devname;
 
@@ -306,8 +306,8 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 
 	/* Query status only for active device */
 	if (seg_status && dminfo->exists) {
-		start = length = seg_status->seg->lv->vg->extent_size;
-		start *= seg_status->seg->le;
+		extent_size = length = seg_status->seg->lv->vg->extent_size;
+		start = extent_size * seg_status->seg->le;
 		length *= _seg_len(seg_status->seg);
 
 		/* Uses max DM_THIN_MAX_METADATA_SIZE sectors for metadata device */
@@ -328,6 +328,8 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 
 			if ((start == target_start) &&
 			    ((length == target_length) ||
+			     ((lv_is_vdo_pool(seg_status->seg->lv)) && /* should fit within extent size */
+			      (length < target_length) && ((length + extent_size) > target_length)) ||
 			     (length_crop && (length_crop == target_length))))
 				break; /* Keep target_params when matching segment is found */
 
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 779883d03..0181dc6d5 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -263,7 +263,6 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
-reformat:
 	if (*logical_size) {
 		logical_size_aligned = 0;
 		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--logical-size=" FMTu64 "K",
@@ -374,13 +373,8 @@ reformat:
 		// align obtained size to extent size
 		logical_size_aligned = *logical_size / data_lv->vg->extent_size * data_lv->vg->extent_size;
 		if (*logical_size != logical_size_aligned) {
-			*logical_size = logical_size_aligned;
-			argv[1] = (char*) "--force";
-			args = 2;
-			reformating = 1;
-			log_verbose("Reformating VDO to align virtual size %s by extent size.",
-				    display_size(data_lv->vg->cmd, *logical_size));
-			goto reformat;
+			log_debug("Using bigger VDO virtual size unaligned on extent size by %s.",
+				  display_size(data_lv->vg->cmd, *logical_size - logical_size_aligned));
 		}
 	}
 

