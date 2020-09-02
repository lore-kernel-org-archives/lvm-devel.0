From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Sep 2020 19:22:18 +0000 (GMT)
Subject: master - pvck: repair should clear hints
Message-ID: <20200902192218.8A7CE3857C48@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5a669f3145c92220346871bad4ab1c0149a1cc2
Commit:        f5a669f3145c92220346871bad4ab1c0149a1cc2
Parent:        8b9028bbe7a6f2e01ba6bddcf256d02fc11d4858
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 2 14:21:17 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 2 14:21:17 2020 -0500

pvck: repair should clear hints

repairing a pv can cause the hint file to become incorrect
---
 test/shell/hints.sh | 15 +++++++++++++++
 tools/pvck.c        |  2 ++
 2 files changed, 17 insertions(+)

diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index f95505a20..176ee2176 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -338,6 +338,21 @@ pvs
 not diff $HINTS $PREV
 
 
+#
+# Test pvck --repair forces refresh
+#
+
+rm $HINTS $PREV
+pvs
+cp $HINTS $PREV
+pvck --repairtype label_header -y "$dev5"
+cat $NEWHINTS
+grep 'Created empty by pvck' $HINTS
+# this next pvs creates new hints
+pvs
+# the only diff will be "Created by..."
+not diff $HINTS $PREV
+
 
 #
 # Test incorrect dev-to-pvid info in hints is detected
diff --git a/tools/pvck.c b/tools/pvck.c
index 302c74621..39449af68 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3037,6 +3037,8 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, repairtype_ARG) || arg_is_set(cmd, repair_ARG)) {
 		pv_name = argv[0];
 
+		clear_hint_file(cmd);
+
 		if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
 			log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
 			return ECMD_FAILED;


