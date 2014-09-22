From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:59 +0000 (UTC)
Subject: dev-dct-process-latest - toollib: remove unused arg from process_each_lv_in_vg
Message-ID: <20140922153959.2FA6360D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ced473a352ceca9ef9759c98eaaca8f9a9a7fe7c
Commit:        ced473a352ceca9ef9759c98eaaca8f9a9a7fe7c
Parent:        bb21649a4700b5a19251def33a3a3418b5d0830d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 28 14:32:13 2013 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:23 2014 -0500

toollib: remove unused arg from process_each_lv_in_vg

The failed_lvnames arg is no longer used since the
cmd_vg replicator wrapper was removed.
---
 tools/toollib.c   |    3 +--
 tools/toollib.h   |    1 -
 tools/vgdisplay.c |    2 +-
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 31e2fcf..d222da9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1688,7 +1688,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  struct dm_list *arg_lvnames,
 			  const struct dm_list *tags_in,
-			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv)
 {
@@ -1959,7 +1958,7 @@ static int process_lv_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 			continue;
 		}
 
-		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, NULL,
+		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
 					    handle, process_single_lv);
 		unlock_and_release_vg(cmd, vg, vg_name);
 
diff --git a/tools/toollib.h b/tools/toollib.h
index c605aed..3f21470 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -88,7 +88,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tagsl,
-			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv);
 
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index a739d11..39cdaf3 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -39,7 +39,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, verbose_ARG)) {
 		vgdisplay_extents(vg);
 
-		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL, NULL,
+		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");


