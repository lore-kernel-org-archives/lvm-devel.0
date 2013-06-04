From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:20 +0000 (UTC)
Subject: dev-mornfall-activate - test: new test new fail
Message-ID: <20130604192520.48BB161021@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7c5a840c1aca9712134b8afee8abcba5cb8116f
Commit:        c7c5a840c1aca9712134b8afee8abcba5cb8116f
Parent:        68ef288901820b522e3765e5fbec972ea348e3b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 14:15:04 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 14:15:04 2013 +0200

test: new test new fail

Do not hide new features into old test files.
---
 test/shell/lvchange-partial-raid10.sh |   29 +++++++++++++++++++++++++++++
 test/shell/lvchange-partial.sh        |   12 ------------
 2 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
new file mode 100644
index 0000000..64a2389
--- /dev/null
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -0,0 +1,29 @@
+#!/bin/bash
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+aux target_at_least dm-raid 1 3 2 || skip
+
+aux prepare_vg 4
+
+# rhbz 889358
+# Should be able to activate when RAID10
+# has failed devs in different mirror sets.
+lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+lvchange -an $vg/$lv1
+aux disable_dev "$dev1" "$dev3"
+lvchange -ay $vg/$lv1 --partial
+lvchange -an $vg/$lv1
+
+aux enable_dev "$dev1"
+lvremove -ff $vg
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index bc9a514..891dd0a 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -66,15 +66,3 @@ not lvchange --resync --addtag foo $vg/$lv1
 
 aux enable_dev "$dev1"
 lvremove -ff $vg
-
-# rhbz 889358
-# Should be able to activate when RAID10
-# has failed devs in different mirror sets.
-if aux target_at_least dm-raid 1 3 2; then
-	lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
-	aux wait_for_sync $vg $lv1
-	lvchange -an $vg/$lv1
-	aux disable_dev "$dev1" "$dev3"
-	lvchange -ay $vg/$lv1 --partial
-	lvchange -an $vg/$lv1
-fi


