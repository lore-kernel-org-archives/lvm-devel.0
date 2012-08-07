From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:37 +0000 (UTC)
Subject: master - thin: mention discard/zero in lvchange errmsg
Message-ID: <20120807203037.B50373506@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b51241a346be6f31a525c1d547bed12ba2df34a3
Commit:        b51241a346be6f31a525c1d547bed12ba2df34a3
Parent:        d01f8ee684992eaf4efc06453ee07cb2b9ebf49c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 20:08:14 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 20:08:14 2012 +0100

thin: mention discard/zero in lvchange errmsg

---
 tools/lvchange.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index c5cbe08..1a4318f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -98,7 +98,7 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 	thin_discard_t discard;
 
 	if (!lv_is_thin_pool(lv)) {
-		log_error("Logical volume \"%s\" is not a thinpool.", lv->name);
+		log_error("Logical volume \"%s\" is not a thin pool.", lv->name);
 		return 0;
 	}
 
@@ -839,15 +839,14 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
 		arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG) ||
-		arg_count(cmd, discard_ARG) ||
-		arg_count(cmd, zero_ARG);
+		arg_count(cmd, discard_ARG) || arg_count(cmd, zero_ARG);
 
 	if (!update &&
             !arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG) &&
             !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG)) {
-		log_error("Need 1 or more of -a, -C, -M, -p, -r, "
+		log_error("Need 1 or more of -a, -C, -M, -p, -r, -Z, "
 			  "--resync, --refresh, --alloc, --addtag, --deltag, "
-			  "--monitor or --poll");
+			  "--monitor, --poll or --discard");
 		return EINVALID_CMD_LINE;
 	}
 


