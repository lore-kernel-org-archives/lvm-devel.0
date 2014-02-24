From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:06 +0000 (UTC)
Subject: master - thin: cleanup target_present call
Message-ID: <20140224201706.3862B60D5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23c069d16f40adb9c59caa686904bb3f23ab6fca
Commit:        23c069d16f40adb9c59caa686904bb3f23ab6fca
Parent:        8c878438f5a75310d09a1ee035d9caf8e2b9e50b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 13:13:20 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:09:29 2014 +0100

thin: cleanup target_present call

Mark 'seg' as unused attribute.
Pass seg as NULL (as it is unused) in this function.
---
 lib/thin/thin.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 92767a8..7c989f8 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -215,7 +215,7 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 
 #ifdef DEVMAPPER_SUPPORT
 static int _thin_target_present(struct cmd_context *cmd,
-				const struct lv_segment *seg,
+				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes);
 
 static int _thin_pool_modules_needed(struct dm_pool *mem,
@@ -262,7 +262,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	uint64_t transaction_id = 0;
 	unsigned attr;
 
-	if (!_thin_target_present(cmd, seg, &attr))
+	if (!_thin_target_present(cmd, NULL, &attr))
 		return_0;
 
 	if (!seg->metadata_lv) {
@@ -566,7 +566,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 			return_0;
 		if (seg->external_lv->size < seg->lv->size) {
 			/* Validate target supports smaller external origin */
-			if (!_thin_target_present(cmd, first_seg(seg->pool_lv), &attr) ||
+			if (!_thin_target_present(cmd, NULL, &attr) ||
 			    !(attr & THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {
 				log_error("Thin target does not support smaller size of external origin LV %s.",
 					  seg->external_lv->name);
@@ -617,7 +617,7 @@ static int _thin_target_percent(void **target_state __attribute__((unused)),
 }
 
 static int _thin_target_present(struct cmd_context *cmd,
-				const struct lv_segment *seg,
+				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes)
 {
 	/* List of features with their kernel target version */


