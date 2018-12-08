From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 7 Dec 2018 20:53:47 -0500
Subject: master - lvcreate/lvconvert: prohibit creation of/conversion to mirrored mirror logs
Message-ID: <201812080153.wB81rlm5026071@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edb72cb70cb8abd0acb92f07937715be2816d04a
Commit:        edb72cb70cb8abd0acb92f07937715be2816d04a
Parent:        a4b8377488f82c496b14ee6d644fc681968acaca
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 7 19:56:49 2018 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Dec 8 02:52:50 2018 +0100

lvcreate/lvconvert: prohibit creation of/conversion to mirrored mirror logs

In RHEL7 we marked mirrored mirror logs as deprecated and
added a related message.  This patch prohibits creating new
'mirror' LVs with that log type or converting existing LVs
to have one.

Existing LVs with mirrored mirror log can be activated
and converted to disk/core logs.

Avoid double deprecation message when running lvconvert.

Resolves: rhbz1643562
---
 lib/metadata/mirror.c |    3 ++-
 tools/lvconvert.c     |    5 -----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index ba3f33d..8b20979 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1908,7 +1908,8 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (log_count > 1) {
-		log_warn("WARNING: Log type \"mirrored\" is DEPRECATED and will be removed in the future. Use RAID1 LV or disk log instead.");
+		log_err("Log type \"mirrored\" is DEPRECATED. Use RAID1 LV or disk log instead.");
+		return 0;
 	}
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 65a4ed3..dbc9fea 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1262,11 +1262,6 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	    (old_log_count == new_log_count))
 		return 1;
 
-	if ((old_log_count != new_log_count) &&
-	    (new_log_count == MIRROR_LOG_MIRRORED)) {
-		log_warn("WARNING: Log type \"mirrored\" is DEPRECATED and will be removed in the future. Use RAID1 LV or disk log instead.");
-	}
-
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
 				    new_mimage_count, new_log_count, lp->pvh))
 		return_0;


