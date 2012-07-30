From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 30 Jul 2012 09:25:05 +0000 (UTC)
Subject: master - TEST: Add lvmetad-test; checks --test with lvmetad.
Message-ID: <20120730092505.7B7BE340A@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20ca6d6545e6a0a8e84c117fd4530de0421bc78d
Commit:        20ca6d6545e6a0a8e84c117fd4530de0421bc78d
Parent:        6997943f2221729449469d1a7963055991c2361d
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Mon Jul 30 11:21:55 2012 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Mon Jul 30 11:21:55 2012 +0200

TEST: Add lvmetad-test; checks --test with lvmetad.

---
 test/shell/lvmetad-test.sh |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-test.sh b/test/shell/lvmetad-test.sh
new file mode 100644
index 0000000..7e801f1
--- /dev/null
+++ b/test/shell/lvmetad-test.sh
@@ -0,0 +1,34 @@
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
+aux prepare_pvs 2
+
+vgcreate $vg1 $dev1 $dev2 --test
+vgs | not grep $vg1
+vgcreate $vg1 $dev1 $dev2
+vgs | grep $vg1
+
+lvcreate -n bar -l 1 $vg1 --test
+lvs | not grep bar
+lvcreate -n bar -l 1 $vg1
+lvs | grep bar
+
+lvremove $vg1/bar -f --test
+lvs | grep bar
+lvremove $vg1/bar -f
+lvs | not grep bar
+
+vgremove $vg1 --test
+vgs | grep $vg1
+vgremove $vg1
+vgs | not grep $vg1


