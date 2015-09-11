From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:54:39 +0000 (UTC)
Subject: master - tests: new thin tests
Message-ID: <20150911195439.9DD88609C4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd2e4310b320782ec58b712d3c2f24a56c7d10c5
Commit:        cd2e4310b320782ec58b712d3c2f24a56c7d10c5
Parent:        fd3d795b9301dd1defd33e4340fd453e5aee4e8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 21:00:10 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:52:27 2015 +0200

tests: new thin tests

---
 test/shell/lvconvert-repair-thin-raid.sh |   58 ++++++++++++++++++++++++++++++
 test/shell/lvextend-thin.sh              |    2 +
 2 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-thin-raid.sh b/test/shell/lvconvert-repair-thin-raid.sh
new file mode 100644
index 0000000..04bc5c7
--- /dev/null
+++ b/test/shell/lvconvert-repair-thin-raid.sh
@@ -0,0 +1,58 @@
+#!/bin/sh
+
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
+# Test repairing of broken thin pool on raid
+
+. lib/inittest
+
+test -e LOCAL_LVMPOLLD && skip
+aux have_thin 1 0 0 || skip
+aux have_raid 1 4 0 || skip
+
+#
+# Main
+#
+
+aux prepare_vg 4
+
+lvcreate --type raid1 -L1 -n pool $vg
+lvcreate --type raid1 -L2 -n meta $vg
+# raid _tdata & _tmeta
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/meta
+
+lvcreate -V1G $vg/pool
+
+# Pool has to be inactive (ATM) for repair
+fail lvconvert -y --repair $vg/pool "$dev3"
+
+lvchange -an $vg
+
+check lv_field $vg/pool_tmeta lv_role "private,thin,pool,metadata"
+
+lvconvert -y --repair $vg/pool "$dev3"
+
+lvs -a -o+devices,seg_pe_ranges,role,layout $vg
+check lv_field $vg/pool_meta0 lv_role "public"
+check lv_field $vg/pool_meta0 lv_layout "raid,raid1"
+check lv_field $vg/pool_tmeta lv_layout "linear"
+check lv_on $vg pool_tmeta "$dev1"
+
+# Hmm name is generated in order
+SPARE=$(lvs --noheadings -a --select "name=~_pmspare" -o name $vg)
+SPARE=${SPARE##*[}
+SPARE=${SPARE%%]*}
+
+check lv_on $vg $SPARE "$dev3"
+
+lvchange -ay $vg
+
+vgremove -ff $vg
diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index 1e64e42..a97e93b 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -21,3 +21,5 @@ aux prepare_vg 3
 lvcreate -i2 -l2 -T $vg/pool2
 lvextend -l+2 $vg/pool2 "$dev2" "$dev3"
 should lvextend -l+100%FREE $vg/pool2
+
+vgremove -ff $vg


