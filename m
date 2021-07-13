From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Jul 2021 21:14:13 +0000 (GMT)
Subject: main - pvscan: do nothing for device removal and event_activation=0
Message-ID: <20210713211413.769AC385781D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25f0f5daac5606e557d2124c219f5bb255c5d9dc
Commit:        25f0f5daac5606e557d2124c219f5bb255c5d9dc
Parent:        f8b52f2763cd029422147fa97928661bd67ebd03
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 13 15:34:05 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 13 16:09:54 2021 -0500

pvscan: do nothing for device removal and event_activation=0

The lvm2-pvscan service runs pvscan --cache -aay <dev> for
device addition, and pvscan --cache <dev> on device removal.
For event_activation=0, the addition does nothing.  Fix
device removal to also do nothing for event_activation=0.
Device removal was previously doing some work to process
the removal which slowed down stopping lvm2-pvscan services.
---
 tools/pvscan.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 40a93957c..78cb5e764 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1619,12 +1619,6 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->check_devs_used = 0;
 
-	if (do_activate &&
-	    !find_config_tree_bool(cmd, global_event_activation_CFG, NULL)) {
-		log_verbose("Ignoring pvscan --cache -aay because event_activation is disabled.");
-		return ECMD_PROCESSED;
-	}
-
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;
 
@@ -1635,6 +1629,11 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	do_all = !argc && !devno_args;
 
+	if (!do_all && !find_config_tree_bool(cmd, global_event_activation_CFG, NULL)) {
+		log_verbose("Ignoring pvscan --cache because event_activation is disabled.");
+		return ECMD_PROCESSED;
+	}
+
 	_online_dir_setup();
 
 	if (do_all) {


