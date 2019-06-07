From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:51 -0400
Subject: master - vgcfgbackup add error messages
Message-ID: <201906072108.x57L8pBZ005339@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5dd32680b0cbe468c07b3187bbb8922323b848f8
Commit:        5dd32680b0cbe468c07b3187bbb8922323b848f8
Parent:        47effdc025384cef5b3235a9c4b90e7fd74d68a4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 6 13:46:35 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

vgcfgbackup add error messages

---
 tools/vgcfgbackup.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 7d061d5..5a0fb13 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -73,6 +73,15 @@ static int _vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 			return ECMD_FAILED;
 		}
 
+		if (vg_missing_pv_count(vg)) {
+			log_error("No backup taken: specify filename with -f to backup with missing PVs.");
+			return ECMD_FAILED;
+		}
+		if (vg_has_unknown_segments(vg)) {
+			log_error("No backup taken: specify filename with -f to backup with unknown segments.");
+			return ECMD_FAILED;
+		}
+
 		/* just use the normal backup code */
 		backup_enable(cmd, 1);	/* force a backup */
 		if (!backup(vg))
@@ -97,6 +106,14 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &last_filename;
 
+	/*
+	 * Just set so that we can do the check ourselves above and
+	 * report a helpful error message in place of the error message
+	 * that would be generated from vg_read.
+	 */
+	cmd->handles_missing_pvs = 1;
+	cmd->handles_unknown_segments = 1;
+
 	init_pvmove(1);
 
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_INCONSISTENT, 0,


