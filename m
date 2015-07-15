From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:10:53 +0000 (UTC)
Subject: master - cache: capture missing policy name
Message-ID: <20150715111053.0CA80609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=077645476cdfd7de0a16c283712b6c01938015d7
Commit:        077645476cdfd7de0a16c283712b6c01938015d7
Parent:        e9e35b011e084616f97ede9a31305259e70f883d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 15 10:54:49 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:22 2015 +0200

cache: capture missing policy name

Policy name has to be always defined.
Capture it as an internal error before write.
When reading metadata without defined policy name, use default defined policy.

TODO: Unsure, but it might have to be actually always 'mq' in this case.
---
 lib/cache_segtype/cache.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index ca30495..ad356a9 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -77,9 +77,13 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("policy must be a string in");
 		if (!(seg->policy_name = dm_pool_strdup(mem, str)))
 			return SEG_LOG_ERROR("Failed to duplicate policy in");
-	} else
+	} else {
 		/* Cannot use 'just' default, so pick one */
 		seg->policy_name = DEFAULT_CACHE_POOL_POLICY; /* FIXME make configurable */
+		/* FIXME maybe here should be always 'mq' */
+		log_warn("WARNING: cache_policy undefined, using default \"%s\" policy.",
+			 seg->policy_name);
+	}
 
 	/*
 	 * Read in policy args:
@@ -130,13 +134,17 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	if (!(cache_mode = get_cache_pool_cachemode_name(seg)))
 		return_0;
 
+	if (!seg->policy_name) {
+		log_error(INTERNAL_ERROR "Policy name for %s is not defined.",
+			  display_lvname(seg->lv));
+		return 0;
+	}
+
 	outf(f, "data = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
 	outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
 	outf(f, "cache_mode = \"%s\"", cache_mode);
-
-	if (seg->policy_name)
-		outf(f, "policy = \"%s\"", seg->policy_name);
+	outf(f, "policy = \"%s\"", seg->policy_name);
 
 	if (seg->policy_settings) {
 		if (strcmp(seg->policy_settings->key, "policy_settings")) {


