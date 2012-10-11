From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 11 Oct 2012 20:03:58 +0000 (UTC)
Subject: master - test: Add lvmetad-dump.sh.
Message-ID: <20121011200358.5781222BD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=413d91dc29a41b44c80df5ff5d054b36895718eb
Commit:        413d91dc29a41b44c80df5ff5d054b36895718eb
Parent:        a63b46bf36b22b83ff05f2d3529bc22a38ff56d3
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 11 20:32:25 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 11 20:32:25 2012 +0200

test: Add lvmetad-dump.sh.

---
 test/shell/lvmetad-dump.sh |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
new file mode 100644
index 0000000..e49eb68
--- /dev/null
+++ b/test/shell/lvmetad-dump.sh
@@ -0,0 +1,38 @@
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
+test -e LOCAL_LVMETAD || skip
+
+aux prepare_pvs 2
+vgcreate $vg1 $dev1 $dev2
+lvcreate -n bar -l 1 $vg1
+
+lvmetad_talk() {
+    if type -p socat >& /dev/null; then
+	socat "unix-connect:$1" -
+    elif echo | nc -U "$1"; then
+	nc -U "$1"
+    else
+	echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
+	echo "# DUMP FAILED"
+	return 1
+    fi
+}
+
+lvmetad_dump() {
+    (echo 'request="dump"'; echo '##') | lvmetad_talk "$@"
+}
+
+(echo | lvmetad_talk ./lvmetad.socket) || skip
+lvmetad_dump ./lvmetad.socket | tee lvmetad.txt
+
+grep $vg1 lvmetad.txt


