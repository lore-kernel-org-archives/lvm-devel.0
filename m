From: David Teigland <teigland@sourceware.org>
Date: Wed, 17 Nov 2021 16:57:42 +0000 (GMT)
Subject: main - display: ignore --reportformat
Message-ID: <20211117165742.6AFC73858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8f4ec846d8f4f5256b2737a6d6127482ef7b44e
Commit:        b8f4ec846d8f4f5256b2737a6d6127482ef7b44e
Parent:        e4b8726b6d4ba9fc4b1f6e79339b1fecb2d890b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 17 10:40:27 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 17 10:40:27 2021 -0600

display: ignore --reportformat

Using the option would do nothing useful but would
print extraneous braces.
---
 tools/command-lines.in | 12 ++++++------
 tools/lvmcmdline.c     | 15 +++++++++++++++
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index d4691c686..6f431e233 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1359,10 +1359,10 @@ OO: --aligned, --all, --binary, --colon, --columns,
 --configreport ConfigReport, --foreign, --history, --ignorelockingfailure,
 --logonly, --maps, --noheadings,
 --nosuffix, --options String, --sort String, --readonly,
---reportformat ReportFmt, --segments, --select String, --separator String,
+--segments, --select String, --separator String,
 --shared, --unbuffered, --units Units
 OP: VG|LV|Tag ...
-IO: --partial, --ignoreskippedcluster
+IO: --partial, --ignoreskippedcluster, --reportformat ReportFmt
 ID: lvdisplay_general
 
 ---
@@ -1590,10 +1590,10 @@ pvdisplay
 OO: --aligned, --all, --binary, --colon, --columns, --configreport ConfigReport,
 --foreign, --ignorelockingfailure,
 --logonly, --maps, --noheadings, --nosuffix, --options String,
---readonly, --reportformat ReportFmt, --select String, --separator String, --shared,
+--readonly, --select String, --separator String, --shared,
 --short, --sort String, --unbuffered, --units Units
 OP: PV|Tag ...
-IO: --ignoreskippedcluster
+IO: --ignoreskippedcluster, --reportformat ReportFmt
 ID: pvdisplay_general
 
 ---
@@ -1811,10 +1811,10 @@ vgdisplay
 OO: --activevolumegroups, --aligned, --binary, --colon, --columns,
 --configreport ConfigReport, --foreign, --ignorelockingfailure,
 --logonly, --noheadings, --nosuffix,
---options String, --readonly, --reportformat ReportFmt, --select String,
+--options String, --readonly, --select String,
 --shared, --short, --separator String, --sort String, --unbuffered, --units Units
 OP: VG|Tag ...
-IO: --partial, --ignoreskippedcluster
+IO: --partial, --ignoreskippedcluster, --reportformat ReportFmt
 ID: vgdisplay_general
 
 ---
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a28d98ecf..7e3afc241 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3060,6 +3060,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	int i;
 	int skip_hyphens;
 	int refresh_done = 0;
+	int io;
 
 	/* Avoid excessive access to /etc/localtime and set TZ variable for glibc
 	 * so it does not need to check /etc/localtime everytime that needs that info */
@@ -3142,6 +3143,20 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (!(cmd->command = _find_command(cmd, cmd->name, &argc, argv)))
 		return EINVALID_CMD_LINE;
 
+	/*
+	 * If option --foo is set which is listed in IO (ignore option) in
+	 * command-lines.in, then unset foo.  Commands won't usually use an
+	 * ignored option, but there can be shared code that checks for --foo,
+	 * and should not find it to be set.
+	 */
+	for (io = 0; io < cmd->command->io_count; io++) {
+		int opt = cmd->command->ignore_opt_args[io].opt;
+		if (arg_is_set(cmd, opt)) {
+			log_debug("Ignore opt %d", opt);
+			cmd->opt_arg_values[opt].count = 0;
+		}
+	}
+
 	/*
 	 * Remaining position args after command name and --options are removed.
 	 */


