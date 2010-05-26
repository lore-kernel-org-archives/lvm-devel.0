From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 26 May 2010 10:02:20 -0400
Subject: [PATCH 18/18] Add tests for metadata balance - set/clear/display per-PV ignore bit.
In-Reply-To: <1274882540-6181-18-git-send-email-dwysocha@redhat.com>
References: <1274882540-6181-1-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-2-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-3-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-4-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-5-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-6-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-7-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-8-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-9-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-10-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-11-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-12-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-13-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-14-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-15-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-16-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-17-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-18-git-send-email-dwysocha@redhat.com>
Message-ID: <1274882540-6181-19-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-metadata-balance.sh |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)
 create mode 100755 test/t-metadata-balance.sh

diff --git a/test/t-metadata-balance.sh b/test/t-metadata-balance.sh
new file mode 100755
index 0000000..2321771
--- /dev/null
+++ b/test/t-metadata-balance.sh
@@ -0,0 +1,41 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+aux prepare_devs 5
+
+#  Make sure we can ignore / un-ignore mdas on a per-PV basis
+for pv_in_vg in 1 0; do
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2
+        pvcreate --metadatacopies 0 $dev3
+	if [ $pv_in_vg = 1 ]; then
+		vgcreate -c n "$vg" $dev1 $dev2 $dev3
+	fi
+	pvchange --metadataignore y $dev1
+	check_pv_field_ $dev1 pv_mda_count $mdacp
+	check_pv_field_ $dev1 pv_mda_count_ignored $mdacp
+	check_pv_field_ $dev2 pv_mda_count $mdacp
+	check_pv_field_ $dev2 pv_mda_count_ignored 0
+	if [ $pv_in_vg = 1 ]; then
+		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
+		check_vg_field_ $vg vg_mda_count_ignored $mdacp
+	fi
+	pvchange --metadataignore n $dev1
+	check_pv_field_ $dev1 pv_mda_count $mdacp
+	check_pv_field_ $dev1 pv_mda_count_ignored 0
+	if [ $pv_in_vg = 1 ]; then
+		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
+		check_vg_field_ $vg vg_mda_count_ignored 0
+		vgremove -f $vg
+	fi
+done
+done
-- 
1.6.0.6


