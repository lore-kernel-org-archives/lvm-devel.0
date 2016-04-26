From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 22:21:02 +0000 (UTC)
Subject: master - cache: better support for alias check
Message-ID: <20160426222102.E38BB60733@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49f32e4859017104555ba0297fa0384d4aa3d5f2
Commit:        49f32e4859017104555ba0297fa0384d4aa3d5f2
Parent:        2a2efab0b11b7bfeef1a60b6cfd61c8bceb67164
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 27 00:19:04 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 27 00:20:37 2016 +0200

cache: better support for alias check

To still support disabling of policies for test we need
better logic for alias detection introduced in
588455d03ea40ffa37f466023691b0ec2bdf5e82.
---
 lib/cache_segtype/cache.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index be9a57e..199bda6 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -208,12 +208,13 @@ static int _target_present(struct cmd_context *cmd,
 		uint32_t maj;
 		uint32_t min;
 		unsigned cache_feature;
+		unsigned cache_alias;
 		const char feature[12];
 		const char module[12]; /* check dm-%s */
 	} _features[] = {
-		{ 1, 9, CACHE_FEATURE_POLICY_SMQ | CACHE_FEATURE_POLICY_MQ, "policy_smq", "cache-smq" },
-		{ 1, 8, CACHE_FEATURE_POLICY_SMQ, "policy_smq", "cache-smq" },
-		{ 1, 3, CACHE_FEATURE_POLICY_MQ, "policy_mq", "cache-mq" },
+		{ 1, 9, 0, CACHE_FEATURE_POLICY_MQ, "policy_smq", "cache-smq" },
+		{ 1, 8, CACHE_FEATURE_POLICY_SMQ, 0, "policy_smq", "cache-smq" },
+		{ 1, 3, CACHE_FEATURE_POLICY_MQ, 0, "policy_mq", "cache-mq" },
 	};
 	static const char _lvmconf[] = "global/cache_disabled_features";
 	static unsigned _attrs = 0;
@@ -253,7 +254,8 @@ static int _target_present(struct cmd_context *cmd,
 			    (!_features[i].module[0] ||
 			     (_attrs & _features[i].cache_feature) || /* already present */
 			     module_present(cmd, _features[i].module)))
-				_attrs |= _features[i].cache_feature;
+				_attrs |= _features[i].cache_feature |
+					_features[i].cache_alias;
 			else
 				log_very_verbose("Target %s does not support %s.",
 						 _cache_module, _features[i].feature);


