From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  9 Feb 2021 14:06:53 +0000 (GMT)
Subject: stable-2.02 - targets: use target_present_version
Message-ID: <20210209140653.76CBE398B17C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a1e8104f84849dc198af1be2f8d51942621a1e2
Commit:        6a1e8104f84849dc198af1be2f8d51942621a1e2
Parent:        0f074a4d65bb950e25b13d7ac9aa63361ea774a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 21:48:18 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 9 15:04:18 2021 +0100

targets: use target_present_version

Skip duplicated  dm version   ioctl() on every startup.
---
 lib/mirror/mirrored.c   | 3 ++-
 lib/raid/raid.c         | 6 ++----
 lib/snapshot/snapshot.c | 8 ++++----
 lib/thin/thin.c         | 6 ++----
 4 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 606bcf0ee..ec1cab538 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -412,7 +412,8 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 	if (!_mirrored_checked) {
 		_mirrored_checked = 1;
 
-		if (!(_mirrored_present = target_present(cmd, TARGET_NAME_MIRROR, 1)))
+		if (!(_mirrored_present = target_present_version(cmd, TARGET_NAME_MIRROR, 1,
+								 &maj, &min, &patchlevel)))
 			return 0;
 
 		/*
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index f75c676e8..8ab2d20ec 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -550,10 +550,8 @@ static int _raid_target_present(struct cmd_context *cmd,
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
index 5fd39e9f8..695fbd6d4 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -151,12 +151,12 @@ static int _snap_target_present(struct cmd_context *cmd,
 	if (!_snap_checked) {
 		_snap_checked = 1;
 
-		if (!(_snap_present = target_present(cmd, TARGET_NAME_SNAPSHOT, 1) &&
-		      target_present(cmd, TARGET_NAME_SNAPSHOT_ORIGIN, 0)))
+		if (!(_snap_present = (target_present_version(cmd, TARGET_NAME_SNAPSHOT, 1,
+							      &maj, &min, &patchlevel) &&
+				       target_present(cmd, TARGET_NAME_SNAPSHOT_ORIGIN, 0))))
 			return 0;
 
-		if (target_version(TARGET_NAME_SNAPSHOT, &maj, &min, &patchlevel) &&
-		    (maj > 1 ||
+		if ((maj > 1 ||
 		     (maj == 1 && (min >= 12 || (min == 10 && patchlevel >= 2)))))
 			_snap_attrs |= SNAPSHOT_FEATURE_FIXED_LEAK;
 		else
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 8ab60ce1e..c77fe5c7c 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -689,12 +689,10 @@ static int _thin_target_present(struct cmd_context *cmd,
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


