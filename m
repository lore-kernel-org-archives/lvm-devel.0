From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 19 Mar 2014 15:26:31 +0000 (UTC)
Subject: master - polldaemon: Re-initialise lvmcache properly on fork (fixes RHBZ 1073670).
Message-ID: <20140319152631.DD67A60E2A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f12ee43f2eaba5d38b1925a5a34b1746c1d66985
Commit:        f12ee43f2eaba5d38b1925a5a34b1746c1d66985
Parent:        2f279797f526494887a6163ead9e83e4823c8c94
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Mar 19 16:23:43 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Mar 19 16:25:12 2014 +0100

polldaemon: Re-initialise lvmcache properly on fork (fixes RHBZ 1073670).

---
 test/shell/pvmove-background.sh |   24 ++++++++++++++++++++++++
 tools/toollib.c                 |    1 +
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
new file mode 100644
index 0000000..0f657be
--- /dev/null
+++ b/test/shell/pvmove-background.sh
@@ -0,0 +1,24 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Check pvmove behavior when it's progress and machine is rebooted
+
+. lib/test
+
+aux prepare_vg 3
+
+lvcreate -l1 -n $lv1 $vg "$dev1"
+
+lvs -o +devices | grep $dev1
+pvmove -i 1 -b "$dev1" "$dev2"
+sleep 5 # arbitrary...
+lvs -o +devices | not grep "pvmove"
+lvs -o +devices | grep "$dev2"
diff --git a/tools/toollib.c b/tools/toollib.c
index 91b0559..2bc0be3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -91,6 +91,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
 
 	if (!skip_lvm) {
+		lvmcache_destroy(cmd, 1);
 		reset_locking();
 		if (!lvmcache_init())
 			/* FIXME Clean up properly here */


