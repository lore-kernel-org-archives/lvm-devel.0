From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:07 -0400
Subject: master - lvmlockd: do not use an LV lock for some lvchange options
Message-ID: <201805311414.w4VEE7E8031147@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f7ec769d98cfe7af47b202189b279f354763b5a
Commit:        7f7ec769d98cfe7af47b202189b279f354763b5a
Parent:        cd369d8a7fc5324f66d9965528ef9b92828b1a19
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 24 11:41:14 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

lvmlockd: do not use an LV lock for some lvchange options

Some lvchange options can be used even if the LV is active.
---
 lib/locking/lvmlockd.c |    5 +++--
 tools/lvchange.c       |    8 +++++---
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index bf9b7a9..7f4fb2e 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2105,8 +2105,9 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (result == -EEXIST) {
 		/*
-		 * This happens if lvchange tries to modify the LV with an ex
-		 * LV lock when the LV is already active with a sh LV lock.
+		 * This happens if a command like lvchange tries to modify the
+		 * LV with an ex LV lock when the LV is already active with a
+		 * sh LV lock.
 		 */
 		log_error("LV is already locked with incompatible mode: %s/%s", vg->name, lv_name);
 		return 0;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0aac5ac..6144852 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1056,9 +1056,11 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 	int i, opt_enum;
 	uint32_t mr = 0;
 
-	/* If LV is inactive here, ensure it's not active elsewhere. */
-	if (!lockd_lv(cmd, lv, "ex", 0))
-		return_ECMD_FAILED;
+	/*
+	 * We do not acquire an lvmlockd lock on the LV here because these are
+	 * VG metadata changes that do not conflict with the LV being active on
+	 * another host.
+	 */
 
 	/* First group of options which allow for one metadata commit/update for the whole group */
 	for (i = 0; i < cmd->command->ro_count; i++) {


