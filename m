From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  8 Jan 2014 14:25:21 +0000 (UTC)
Subject: master - test: Add a regression test for pvcreate -ff.
Message-ID: <20140108142521.0E4BC610B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1937715d2ccdd46122da862c6d7c1ef0ed7d1230
Commit:        1937715d2ccdd46122da862c6d7c1ef0ed7d1230
Parent:        8a8e59fb5afd1f85be5cb96744b3eb34ad9a5e71
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 8 15:23:30 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 8 15:24:43 2014 +0100

test: Add a regression test for pvcreate -ff.

---
 test/shell/pvcreate-ff.sh |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvcreate-ff.sh b/test/shell/pvcreate-ff.sh
new file mode 100644
index 0000000..38284af
--- /dev/null
+++ b/test/shell/pvcreate-ff.sh
@@ -0,0 +1,19 @@
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
+. lib/test
+
+aux prepare_devs 2
+pvcreate $dev1
+vgcreate foo $dev1
+pvcreate -ff -y $dev1
+vgs
+vgcreate foo $dev1


