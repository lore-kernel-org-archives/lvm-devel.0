From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:10 -0400
Subject: master - resize: continue change for getting vdo status before resize
Message-ID: <201910041533.x94FXAAp030995@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a9a4b45341cc62b103bf167e96bbdb5f542476e
Commit:        6a9a4b45341cc62b103bf167e96bbdb5f542476e
Parent:        cb5f0bdba988c826b8edee06e139cff62eeffeb8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 2 14:50:12 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

resize: continue change for getting vdo status before resize

Continue commit a98b77c16455ee97f5bd4b89536a3ae4efd8e009.
There needs to be error reported when status can't be obtained.
---
 lib/metadata/lv_manip.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 47ff167..ebdb0cb 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4852,7 +4852,7 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, 1, &percent))
-			return_0;
+			goto_bad;
 
 		/* Resize below the minimal usable value */
 		min_threshold = pool_metadata_min_threshold(first_seg(lv)) / DM_PERCENT_1;
@@ -4860,13 +4860,14 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 					      min_threshold : policy_threshold, policy_amount);
 
 		if (!lv_thin_pool_percent(lv, 0, &percent))
-			return_0;
+			goto_bad;
 	} else if (lv_is_vdo_pool(lv)) {
 		if (!lv_vdo_pool_percent(lv, &percent))
-			return_0;
+			goto_bad;
 	} else if (!lv_snapshot_percent(lv, &percent))
-			return_0;
+			goto_bad;
 	else if (!lv_is_active(lv)) {
+	bad:
 		log_error("Can't read state of locally inactive LV %s.",
 			  display_lvname(lv));
 		return 0;


