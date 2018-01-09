From: David Teigland <teigland@sourceware.org>
Date: Tue, 9 Jan 2018 12:20:56 -0500
Subject: master - lvmlockd: add lockopt values for skipping selected locks
Message-ID: <201801091720.w09HKuqg000719@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46cedb105bb7fdba0107794ca5801c2a0e8fd524
Commit:        46cedb105bb7fdba0107794ca5801c2a0e8fd524
Parent:        f4675af4cfbc0139ba94ec3f18b15c09bf106a61
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 9 11:18:57 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 9 11:20:10 2018 -0600

lvmlockd: add lockopt values for skipping selected locks

and add lockopt to common options.
---
 tools/command-lines.in |    9 ++++-----
 tools/lvmcmdline.c     |   10 ++++++++++
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index d0e5e06..a1776ce 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -187,7 +187,7 @@
 # OO_ALL is included in every command automatically.
 #
 OO_ALL: --commandprofile String, --config String, --debug,
---driverloaded Bool, --help, --longhelp, --profile String, --quiet,
+--driverloaded Bool, --help, --lockopt String, --longhelp, --profile String, --quiet,
 --verbose, --version, --yes, --test
 
 #
@@ -1524,19 +1524,18 @@ ID: vgchange_systemid
 DESC: Change the system ID of a VG.
 
 vgchange --lockstart
-OO: --lockopt String, --select String
+OO: --select String
 OP: VG|Tag|Select ...
 ID: vgchange_lockstart
 DESC: Start the lockspace of a shared VG in lvmlockd.
 
 vgchange --lockstop
-OO: --lockopt String, --select String
+OO: --select String
 OP: VG|Tag|Select ...
 ID: vgchange_lockstop
 DESC: Stop the lockspace of a shared VG in lvmlockd.
 
 vgchange --locktype LockType VG
-OO: --lockopt String
 ID: vgchange_locktype
 DESC: Change the lock type for a shared VG.
 
@@ -1563,7 +1562,7 @@ OO: --addtag Tag, --alloc Alloc, --autobackup Bool, --clustered Bool, --maxlogic
 --physicalextentsize SizeMB, --force, --zero Bool, --labelsector Number,
 --metadatasize SizeMB, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
 --reportformat ReportFmt, --dataalignment SizeKB, --dataalignmentoffset SizeKB,
---shared, --systemid String, --locktype LockType, --lockopt String
+--shared, --systemid String, --locktype LockType
 ID: vgcreate_general
 
 ---
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b693722..791e272 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2682,6 +2682,16 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 		return 1;
 	}
 
+	if (use_lvmlockd && arg_is_set(cmd, lockopt_ARG)) {
+		const char *opts = arg_str_value(cmd, lockopt_ARG, "");
+		if (strstr(opts, "skiplv"))
+			cmd->lockd_lv_disable = 1;
+		if (strstr(opts, "skipvg"))
+			cmd->lockd_vg_disable = 1;
+		if (strstr(opts, "skipgl"))
+			cmd->lockd_gl_disable = 1;
+	}
+
 	if (use_lvmlockd && locking_is_clustered()) {
 		log_error("ERROR: configuration setting use_lvmlockd cannot be used with clustered locking_type 3.");
 		return 0;


