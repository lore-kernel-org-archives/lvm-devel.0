From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 May 2014 13:41:44 +0000 (UTC)
Subject: master - tests: rename test
Message-ID: <20140528134144.D804A611BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8212dac849e5a820c579c06a1b2805e7934a8d8b
Commit:        8212dac849e5a820c579c06a1b2805e7934a8d8b
Parent:        2adaef82722ec71620a6d02c6c973d3472d705ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 28 15:41:06 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 28 15:41:06 2014 +0200

tests: rename test

---
 test/shell/lvmetad-same-uuid.sh |   27 ---------------------------
 test/shell/pv-duplicate-uuid.sh |   28 ++++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/test/shell/lvmetad-same-uuid.sh b/test/shell/lvmetad-same-uuid.sh
deleted file mode 100644
index 34cc8eb..0000000
--- a/test/shell/lvmetad-same-uuid.sh
+++ /dev/null
@@ -1,27 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-
-. lib/test
-
-aux prepare_devs 3
-
-pvcreate "$dev1"
-UUID1=$(get pv_field "$dev1" uuid)
-pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev2"
-pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev3"
-
-pvs -o+uuid |& tee out
-COUNT=$(should grep --count "Found duplicate" out)
-
-# FIXME  lvmetad is not able to serve properly this case
-should [ "$COUNT" -eq 2 ]
-
-pvs -o+uuid --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}"
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
new file mode 100644
index 0000000..cc5f56b
--- /dev/null
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -0,0 +1,28 @@
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
+# Test 'Found duplicate' is shown
+. lib/test
+
+aux prepare_devs 3
+
+pvcreate "$dev1"
+UUID1=$(get pv_field "$dev1" uuid)
+pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev2"
+pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev3"
+
+pvs -o+uuid |& tee out
+COUNT=$(should grep --count "Found duplicate" out)
+
+# FIXME  lvmetad is not able to serve properly this case
+should [ "$COUNT" -eq 2 ]
+
+pvs -o+uuid --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}"


