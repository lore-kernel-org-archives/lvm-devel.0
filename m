From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jan 2021 19:39:44 +0000 (GMT)
Subject: main - integrity: fix segfault on error path when replacing images
Message-ID: <20210113193944.5D5D4386F80B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0534723a2de62da913dfd88d40ee6f8b8b93ac56
Commit:        0534723a2de62da913dfd88d40ee6f8b8b93ac56
Parent:        ff1324d5952db6f79c2c916c4f4520b3338abf4f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 13 13:33:19 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 13 13:39:33 2021 -0600

integrity: fix segfault on error path when replacing images

When adding replacement raid+integrity images (lvconvert --repair
after a raid image is lost), various errors can cause the function
to exit with an error.  On this exit path, the function attempts
to revert new images that had been created but not yet used.  The
cleanup failed to account for the fact that not all images needed
to be reverted.
---
 lib/metadata/integrity_manip.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 53ab1b3fa..abf90d850 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -773,9 +773,13 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 bad:
 	log_error("Failed to add integrity.");
 
-	for (s = 0; s < revert_meta_lvs; s++) {
-		if (!lv_remove(imeta_lvs[s]))
-			log_error("New integrity metadata LV may require manual removal.");
+	if (revert_meta_lvs) {
+		for (s = 0; s < DEFAULT_RAID_MAX_IMAGES; s++) {
+			if (!imeta_lvs[s])
+				continue;
+			if (!lv_remove(imeta_lvs[s]))
+				log_error("New integrity metadata LV may require manual removal.");
+		}
 	}
 			       
 	if (!vg_write(vg) || !vg_commit(vg))


