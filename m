From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:27 +0000 (UTC)
Subject: master - debug: enhance debug msg for cache
Message-ID: <20160505220127.344CF60C56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0111563c2ffd4026ea45dc38c97d4210d903889
Commit:        d0111563c2ffd4026ea45dc38c97d4210d903889
Parent:        fd79027cae16be4f7fcae98568c2063ac37c9e3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 27 12:55:52 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:34:35 2016 +0200

debug: enhance debug msg for cache

---
 lib/cache_segtype/cache.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index b3edff8..0cbb993 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -211,8 +211,11 @@ static int _target_present(struct cmd_context *cmd,
 		unsigned cache_alias;
 		const char feature[12];
 		const char module[12]; /* check dm-%s */
+		const char *aliasing;
 	} _features[] = {
-		{ 1, 9, 0, CACHE_FEATURE_POLICY_MQ, "policy_smq", "cache-smq" },
+		/* Assumption: cache >=1.9 always aliases MQ policy */
+		{ 1, 9, CACHE_FEATURE_POLICY_SMQ, CACHE_FEATURE_POLICY_MQ, "policy_smq", "cache-smq",
+		" and aliases cache-mq" },
 		{ 1, 8, CACHE_FEATURE_POLICY_SMQ, 0, "policy_smq", "cache-smq" },
 		{ 1, 3, CACHE_FEATURE_POLICY_MQ, 0, "policy_mq", "cache-mq" },
 	};
@@ -245,16 +248,17 @@ static int _target_present(struct cmd_context *cmd,
 			return 0;
 		}
 
-
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i) {
+			if (_attrs & _features[i].cache_feature)
+				continue; /* already present */
 			if (((maj > _features[i].maj) ||
 			     (maj == _features[i].maj && min >= _features[i].min)) &&
-			    (!_features[i].module[0] ||
-			     (_attrs & _features[i].cache_feature) || /* already present */
-			     module_present(cmd, _features[i].module)))
-				_attrs |= _features[i].cache_feature |
-					_features[i].cache_alias;
-			else
+			    module_present(cmd, _features[i].module)) {
+				log_debug_activation("Cache policy %s is available%s.",
+						     _features[i].module,
+						     _features[i].aliasing ? : "");
+				_attrs |= (_features[i].cache_feature | _features[i].cache_alias);
+			} else if (!_features[i].cache_alias)
 				log_very_verbose("Target %s does not support %s.",
 						 _cache_module, _features[i].feature);
 		}


