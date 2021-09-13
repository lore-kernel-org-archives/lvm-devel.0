From: David Teigland <teigland@sourceware.org>
Date: Mon, 13 Sep 2021 16:47:24 +0000 (GMT)
Subject: main - add --nohints option
Message-ID: <20210913164724.63DF13858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9857b5a3dc7b23295e47e04c5c338d189c3502d5
Commit:        9857b5a3dc7b23295e47e04c5c338d189c3502d5
Parent:        b36ab8a0639e85a5674a83808ccbb526a7191699
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 10 15:57:19 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 13 10:55:07 2021 -0500

add --nohints option

The command will not use the hints file to locate devices for PVs.
It will still do standard hint file invalidation where appropriate.
---
 test/shell/hints.sh    | 53 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/args.h           |  5 +++++
 tools/command-lines.in |  2 +-
 tools/lvmcmdline.c     |  8 ++++++++
 4 files changed, 67 insertions(+), 1 deletion(-)

diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 4fba5cae4..506c005dd 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -37,6 +37,57 @@ aux prepare_devs 6
 pvs
 not grep scan: $HINTS
 
+#
+# test --nohints option
+#
+
+pvcreate "$dev1"
+pvcreate "$dev2"
+# pvs --nohints does not create hints
+pvs --nohints |tee out
+grep "$dev1" out
+grep "$dev2" out
+not grep "$dev1" $HINTS
+not grep "$dev2" $HINTS
+# pvs creates hints
+pvs
+grep "$dev1" $HINTS
+grep "$dev2" $HINTS
+
+# save hints with dev1 and dev2 before dev3 is created
+cp $HINTS $PREV
+# pvcreate --nohints invalidates hints
+pvcreate --nohints "$dev3"
+ls $NEWHINTS
+# pvs --nohints does not update hints
+pvs --nohints |tee out
+grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+not grep "$dev3" $HINTS
+# restore old hint file without dev3
+cp $PREV $HINTS
+# pvs --nohints does not update hints
+pvs --nohints |tee out
+grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+grep "$dev1" $HINTS
+grep "$dev2" $HINTS
+not grep "$dev3" $HINTS
+# pvs updates hints
+pvs |tee out
+grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+grep "$dev1" $HINTS
+grep "$dev2" $HINTS
+grep "$dev3" $HINTS
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+
 #
 # vg1 uses dev1,dev2
 #
@@ -44,6 +95,8 @@ not grep scan: $HINTS
 # and that only PVs are scanned when using hints.
 #
 
+rm $HINTS
+
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 $vg1
 
diff --git a/tools/args.h b/tools/args.h
index d4f23f849..05c16d94a 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -460,6 +460,11 @@ arg(noheadings_ARG, '\0', "noheadings", 0, 0, 0,
     "Suppress the headings line that is normally the first line of output.\n"
     "Useful if grepping the output.\n")
 
+arg(nohints_ARG, '\0', "nohints", 0, 0, 0,
+    "Do not use the hints file to locate devices for PVs. A command may read\n"
+    "more devices to find PVs when hints are not used. The command will still\n"
+    "perform standard hint file invalidation where appropriate.\n")
+
 arg(nohistory_ARG, '\0', "nohistory", 0, 0, 0,
     "Do not record history of LVs being removed.\n"
     "This has no effect unless the configuration setting\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 0bc5a4989..73a4c57f9 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -204,7 +204,7 @@
 #
 OO_ALL: --commandprofile String, --config String, --debug,
 --driverloaded Bool, --help, --nolocking, --lockopt String, --longhelp, --profile String, --quiet,
---verbose, --version, --yes, --test, --devicesfile String, --devices PV
+--verbose, --version, --yes, --test, --devicesfile String, --devices PV, --nohints
 
 #
 # options for pvs, lvs, vgs, fullreport
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f9eab8ec8..de70e63c9 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2512,6 +2512,14 @@ static int _get_current_settings(struct cmd_context *cmd)
 	if (arg_is_set(cmd, sysinit_ARG))
 		cmd->use_hints = 0;
 
+	/*
+	 * Don't use hints from this command, but enable_hints will
+	 * remain set unless hints=none in the config.  See above re
+	 * the meaning of use_hints=0 && enable_hints=1.
+	 */
+	if (arg_is_set(cmd, nohints_ARG))
+		cmd->use_hints = 0;
+
 	if ((hint_mode = find_config_tree_str(cmd, devices_hints_CFG, NULL))) {
 		if (!strcmp(hint_mode, "none")) {
 			cmd->enable_hints = 0;


