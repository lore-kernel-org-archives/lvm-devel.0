From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Jul 2016 13:49:32 +0000 (UTC)
Subject: master - tests: check fail path on cache creation
Message-ID: <20160715134932.D5E0660D2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2bb19e883f46a95e9780cea046e6e0a5db006b9
Commit:        d2bb19e883f46a95e9780cea046e6e0a5db006b9
Parent:        a57bf37cdb89aced30bf27d61e87388704a7d9c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 15 15:47:33 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 15 15:49:01 2016 +0200

tests: check fail path on cache creation

---
 test/shell/lvcreate-cache-fail.sh |   41 +++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-cache-fail.sh b/test/shell/lvcreate-cache-fail.sh
new file mode 100644
index 0000000..2ff4865
--- /dev/null
+++ b/test/shell/lvcreate-cache-fail.sh
@@ -0,0 +1,41 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise creation of cache and cache pool volumes and failure path
+# https://bugzilla.redhat.com/1355923
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+#aux prepare_pvs 1 4707950
+#vgcreate $vg "$dev1"
+#lvcreate -L4T -n $lv1 $vg
+#lvcreate -H -L500G -n cache $vg/$lv1
+#fail lvcreate -H -l 127999 -n cache $vg/$lv1
+
+aux prepare_vg 1 20
+lvcreate -L10 -n $lv1 $vg
+fail lvcreate -H -L2 -n cache $vg/$lv1
+
+lvs -a $vg
+vgs $vg
+lvdisplay $vg
+
+#dmsetup table
+#dmsetup status
+#time dmsetup suspend ${vg}-${lv1}
+#time dmsetup resume ${vg}-${lv1}
+
+vgremove -ff $vg


