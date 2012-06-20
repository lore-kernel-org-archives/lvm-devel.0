From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jun 2012 12:49:13 +0000 (UTC)
Subject: master - cleanup: use struct initializers instead of memset
Message-ID: <20120620124913.27741168A@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba222c6e35dd08d7e3665b187eacdd61e6f678d4
Commit:        ba222c6e35dd08d7e3665b187eacdd61e6f678d4
Parent:        865b9d3701e075484888ac23ceb5c29d73b06154
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 30 17:17:25 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 20 14:47:54 2012 +0200

cleanup: use struct initializers instead of memset

No need to call memset if we the language can do that.
---
 tools/lvresize.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 9662eb9..55d1334 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -86,9 +86,7 @@ static int _request_confirmation(struct cmd_context *cmd,
 				 const struct logical_volume *lv,
 				 const struct lvresize_params *lp)
 {
-	struct lvinfo info;
-
-	memset(&info, 0, sizeof(info));
+	struct lvinfo info = { 0 };
 
 	if (!lv_info(cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
 		log_error("lv_info failed: aborting");
@@ -738,8 +736,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			return ECMD_FAILED;
 		}
 
-		memset(&info, 0, sizeof(info));
-
 		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
 			log_error("Snapshot origin volumes can be resized "
 				  "only while inactive: try lvchange -an");
@@ -873,12 +869,10 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 int lvresize(struct cmd_context *cmd, int argc, char **argv)
 {
-	struct lvresize_params lp;
+	struct lvresize_params lp = { 0 };
 	struct volume_group *vg;
 	int r;
 
-	memset(&lp, 0, sizeof(lp));
-
 	if (!_lvresize_params(cmd, argc, argv, &lp))
 		return EINVALID_CMD_LINE;
 


