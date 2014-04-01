From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  1 Apr 2014 13:01:55 +0000 (UTC)
Subject: master - pvs: Wipe persistent filters when given a device argument.
Message-ID: <20140401130155.A2FAB60E98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=490226fc475232e0b158cf9fdc8670a663da4efe
Commit:        490226fc475232e0b158cf9fdc8670a663da4efe
Parent:        a30219a8c0ba2d9f5ce6402ff2edbd0ece263166
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Apr 1 14:46:22 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Apr 1 14:46:22 2014 +0200

pvs: Wipe persistent filters when given a device argument.

---
 test/shell/lvmcache-exercise.sh |    2 --
 tools/reporter.c                |    3 +++
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 785ab17..b7c584b 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -24,8 +24,6 @@ fail pvs $(cat DEVICES)
 vgcreate $vg1 "$dev2"
 aux enable_dev "$dev1"
 
-pvscan
-# FIXME: above pvscan should not be needed
 pvs "$dev1"
 
 # reappearing device (rhbz 995440)
diff --git a/tools/reporter.c b/tools/reporter.c
index 602f173..e070bc2 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -271,6 +271,9 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			report_type == LABEL ||
 			report_type == PVSEGS) ? 1 : 0;
 
+	if (args_are_pvs && argc)
+		cmd->filter->wipe(cmd->filter);
+
 	switch (report_type) {
 	case DEVTYPES:
 		keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);


