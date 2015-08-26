From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Aug 2015 09:29:22 +0000 (UTC)
Subject: master - cache: lvconvert accepts --cachemode for --cache
Message-ID: <20150826092922.47E9561188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9886fd236e2cf09f299589e0e2b6cb7454b2314a
Commit:        9886fd236e2cf09f299589e0e2b6cb7454b2314a
Parent:        a4fdfc098d7a1c28793a8ba6f82277ecef40dfcd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 25 14:48:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 26 11:24:41 2015 +0200

cache: lvconvert accepts --cachemode for --cache

All cache args could be specified when caching LV
(means converting LV to cached).

When --cachemode arg is given during cache-pool conversion,
store it in the metadata.

https://bugzilla.redhat.com/show_bug.cgi?id=1255184
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ac8e1e9..ea50997 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.129 -
 ===================================
+  Accept --cachemode with lvconvert.
   Fix and improve reporting properties of cache-pool.
   Enable usage of --cachepolicy and --cachesetting with lvconvert.
   Don't allow to reduce size of thin-pool metadata.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 95996b7..07d9f43 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2828,7 +2828,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 
 		if (!metadata_lv) {
 			if (arg_from_list_is_set(cmd, "is invalid with existing pool",
-						 cachemode_ARG, chunksize_ARG, discards_ARG,
+						 chunksize_ARG, discards_ARG,
 						 zero_ARG, poolmetadatasize_ARG, -1))
 				return_0;
 
@@ -3069,6 +3069,10 @@ mda_write:
 	seg->discards = lp->discards;
 	seg->zero_new_blocks = lp->zero ? 1 : 0;
 
+	if (lp->cache_mode &&
+	    !cache_set_mode(seg, lp->cache_mode))
+		return_0;
+
 	if ((lp->policy_name || lp->policy_settings) &&
 	    !cache_set_policy(seg, lp->policy_name, lp->policy_settings))
 		return_0;


