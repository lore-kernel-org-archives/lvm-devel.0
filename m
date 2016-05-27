From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:51 +0000 (UTC)
Subject: master - snapshot: use seg_status for attrs
Message-ID: <20160527134751.A1A7160789@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80603ad49aeec70c9a3f391236668f212342d10a
Commit:        80603ad49aeec70c9a3f391236668f212342d10a
Parent:        92eba53a797a011d1ce6fbd7bef88eab41af2072
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 25 16:19:59 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

snapshot: use seg_status for attrs

---
 lib/metadata/lv.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 92ea3a9..d67caa2 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1111,7 +1111,6 @@ int lv_raid_healthy(const struct logical_volume *lv)
 
 char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm)
 {
-	dm_percent_t snap_percent;
 	const struct logical_volume *lv = lvdm->lv;
 	struct lv_segment *seg;
 	char *repstr;
@@ -1203,19 +1202,18 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 			repstr[4] = 'd';	/* Inactive without table */
 
 		/* Snapshot dropped? */
-		if (lvdm->info.live_table && lv_is_cow(lv)) {
-			if (!lv_snapshot_percent(lv, &snap_percent) ||
-			    snap_percent == DM_PERCENT_INVALID) {
+		if (lvdm->info.live_table &&
+		    (lvdm->seg_status.type == SEG_STATUS_SNAPSHOT)) {
+			if (lvdm->seg_status.snapshot->invalid) {
 				if (lvdm->info.suspended)
 					repstr[4] = 'S'; /* Susp Inv snapshot */
 				else
 					repstr[4] = 'I'; /* Invalid snapshot */
-			}
-			else if (snap_percent == LVM_PERCENT_MERGE_FAILED) {
+			} else if (lvdm->seg_status.snapshot->merge_failed) {
 				if (lvdm->info.suspended)
 					repstr[4] = 'M'; /* Susp snapshot merge failed */
 				else
-					repstr[4] = 'm'; /* snapshot merge failed */
+					repstr[4] = 'm'; /* Snapshot merge failed */
 			}
 		}
 


