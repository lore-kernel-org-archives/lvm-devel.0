From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:35 +0000 (GMT)
Subject: main - cleanup: simplify
Message-ID: <20230406114735.5328F385842A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fb3e08033570365580b576777e312d2f9c2d86d
Commit:        1fb3e08033570365580b576777e312d2f9c2d86d
Parent:        a7cf55c6a19a0a70dab7f2b8a406d52e24d5e3cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 1 21:05:47 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 11:06:04 2023 +0200

cleanup: simplify

---
 lib/metadata/integrity_manip.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index ffb869b08..456795532 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -936,7 +936,9 @@ int lv_integrity_mismatches(struct cmd_context *cmd,
 			    const struct logical_volume *lv,
 			    uint64_t *mismatches)
 {
-	struct lv_with_info_and_seg_status status;
+	struct lv_with_info_and_seg_status status = {
+		.seg_status.type = SEG_STATUS_NONE,
+	};
 
 	if (lv_is_raid(lv) && lv_raid_has_integrity((struct logical_volume *)lv))
 		return lv_raid_integrity_total_mismatches(cmd, lv, mismatches);
@@ -944,9 +946,6 @@ int lv_integrity_mismatches(struct cmd_context *cmd,
 	if (!lv_is_integrity(lv))
 		return_0;
 
-	memset(&status, 0, sizeof(status));
-	status.seg_status.type = SEG_STATUS_NONE;
-
 	status.seg_status.seg = first_seg(lv);
 
 	/* FIXME: why reporter_pool? */

