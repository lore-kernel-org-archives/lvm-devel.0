From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:28 +0000 (UTC)
Subject: master - cache: with cache target 1.9 mq is alias to smq
Message-ID: <20160426213128.2280860509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=588455d03ea40ffa37f466023691b0ec2bdf5e82
Commit:        588455d03ea40ffa37f466023691b0ec2bdf5e82
Parent:        aa91fe3d3c3e6c2d8d96f5c0766b58375a44daa9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 26 21:43:41 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:24:05 2016 +0200

cache: with cache target 1.9 mq is alias to smq

Avoid useless check for mq policy, it's loaded as smq
and aliased.
---
 WHATS_NEW                 |    1 +
 lib/cache_segtype/cache.c |    7 +++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2a4fdd5..4b33913 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.152 - 
 ==================================
+  Stop checking for dm_cache_mq policy with cache target 1.9 (alias to smq).
   Check first /sys/module/dm_* dir existance before using modprobe.
   Remove mpath from 10-dm.rules, superseded by 11-dm-mpath.rules (mpath>=0.6.0).
 
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index a65892e..be9a57e 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -211,8 +211,9 @@ static int _target_present(struct cmd_context *cmd,
 		const char feature[12];
 		const char module[12]; /* check dm-%s */
 	} _features[] = {
-		{ 1, 3, CACHE_FEATURE_POLICY_MQ, "policy_mq", "cache-mq" },
+		{ 1, 9, CACHE_FEATURE_POLICY_SMQ | CACHE_FEATURE_POLICY_MQ, "policy_smq", "cache-smq" },
 		{ 1, 8, CACHE_FEATURE_POLICY_SMQ, "policy_smq", "cache-smq" },
+		{ 1, 3, CACHE_FEATURE_POLICY_MQ, "policy_mq", "cache-mq" },
 	};
 	static const char _lvmconf[] = "global/cache_disabled_features";
 	static unsigned _attrs = 0;
@@ -249,7 +250,9 @@ static int _target_present(struct cmd_context *cmd,
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i) {
 			if (((maj > _features[i].maj) ||
 			     (maj == _features[i].maj && min >= _features[i].min)) &&
-			    (!_features[i].module[0] || module_present(cmd, _features[i].module)))
+			    (!_features[i].module[0] ||
+			     (_attrs & _features[i].cache_feature) || /* already present */
+			     module_present(cmd, _features[i].module)))
 				_attrs |= _features[i].cache_feature;
 			else
 				log_very_verbose("Target %s does not support %s.",


