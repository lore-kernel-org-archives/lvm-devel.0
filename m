From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:45 +0000 (UTC)
Subject: master - tests: thin and volume_list testing
Message-ID: <20140826121745.6E5AE60E57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70e998754e852fd3052daa5d79213af2f632ac44
Commit:        70e998754e852fd3052daa5d79213af2f632ac44
Parent:        c37ca279e33b532f00da4b2f50e8e1ad547e8a77
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 26 12:26:17 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:13:07 2014 +0200

tests: thin and volume_list testing

---
 test/shell/thin-volume-list.sh |   51 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
new file mode 100644
index 0000000..b53e772
--- /dev/null
+++ b/test/shell/thin-volume-list.sh
@@ -0,0 +1,51 @@
+#!/bin/bash
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
+# test pool behaviour when volume_list masks activation
+
+. lib/inittest
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 2
+
+lvcreate -T -L8M $vg/pool -V10M -n $lv1
+
+aux lvmconf "activation/volume_list = [ \"$vg1\" ]"
+
+# We still could pass - since pool is still active
+lvcreate -V10 -n $lv2 -T $vg/pool
+
+# but $lv2 is not active
+check inactive $vg $lv2
+
+vgchange -an $vg
+
+# skip $vg from activation
+aux lvmconf "activation/volume_list = [ \"$vg1\" ]"
+
+# Pool is not active - so it cannot create thin volume
+not lvcreate -V10 -T $vg/pool
+
+aux lvmconf "activation/volume_list = [ \"$vg\" ]"
+
+lvcreate -V10 -T $vg/pool
+
+lvs -o +transaction_id,thin_id $vg
+
+lvremove -ff $vg
+
+check vg_field $vg lv_count "0"
+
+vgremove -ff $vg


