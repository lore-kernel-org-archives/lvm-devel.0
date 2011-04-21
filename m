From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 21 Apr 2011 12:00:20 -0400
Subject: [PATCH] Add nightly test for vgimportclone and querying of vgnames with duplicate pvs.
Message-ID: <1303401620-8683-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Related to rhbz 697959.

This test fails prior to these two commits:
commit af112eb2c9a62c5d794df920218bd3ee291d5b25
Author: Zdenek Kabelac <zkabelac@redhat.com>
Date:   Thu Apr 21 13:15:26 2011 +0000

    Skip check for NULL before dm_free

    dm_free makes this test itself.

commit 91419c3e86bf9666aab2aa631faae1ba73e8d745
Author: Zdenek Kabelac <zkabelac@redhat.com>
Date:   Thu Apr 21 13:13:40 2011 +0000

    Fix use of released vgname and vgid

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-vgimportclone.sh |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)
 create mode 100644 test/t-vgimportclone.sh

diff --git a/test/t-vgimportclone.sh b/test/t-vgimportclone.sh
new file mode 100644
index 0000000..3c50170
--- /dev/null
+++ b/test/t-vgimportclone.sh
@@ -0,0 +1,35 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+
+pvcreate $dev1 $dev2
+vgcreate $vg1 $dev1
+lvcreate -l100%FREE -n $lv1 $vg1
+
+# Clone the LUN
+dd if=$dev1 of=$dev2
+
+# Verify pvs works on each device to give us vgname
+pvs --noheadings -o vg_name $dev1 1>err
+grep $vg1 err
+pvs --noheadings -o vg_name $dev2 1>err
+grep $vg1 err
+
+# Import the cloned PV to a new VG
+vgimportclone --basevgname $vg2 $dev2
+
+# Verify we can activate / deactivate the LV from both VGs
+lvchange -ay $vg1/$lv1
+lvchange -ay $vg2/$lv1
+vgchange -an $vg1
+vgchange -an $vg2
-- 
1.7.2.3


