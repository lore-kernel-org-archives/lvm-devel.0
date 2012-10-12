From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 12 Oct 2012 09:23:41 +0000 (UTC)
Subject: master - lvmetad: Fix the fix for 813766 (lvmetad connection warning).
Message-ID: <20121012092341.526D9A0D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6d207006a8f337e9d6919ffddedfa08dac128c6
Commit:        d6d207006a8f337e9d6919ffddedfa08dac128c6
Parent:        f2a5d3ae3a457059bc7de7cf3fce8eb092ac03dd
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Oct 12 11:16:38 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Fri Oct 12 11:22:47 2012 +0200

lvmetad: Fix the fix for 813766 (lvmetad connection warning).

---
 lib/cache/lvmetad.c           |    5 +++--
 test/shell/lvmetad-warning.sh |   27 +++++++++++++++++++++++++++
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index b1c799a..47a6d75 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -55,8 +55,9 @@ void lvmetad_init(struct cmd_context *cmd)
 
 void lvmetad_warning()
 {
-	log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.",
-		 strerror(_lvmetad.error));
+	if (_lvmetad_use && (_lvmetad.socket_fd < 0 || _lvmetad.error))
+		log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.",
+			 strerror(_lvmetad.error));
 }
 
 int lvmetad_active(void)
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
new file mode 100644
index 0000000..3a97a1b
--- /dev/null
+++ b/test/shell/lvmetad-warning.sh
@@ -0,0 +1,27 @@
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
+test -e LOCAL_LVMETAD || skip
+aux prepare_pvs 2
+
+vgcreate $vg1 $dev1 $dev2
+lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
+kill $(cat LOCAL_LVMETAD)
+lvchange -ay $vg1 2>&1 | grep "Failed to connect"
+lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
+aux lvmconf 'global/use_lvmetad = 0'
+lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
+lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
+aux prepare_lvmetad
+lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
+lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"


