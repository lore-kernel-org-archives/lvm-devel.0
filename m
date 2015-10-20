From: okozina <okozina@fedoraproject.org>
Date: Tue, 20 Oct 2015 13:46:11 +0000 (UTC)
Subject: master - tests: add lvmetad shutdown on idle test
Message-ID: <20151020134611.58D23602B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef4d69f456b22b4e58afb9fe5ff0b09603944f35
Commit:        ef4d69f456b22b4e58afb9fe5ff0b09603944f35
Parent:        c15649b3af94e4af573ada0f30e35f7d1fee5321
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 20 15:41:42 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 20 15:45:28 2015 +0200

tests: add lvmetad shutdown on idle test

---
 test/shell/lvmetad-autoshutdown.sh |   56 ++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-autoshutdown.sh b/test/shell/lvmetad-autoshutdown.sh
new file mode 100644
index 0000000..fdee4a6
--- /dev/null
+++ b/test/shell/lvmetad-autoshutdown.sh
@@ -0,0 +1,56 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
+kill -0 $(< LOCAL_LVMETAD) || die "lvmetad is already dead"
+
+lvmetad_timeout=3
+
+aux prepare_pvs 1
+
+vgcreate $vg1 "$dev1"
+
+kill $(< LOCAL_LVMETAD)
+aux prepare_lvmetad -t $lvmetad_timeout
+
+sleep $lvmetad_timeout
+
+# lvmetad should die after timeout, but give it some time to do so
+i=0
+while kill -0 $(< LOCAL_LVMETAD) 2>/dev/null; do
+	test $i -ge $((lvmetad_timeout*10)) && die "lvmetad didn't shutdown with optional timeout: $lvmetad_timeout seconds"
+	sleep .1
+	i=$((i+1))
+done
+
+aux prepare_lvmetad -t 0
+sleep 1
+# lvmetad must not die with -t 0 option
+kill -0 $(< LOCAL_LVMETAD) || die "lvmetad died"
+
+kill $(< LOCAL_LVMETAD)
+aux prepare_lvmetad -t $lvmetad_timeout
+
+sleep 1
+vgs
+sleep 1
+vgs
+sleep 1
+vgs
+
+# check that connection to lvmetad resets the timeout
+kill -0 $(< LOCAL_LVMETAD) || die "lvmetad died too soon"
+
+vgremove -ff $vg1


