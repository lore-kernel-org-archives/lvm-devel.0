From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jun 2015 16:52:37 +0000 (UTC)
Subject: master - thin: drop limitation for extension of reduced thin volume
Message-ID: <20150618165237.8D68960F08@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f2a617c318d3e7b4535563b72ddcaad67da62ed
Commit:        6f2a617c318d3e7b4535563b72ddcaad67da62ed
Parent:        69132f55eafb6a797e86b449783f9cd2f518c3dd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 18 14:38:05 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 18 18:48:59 2015 +0200

thin: drop limitation for extension of reduced thin volume

Drop check which has prevented resize of reduce thin volume with
external origin. User is supposed to use 'zeroing' to get 'clean'
chunks.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   10 ----------
 2 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9e2a3dd..42a2571 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.122 - 
 =================================
+  Allow to extend reduced thin volumes with external origins.
   Consider snapshot and origin LV as unusable if its component is suspended.
   Fix lvmconfig segfault on settings with undefined default value (2.02.120).
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9983793..07f119a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5084,16 +5084,6 @@ static int _lvresize_check_type(struct cmd_context *cmd, const struct logical_vo
 
 	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
 	    (lp->resize == LV_EXTEND)) {
-		/*
-		 * TODO: currently we do not support extension of already reduced thin volume.
-		 * But it might be possible to create combined mapping of some part of
-		 * the external origin followed by zero target.
-		 */
-		if (first_seg(lv)->external_lv->size > lv->size) {
-			log_error("Extension of reduced thin volume with external origin is unsupported.");
-			return 0;
-		}
-
 		/* Validate thin target supports bigger size of thin volume then external origin */
 		if (first_seg(lv)->external_lv->size <= lv->size &&
 		    !thin_pool_feature_supported(first_seg(lv)->pool_lv, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {


