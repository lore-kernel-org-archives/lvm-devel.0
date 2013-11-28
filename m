From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:51 +0000 (UTC)
Subject: master - toollib: drop init of ret
Message-ID: <20131128114851.26AF060F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1eda8ea245ec7af684fb50e7f0abf5229d9bcfb
Commit:        a1eda8ea245ec7af684fb50e7f0abf5229d9bcfb
Parent:        8724c0fcebcc35df980e6819e5c531f213fe2767
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 22:27:32 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:45:52 2013 +0100

toollib: drop init of ret

Keep the ret uninitialized, so we get compiler warning, when tried
to use this value instead of ret_max as function return value.
---
 tools/toollib.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 90a7cb8..654384d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -190,7 +190,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  process_single_lv_fn_t process_single_lv)
 {
 	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
+	int ret;
 	unsigned process_all = 0;
 	unsigned process_lv = 0;
 	unsigned tags_supplied = 0;
@@ -302,7 +302,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 {
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
+	int ret;
 
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
@@ -724,7 +724,7 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  process_single_pv_fn_t process_single_pv)
 {
 	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
+	int ret;
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
@@ -810,7 +810,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 {
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
+	int ret;
 	int lock_global = !(flags & READ_WITHOUT_LOCK) && !(flags & READ_FOR_UPDATE) && !lvmetad_active();
 
 	struct pv_list *pvl;
@@ -1803,7 +1803,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 	struct device *dev;
 
 	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
+	int ret;
 	int opt = 0;
 
 	if (argc) {


