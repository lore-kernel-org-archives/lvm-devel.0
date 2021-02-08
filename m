From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:07 +0000 (GMT)
Subject: main - targets: use target_present_version
Message-ID: <20210208224507.53EE53938398@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b173bb931426cd1d35beb5ec5151289112b2568
Commit:        9b173bb931426cd1d35beb5ec5151289112b2568
Parent:        6373f3909252e312ca2b25d42a46a712099ae7fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 21:48:18 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

targets: use target_present_version

Skip duplicated  dm version   ioctl() on every startup.
---
 lib/integrity/integrity.c   |  5 ++---
 lib/mirror/mirrored.c       |  3 ++-
 lib/raid/raid.c             |  6 ++----
 lib/snapshot/snapshot.c     |  8 ++++----
 lib/thin/thin.c             |  6 ++----
 lib/vdo/vdo.c               |  2 +-
 lib/writecache/writecache.c | 12 ++----------
 7 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/lib/integrity/integrity.c b/lib/integrity/integrity.c
index d5ad86b63..7423e04ae 100644
--- a/lib/integrity/integrity.c
+++ b/lib/integrity/integrity.c
@@ -240,9 +240,8 @@ static int _target_present(struct cmd_context *cmd,
 
 	if (!_integrity_checked) {
 		_integrity_checked = 1;
-		_integrity_present =  target_present(cmd, TARGET_NAME_INTEGRITY, 1);
-
-		if (!target_version(TARGET_NAME_INTEGRITY, &maj, &min, &patchlevel))
+		if (!(_integrity_present = target_present_version(cmd, TARGET_NAME_INTEGRITY, 1,
+								  &maj, &min, &patchlevel)))
 			return 0;
 
 		if (maj < 1 || min < 6) {
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 75893a6f6..64b470a98 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -405,7 +405,8 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 	if (!_mirrored_checked) {
 		_mirrored_checked = 1;
 
-		if (!(_mirrored_present = target_present(cmd, TARGET_NAME_MIRROR, 1)))
+		if (!(_mirrored_present = target_present_version(cmd, TARGET_NAME_MIRROR, 1,
+								 &maj, &min, &patchlevel)))
 			return 0;
 
 		/*
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 6344200f5..a0f00637a 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -551,10 +551,8 @@ static int _raid_target_present(struct cmd_context *cmd,
 	if (!_raid_checked) {
 		_raid_checked = 1;
 
-		if (!(_raid_present = target_present(cmd, TARGET_NAME_RAID, 1)))
-			return 0;
-
-		if (!target_version("raid", &maj, &min, &patchlevel))
+		if (!(_raid_present = target_present_version(cmd, TARGET_NAME_RAID, 1,
+							     &maj, &min, &patchlevel)))
 			return_0;
 
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 3c30b3576..b832f890d 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -152,12 +152,12 @@ static int _snap_target_present(struct cmd_context *cmd,
 	if (!_snap_checked) {
 		_snap_checked = 1;
 
-		if (!(_snap_present = target_present(cmd, TARGET_NAME_SNAPSHOT, 1) &&
-		      target_present(cmd, TARGET_NAME_SNAPSHOT_ORIGIN, 0)))
+		if (!(_snap_present = (target_present_version(cmd, TARGET_NAME_SNAPSHOT, 1,
+							      &maj, &min, &patchlevel) &&
+				       target_present(cmd, TARGET_NAME_SNAPSHOT_ORIGIN, 0)))
 			return 0;
 
-		if (target_version(TARGET_NAME_SNAPSHOT, &maj, &min, &patchlevel) &&
-		    (maj > 1 ||
+		if ((maj > 1 ||
 		     (maj == 1 && (min >= 12 || (min == 10 && patchlevel >= 2)))))
 			_snap_attrs |= SNAPSHOT_FEATURE_FIXED_LEAK;
 		else
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 51bc269ae..5f3015026 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -690,12 +690,10 @@ static int _thin_target_present(struct cmd_context *cmd,
 	if (!_checked) {
 		_checked = 1;
 
-		if (!(_present = target_present(cmd, _thin_pool_module, 1)))
+		if (!(_present = target_present_version(cmd, _thin_pool_module, 1,
+							&maj, &min, &patchlevel)))
 			return 0;
 
-		if (!target_version(_thin_pool_module, &maj, &min, &patchlevel))
-			return_0;
-
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
 			if ((maj > _features[i].maj) ||
 			    (maj == _features[i].maj && min >= _features[i].min))
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index bb7c78449..f26874ce5 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -419,7 +419,7 @@ static int _vdo_target_present(struct cmd_context *cmd,
 			/* Try to load kmod VDO module */
 			if (!module_present(cmd, MODULE_NAME_VDO) ||
 			    !target_version(TARGET_NAME_VDO, &maj, &min, &patchlevel))
-				return_0;
+				return 0;
 		}
 
 		if (maj < 6 || (maj == 6 && min < 2)) {
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 2cef9f26e..d114d698c 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -238,17 +238,9 @@ static int _target_present(struct cmd_context *cmd,
 
 	if (!_writecache_checked) {
 		_writecache_checked = 1;
-		_writecache_present = target_present(cmd, TARGET_NAME_WRITECACHE, 1);
-
-		if (!_writecache_present) {
-			log_error("dm-writecache module not found in kernel.");
+		if (!(_writecache_present = target_present_version(cmd, TARGET_NAME_WRITECACHE, 1.
+								   &maj, &min, &patchlevel)))
 			return 0;
-		}
-
-		if (!target_version(TARGET_NAME_WRITECACHE, &maj, &min, &patchlevel)) {
-			log_error("dm-writecache module version not found.");
-			return_0;
-		}
 
 		if (maj < 1) {
 			log_error("dm-writecache module version older than minimum 1.0.0");


