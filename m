From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 14 Feb 2018 07:36:30 -0500
Subject: master - mirror: Add deprecation warning for mirrored log
Message-ID: <201802141236.w1ECaUVg014879@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d67f1602005b4f83e5949668a0cf4e7e5ff0c7d2
Commit:        d67f1602005b4f83e5949668a0cf4e7e5ff0c7d2
Parent:        dd6fbcbb6941b0d534689258f7f07f567ee6f352
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Feb 14 12:46:08 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Feb 14 13:32:04 2018 +0100

mirror: Add deprecation warning for mirrored log

---
 lib/metadata/mirror.c |    4 ++++
 tools/lvconvert.c     |    5 +++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 38c3df6..71d3457 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1945,6 +1945,10 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		return 1;
 	}
 
+	if (log_count > 1) {
+		log_warn("Log type \"mirrored\" is DEPRECATED and will be removed in the future. Use RAID1 LV or disk log instead.");
+	}
+
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
 		return_0;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fee0a4e..e18ec23 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1216,6 +1216,11 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	    (old_log_count == new_log_count))
 		return 1;
 
+	if ((old_log_count != new_log_count) &&
+	    (new_log_count == MIRROR_LOG_MIRRORED)) {
+		log_warn("Log type \"mirrored\" is DEPRECATED and will be removed in the future. Use RAID1 LV or disk log instead.");
+	}
+
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
 				    new_mimage_count, new_log_count, lp->pvh))
 		return_0;


