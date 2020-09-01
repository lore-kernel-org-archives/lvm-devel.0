From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:11 +0000 (GMT)
Subject: master - cleanup: user force_t enums instead of ints
Message-ID: <20200901170211.0731E3954085@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a37565709232085a61063385c1042a0ade0bc10b
Commit:        a37565709232085a61063385c1042a0ade0bc10b
Parent:        dbb19f6ace5210a880f107cbae34081db0457d1e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 21:53:05 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

cleanup: user force_t enums instead of ints

---
 tools/lvcreate.c | 4 ++--
 tools/vgextend.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 3357a08c5..e384291ae 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1826,7 +1826,7 @@ static int _lvcreate_and_attach_writecache_single(struct cmd_context *cmd,
 		log_error("Removing new LV after failing to add writecache.");
 		if (!deactivate_lv(cmd, lv))
 			log_error("Failed to deactivate new LV %s.", display_lvname(lv));
-		if (!lv_remove_with_dependencies(cmd, lv, 1, 0))
+		if (!lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0))
 			log_error("Failed to remove new LV %s.", display_lvname(lv));
 		return ECMD_FAILED;
 	}
@@ -1900,7 +1900,7 @@ static int _lvcreate_and_attach_cache_single(struct cmd_context *cmd,
 		log_error("Removing new LV after failing to add cache.");
 		if (!deactivate_lv(cmd, lv))
 			log_error("Failed to deactivate new LV %s.", display_lvname(lv));
-		if (!lv_remove_with_dependencies(cmd, lv, 1, 0))
+		if (!lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0))
 			log_error("Failed to remove new LV %s.", display_lvname(lv));
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgextend.c b/tools/vgextend.c
index da768981d..dca87ff62 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -161,7 +161,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	pp->preserve_existing = 1;
 
 	/* pvcreate within vgextend cannot be forced. */
-	pp->force = 0;
+	pp->force = PROMPT;
 
 	if (!lock_global(cmd, "ex"))
 		return_ECMD_FAILED;


