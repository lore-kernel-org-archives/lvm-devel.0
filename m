From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Aug 2021 19:51:30 +0000 (GMT)
Subject: main - lvmdevices: check yes option for adding duplicate
Message-ID: <20210820195130.9C161385801E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0bda7c25b19d9254f65dec4a8e1011204de98e6
Commit:        b0bda7c25b19d9254f65dec4a8e1011204de98e6
Parent:        96b777167c63eaf2e8ef1a2e7a92dc6c66cbcd6a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 18 16:26:11 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 19 13:00:43 2021 -0500

lvmdevices: check yes option for adding duplicate

---
 lib/commands/toolcontext.h | 1 +
 lib/device/device_id.c     | 3 ++-
 tools/lvmcmdline.c         | 2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 1a1785bfe..a19a9dea2 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -30,6 +30,7 @@ struct config_info {
 	int verbose;
 	int silent;
 	int test;
+	int yes;
 	int syslog;
 	int activation;
 	int suffix;
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 164a3e2ba..bca6b4f1f 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1138,7 +1138,8 @@ id_done:
 				 du_pvid->dev ? dev_name(du_pvid->dev) : "none", du_pvid->idname,
 				 pvid);
 
-			if (yes_no_prompt("Add device with duplicate PV to devices file?") == 'n') {
+			if (!cmd->current_settings.yes &&
+			    yes_no_prompt("Add device with duplicate PV to devices file?") == 'n') {
 				log_print("Device not added.");
 				free((void *)check_idname);
 				return 1;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4b63d48e3..47ab2f3d8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2446,6 +2446,8 @@ static int _get_current_settings(struct cmd_context *cmd)
 	if (arg_is_set(cmd, test_ARG))
 		cmd->current_settings.test = arg_is_set(cmd, test_ARG);
 
+	cmd->current_settings.yes = arg_count(cmd, yes_ARG);
+
 	if (arg_is_set(cmd, driverloaded_ARG)) {
 		cmd->current_settings.activation =
 		    arg_int_value(cmd, driverloaded_ARG,


