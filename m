From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Mar 2018 07:09:46 -0400
Subject: master - cache: disallow to combine format 2 with mq
Message-ID: <201803191109.w2JB9kid016306@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d7ece126b96337326d026ab4edebe2db4333459
Commit:        8d7ece126b96337326d026ab4edebe2db4333459
Parent:        08487a30983bfa4b3c0a7bcd9060657b6c1803ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 19 10:23:48 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 19 12:02:08 2018 +0100

cache: disallow to combine format 2 with mq

Only policy 'smq' is meant to be used with format version 2.
Code used to let pass 'mq' policy also with format 2. But 'mq'
is obsoloted wth smq and kernel currently matches it. But this
is incompatible with older original mq logic - so disallow creation
of this rather useless combination.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   18 +++++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 995b389..3750341 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Disallow usage of cache format 2 with mq cache policy.
   Again accept striped LV as COW LV with lvconvert -s (2.02.169).
   Fix raid target version testing for supported features.
   Allow activation of pools when thin/cache_check tool is missing.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 5167760..2a54682 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -841,6 +841,18 @@ int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t fo
 		return 0;
 	}
 
+	/*
+	 * If policy is unselected, but format 2 is selected, policy smq is enforced.
+	 * ATM no other then smq policy is allowed to select format 2.
+	 */
+	if (!seg->policy_name) {
+		if (format == CACHE_METADATA_FORMAT_2)
+			seg->policy_name = "smq";
+	} else if (strcmp(seg->policy_name, "smq")) {
+		seg->cache_metadata_format = CACHE_METADATA_FORMAT_1;
+		return 1;
+	}
+
 	/* Check if we need to search for configured cache metadata format */
 	if (format == CACHE_METADATA_FORMAT_UNSELECTED) {
 		if (seg->cache_metadata_format != CACHE_METADATA_FORMAT_UNSELECTED)
@@ -894,15 +906,15 @@ int cache_set_params(struct lv_segment *seg,
 	struct lv_segment *pool_seg;
 	struct cmd_context *cmd = seg->lv->vg->cmd;
 
-	if (!cache_set_metadata_format(seg, format))
-		return_0;
-
 	if (!cache_set_cache_mode(seg, mode))
 		return_0;
 
 	if (!cache_set_policy(seg, policy_name, policy_settings))
 		return_0;
 
+	if (!cache_set_metadata_format(seg, format))
+		return_0;
+
 	pool_seg = seg_is_cache(seg) ? first_seg(seg->pool_lv) : seg;
 
 	if (chunk_size) {


