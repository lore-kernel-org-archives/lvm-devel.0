From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 13:19:20 -0400
Subject: master - lvconvert: require different LV for pool
Message-ID: <201704111719.v3BHJKI2013365@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04d7444afa88f1f4e56065888124fff775a5638f
Commit:        04d7444afa88f1f4e56065888124fff775a5638f
Parent:        a96c8b46b62c316381eb029416b92197d9cfa4de
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 11 12:15:10 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 12:17:14 2017 -0500

lvconvert: require different LV for pool

When convering an LV to a cache or thin LV, require
that an LV being converted to cache pool or thin pool
at the same time be a different LV.
---
 tools/lvconvert.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c18b5a4..f4ee660 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3826,6 +3826,12 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 			goto out;
 		}
 
+		if (cachepool_lv == lv) {
+			log_error("Use a different LV for cache pool LV and cache LV %s.",
+				  display_lvname(cachepool_lv));
+			goto out;
+		}
+
 		if (!_lvconvert_to_pool(cmd, cachepool_lv, lv, 0, 1, &vg->pvs)) {
 			log_error("LV %s could not be converted to a cache pool.",
 				  display_lvname(cachepool_lv));
@@ -3924,6 +3930,12 @@ static int _lvconvert_to_thin_with_external_single(struct cmd_context *cmd,
 			goto out;
 		}
 
+		if (thinpool_lv == lv) {
+			log_error("Use a different LV for thin pool LV and thin LV %s.",
+				  display_lvname(thinpool_lv));
+			goto out;
+		}
+
 		if (!_lvconvert_to_pool(cmd, thinpool_lv, lv, 1, 0, &vg->pvs)) {
 			log_error("LV %s could not be converted to a thin pool.",
 				  display_lvname(thinpool_lv));


