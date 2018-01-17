From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:33 -0500
Subject: master - pvmove: drop misleading pvmove restriction for cluster
Message-ID: <201801171346.w0HDkXRP029941@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02621cffb0d5ff72adb8770e26c1b4adb95bd0d9
Commit:        02621cffb0d5ff72adb8770e26c1b4adb95bd0d9
Parent:        5a961d3411c8c11312d2998378277efc8988fc7f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 11 16:15:16 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:44:33 2018 +0100

pvmove: drop misleading pvmove restriction for cluster

pvmove handles properly locked LVs in cluster and this extra check
actually cause misbehavior as some LVs were silently skipped from
operation scope.
---
 tools/pvmove.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 9bbe12b..c5d7e52 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -371,16 +371,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (lv_name && strcmp(lv->name, top_level_lv_name(vg, lv_name)))
 			continue;
 
-		/*
-		 * RAID, thin and snapshot-related LVs are not
-		 * processed in a cluster, so we don't have to
-		 * worry about avoiding certain PVs in that context.
-		 *
-		 * Allow clustered mirror, but not raid mirror.
-		 */
-		if (vg_is_clustered(vg) && !lv_is_mirror_type(lv))
-			continue;
-
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 


