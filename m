From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 25 Oct 2012 12:31:44 +0000 (UTC)
Subject: master - lvmetad: Disable and warn when locking_type is 3.
Message-ID: <20121025123144.7B7D4A0C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fdd0840d5adb1ff492cd09da79f7a2c5290fd2a
Commit:        2fdd0840d5adb1ff492cd09da79f7a2c5290fd2a
Parent:        b248ba0a396d7fc9a459eea02cfdc70b33ce3441
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 25 14:30:03 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 25 14:31:08 2012 +0200

lvmetad: Disable and warn when locking_type is 3.

---
 lib/commands/toolcontext.c       |    7 ++++++-
 test/shell/lvmetad-no-cluster.sh |   19 +++++++++++++++++++
 2 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d72b0c0..1dd23bf 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -413,7 +413,12 @@ static int _process_config(struct cmd_context *cmd)
 	lvmetad_set_socket(lvmetad_socket);
 	cn = find_config_tree_node(cmd, "devices/global_filter");
 	lvmetad_set_token(cn ? cn->v : NULL);
-	lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
+	if (find_config_tree_int(cmd, "global/locking_type", 1) != 3)
+		lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
+	else {
+		log_warn("WARNING: use_lvmetad overriden to 0 due to locking_type 3");
+		lvmetad_set_active(0);
+	}
 	lvmetad_init(cmd);
 
 	return 1;
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
new file mode 100644
index 0000000..db68e77
--- /dev/null
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -0,0 +1,19 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+test -e LOCAL_CLVMD || skip
+aux prepare_vg 2
+aux prepare_lvmetad
+vgs -vv 2> errs
+cat errs
+grep 'use_lvmetad' errs


