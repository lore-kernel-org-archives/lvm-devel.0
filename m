From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:16 +0000 (UTC)
Subject: master - segtype: check for activation
Message-ID: <20160114103516.87B4260DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8857b227645e97b7cb52ae8d007e87e07db58b4e
Commit:        8857b227645e97b7cb52ae8d007e87e07db58b4e
Parent:        43897239b3cdd9ed9c1c7b795e171d9565d13116
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 17 12:23:33 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:05 2016 +0100

segtype: check for activation

Before setting static variable with check passed state,
detect if we are allowed to talk to driver.
---
 WHATS_NEW                   |    1 +
 lib/cache_segtype/cache.c   |   14 ++++++++------
 lib/error/errseg.c          |   13 ++++++++-----
 lib/mirror/mirrored.c       |    7 ++++++-
 lib/raid/raid.c             |   11 +++++------
 lib/replicator/replicator.c |    5 ++++-
 lib/snapshot/snapshot.c     |   16 ++++++++++------
 lib/striped/striped.c       |   11 +++++++----
 lib/thin/thin.c             |   16 +++++++++-------
 lib/zero/zero.c             |    9 ++++++---
 10 files changed, 64 insertions(+), 39 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 018b955..ae70f5a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.140 -
 ===================================
+  Correct checking of target presence when driver access is disabled.
   Eval poolmetadatasize arg earlier in lvresize.
   Fix vgcfgrestore to respect allocatable attribute of PVs.
   Add report/mark_hidden_devices to lvm.conf.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 033cabe..35d5e93 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -224,20 +224,22 @@ static int _target_present(struct cmd_context *cmd,
 	const struct dm_config_value *cv;
 	const char *str;
 
+	if (!activation())
+		return 0;
+
 	if (!_cache_checked) {
-		_cache_present = target_present(cmd, "cache", 1);
+		_cache_checked = 1;
 
-		if (!target_version("cache", &maj, &min, &patchlevel)) {
-			log_error("Failed to determine version of cache kernel module");
+		if (!(_cache_present = target_present(cmd, "cache", 1)))
 			return 0;
-		}
 
-		_cache_checked = 1;
+		if (!target_version("cache", &maj, &min, &patchlevel))
+			return_0;
 
 		if ((maj < 1) ||
 		    ((maj == 1) && (min < 3))) {
 			_cache_present = 0;
-			log_error("The cache kernel module is version %u.%u.%u. "
+			log_warn("WARNING: The cache kernel module is version %u.%u.%u. "
 				  "Version 1.3.0+ is required.",
 				  maj, min, patchlevel);
 			return 0;
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index 26b07d8..5c63b7c 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -49,13 +49,16 @@ static int _errseg_target_present(struct cmd_context *cmd,
 	static int _errseg_checked = 0;
 	static int _errseg_present = 0;
 
+	if (!activation())
+		return 0;
+
 	/* Reported truncated in older kernels */
-	if (!_errseg_checked &&
-	    (target_present(cmd, "error", 0) ||
-	     target_present(cmd, "erro", 0)))
-		_errseg_present = 1;
+	if (!_errseg_checked) {
+		_errseg_checked = 1;
+		_errseg_present = target_present(cmd, "error", 0) ||
+			target_present(cmd, "erro", 0);
+	}
 
-	_errseg_checked = 1;
 	return _errseg_present;
 }
 
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 371718d..fe6afbe 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -398,9 +398,14 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 	unsigned maj2, min2, patchlevel2;
 	char vsn[80];
 
+	if (!activation())
+		return 0;
+
 	if (!_mirrored_checked) {
 		_mirrored_checked = 1;
-		_mirrored_present = target_present(cmd, "mirror", 1);
+
+		if (!(_mirrored_present = target_present(cmd, "mirror", 1)))
+			return 0;
 
 		/*
 		 * block_on_error available as "block_on_error" log
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 0814cba..303bffa 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -320,12 +320,13 @@ static int _raid_target_present(struct cmd_context *cmd,
 	unsigned i;
 
 	if (!_raid_checked) {
-		_raid_present = target_present(cmd, "raid", 1);
+		_raid_checked = 1;
 
-		if (!target_version("raid", &maj, &min, &patchlevel)) {
-			log_error("Cannot read target version of RAID kernel module.");
+		if (!(_raid_present = target_present(cmd, "raid", 1)))
 			return 0;
-		}
+
+		if (!target_version("raid", &maj, &min, &patchlevel))
+			return_0;
 
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
 			if ((maj > _features[i].maj) ||
@@ -334,8 +335,6 @@ static int _raid_target_present(struct cmd_context *cmd,
 			else
 				log_very_verbose("Target raid does not support %s.",
 						 _features[i].feature);
-
-		_raid_checked = 1;
 	}
 
 	if (attributes)
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 7a8c3a8..f09432b 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -377,9 +377,12 @@ static int _replicator_target_present(struct cmd_context *cmd,
 	static int _checked = 0;
 	static int _present = 0;
 
+	if (!activation())
+		return 0;
+
 	if (!_checked) {
-		_present = target_present(cmd, REPLICATOR_MODULE, 1);
 		_checked = 1;
+		_present = target_present(cmd, REPLICATOR_MODULE, 1);
 	}
 
 	return _present;
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 4a8f005..91c55a9 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -145,13 +145,17 @@ static int _snap_target_present(struct cmd_context *cmd,
 	static unsigned _snap_attrs = 0;
 	uint32_t maj, min, patchlevel;
 
+	if (!activation())
+		return 0;
+
 	if (!_snap_checked) {
 		_snap_checked = 1;
-		_snap_present = target_present(cmd, "snapshot", 1) &&
-		    target_present(cmd, "snapshot-origin", 0);
 
-		if (_snap_present &&
-		    target_version("snapshot", &maj, &min, &patchlevel) &&
+		if (!(_snap_present = target_present(cmd, "snapshot", 1) &&
+		      target_present(cmd, "snapshot-origin", 0)))
+			return 0;
+
+		if (target_version("snapshot", &maj, &min, &patchlevel) &&
 		    (maj > 1 ||
 		     (maj == 1 && (min >= 12 || (min == 10 && patchlevel >= 2)))))
 			_snap_attrs |= SNAPSHOT_FEATURE_FIXED_LEAK;
@@ -163,12 +167,12 @@ static int _snap_target_present(struct cmd_context *cmd,
 		*attributes = _snap_attrs;
 
 	/* TODO: test everything at once */
-	if (seg && (seg->status & MERGING)) {
+	if (_snap_present && seg && (seg->status & MERGING)) {
 		if (!_snap_merge_checked) {
 			_snap_merge_present = target_present(cmd, "snapshot-merge", 0);
 			_snap_merge_checked = 1;
 		}
-		return _snap_present && _snap_merge_present;
+		return _snap_merge_present;
 	}
 
 	return _snap_present;
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index edf1ae2..5c3bb4c 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -192,11 +192,14 @@ static int _striped_target_present(struct cmd_context *cmd,
 	static int _striped_checked = 0;
 	static int _striped_present = 0;
 
-	if (!_striped_checked)
-		_striped_present = target_present(cmd, "linear", 0) &&
-			  target_present(cmd, "striped", 0);
+	if (!activation())
+		return 0;
 
-	_striped_checked = 1;
+	if (!_striped_checked) {
+		_striped_checked = 1;
+		_striped_present = target_present(cmd, "linear", 0) &&
+			target_present(cmd, "striped", 0);
+	}
 
 	return _striped_present;
 }
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index be7a6b4..1c0fce5 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -678,13 +678,17 @@ static int _thin_target_present(struct cmd_context *cmd,
 	const struct dm_config_value *cv;
 	const char *str;
 
+	if (!activation())
+		return 0;
+
 	if (!_checked) {
-		_present = target_present(cmd, _thin_pool_module, 1);
+		_checked = 1;
 
-		if (!target_version(_thin_pool_module, &maj, &min, &patchlevel)) {
-			log_error("Cannot read %s target version.", _thin_pool_module);
+		if (!(_present = target_present(cmd, _thin_pool_module, 1)))
 			return 0;
-		}
+
+		if (!target_version(_thin_pool_module, &maj, &min, &patchlevel))
+			return_0;
 
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
 			if ((maj > _features[i].maj) ||
@@ -694,8 +698,6 @@ static int _thin_target_present(struct cmd_context *cmd,
 				log_very_verbose("Target %s does not support %s.",
 						 _thin_pool_module,
 						 _features[i].feature);
-
-		_checked = 1;
 	}
 
 	if (attributes) {
@@ -704,7 +706,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 			if ((cn = find_config_tree_array(cmd, global_thin_disabled_features_CFG, NULL))) {
 				for (cv = cn->v; cv; cv = cv->next) {
 					if (cv->type != DM_CFG_STRING) {
-						log_error("Ignoring invalid string in config file %s.",
+						log_warn("WARNING: Ignoring invalid string in config file %s.",
 							  _lvmconf);
 						continue;
 					}
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 33ae9d3..f180e25 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -45,10 +45,13 @@ static int _zero_target_present(struct cmd_context *cmd,
 	static int _zero_checked = 0;
 	static int _zero_present = 0;
 
-	if (!_zero_checked)
-		_zero_present = target_present(cmd, "zero", 1);
+	if (!activation())
+		return 0;
 
-	_zero_checked = 1;
+	if (!_zero_checked) {
+		_zero_checked = 1;
+		_zero_present = target_present(cmd, "zero", 1);
+	}
 
 	return _zero_present;
 }


