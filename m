From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  8 Aug 2016 15:39:43 +0000 (UTC)
Subject: master - lvconvert: separate type raid to mirror
Message-ID: <20160808153943.35C3860E61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc93085c7a7716671c3567d367dd2c75544a058b
Commit:        fc93085c7a7716671c3567d367dd2c75544a058b
Parent:        6f90c954b72a5bad8cdeddebea4b3dc5981322c7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 8 10:37:24 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 8 10:37:24 2016 -0500

lvconvert: separate type raid to mirror

By the current division of unique operations,
converting type raid to type mirror is distinct
from converting type raid to raid.
---
 man/lvconvert.8.in |    6 ++++++
 tools/lvconvert.c  |   15 ++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 5ddea3d..641e850 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -452,6 +452,12 @@ Convert RaidLV to use a different raid level.
 \[bu]
 Required options depend on the raid level.
 
+.B lvconvert \-\-type mirror
+VG/RaidLV
+.br
+\[bu]
+Convert RaidLV to type mirror.
+
 .B lvconvert \-\-type striped
 VG/RaidLV
 .br
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e7c34f7..8dc9f6d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3922,6 +3922,16 @@ static int _convert_raid_raid(struct cmd_context *cmd, struct logical_volume *lv
 }
 
 /*
+ * Convert a raid* LV to a mirror LV.
+ * lvconvert --type mirror LV
+ */
+static int _convert_raid_mirror(struct cmd_context *cmd, struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
+
+/*
  * Convert a raid* LV to a striped LV.
  * lvconvert --type striped LV
  */
@@ -4282,9 +4292,12 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
 		return _convert_raid_cache_pool(cmd, lv, lp);
 
-	if (segtype_is_raid(lp->segtype) || segtype_is_mirror(lp->segtype))
+	if (segtype_is_raid(lp->segtype))
 		return _convert_raid_raid(cmd, lv, lp);
 
+	if (segtype_is_mirror(lp->segtype))
+		return _convert_raid_mirror(cmd, lv, lp);
+
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED))
 		return _convert_raid_striped(cmd, lv, lp);
 


