From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:54 +0000 (UTC)
Subject: master - test: thin snapshot merge
Message-ID: <20131204133154.46FD260FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1592bb216e47269b1a2839031b8e92d8c359461c
Commit:        1592bb216e47269b1a2839031b8e92d8c359461c
Parent:        91496e0eda9969f1efcf290803c13d79456067d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 4 14:17:54 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:26 2013 +0100

test: thin snapshot merge

Testing thin snapshot merge cases.
TODO: Probably still misses some cases.
---
 test/shell/thin-merge.sh |  107 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 107 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
new file mode 100644
index 0000000..10a81f0
--- /dev/null
+++ b/test/shell/thin-merge.sh
@@ -0,0 +1,107 @@
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
+# test merge of thin snapshot
+
+. lib/test
+
+which mkfs.ext2 || skip
+which fsck || skip
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 2
+
+lvcreate -T -L8M $vg/pool -V10M -n $lv1
+lvchange --addtag tagL $vg/$lv1
+
+mkdir mnt
+mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
+mount $DM_DEV_DIR/$vg/$lv1 mnt
+touch mnt/test
+
+lvcreate -K -s -n snap --addtag tagS $vg/$lv1
+mkdir mntsnap
+mkfs.ext2 $DM_DEV_DIR/$vg/snap
+mount $DM_DEV_DIR/$vg/snap mntsnap
+touch mntsnap/test_snap
+
+lvs -o+tags,thin_id $vg
+
+lvconvert --merge $vg/snap
+
+umount mnt
+
+# Merge cannot happen
+lvchange --refresh $vg/$lv1
+check lv_field  $vg/$lv1 thin_id "1"
+
+# Fails since it cannot deactivate both
+not lvchange -an $vg/$lv1
+
+# But test $lv1 is not active
+check inactive $vg $lv1
+
+# Also still cannot reactivate $lv1
+not lvchange -ay $vg/$lv1
+
+umount mntsnap
+
+lvdisplay -a $vg | tee out
+grep "merged with" out
+grep "merging to" out
+
+# Check there is no support for manipulation with hidden 'snap'
+not lvchange --refresh $vg/snap
+not lvchange -an $vg/snap
+not lvremove $vg/snap
+
+
+# Finally deactivate 'snap' again via $lv1
+lvchange -an $vg/$lv1
+
+# Still must not be activable
+not lvchange -K -ay $vg/snap
+
+lvs -a -o +tags,thin_id $vg
+dmsetup table
+
+# Test if merge happens
+lvchange -ay $vg/$lv1
+check lv_exists $vg $lv1
+check lv_field  $vg/$lv1 thin_id "2"
+check lv_field $vg/$lv1 tags "tagL"
+not check lv_exists $vg snap
+
+fsck -n $DM_DEV_DIR/$vg/$lv1
+mount $DM_DEV_DIR/$vg/$lv1 mnt
+test -e mnt/test_snap
+umount mnt
+
+
+# test if thin snapshot has also 'old-snapshot'
+
+lvcreate -s -n snap $vg/$lv1
+
+# Also add old snapshot to thin origin
+lvcreate -s -L10 -n oldsnapof_${lv1} $vg/$lv1
+not lvconvert --merge $vg/snap
+lvremove -f $vg/oldsnapof_${lv1}
+
+# Add old snapshot to thin snapshot
+lvcreate -s -L10 -n oldsnapof_snap $vg/snap
+lvconvert --merge $vg/snap
+lvremove -f $vg/oldsnapof_snap
+
+vgremove -ff $vg


