From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:24 -0500
Subject: [PATCH 21/21] Update metadatabalance tests to include sanity checks for vgchange.
In-Reply-To: <1265754744-17319-21-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-3-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-4-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-5-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-6-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-7-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-8-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-9-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-10-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-11-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-12-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-13-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-14-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-15-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-16-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-17-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-18-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-19-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-20-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-21-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-22-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-metadata-balance.sh |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/test/t-metadata-balance.sh b/test/t-metadata-balance.sh
index c0dd679..64e165b 100755
--- a/test/t-metadata-balance.sh
+++ b/test/t-metadata-balance.sh
@@ -28,6 +28,8 @@ for mdacp in 1 2; do
 	if [ $pv_in_vg = 1 ]; then
 		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
 		check_vg_field_ $vg vg_mda_count_disabled $mdacp
+		check_vg_field_ $vg vg_mda_balance_min 1
+		check_vg_field_ $vg vg_mda_balance_max 3
 	fi
 	pvchange --metadatadisable n $dev1
 	check_pv_field_ $dev1 pv_mda_count $mdacp
@@ -35,7 +37,30 @@ for mdacp in 1 2; do
 	if [ $pv_in_vg = 1 ]; then
 		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
 		check_vg_field_ $vg vg_mda_count_disabled 0
+		check_vg_field_ $vg vg_mda_balance_min 1
+		check_vg_field_ $vg vg_mda_balance_max 3
+		# Sanity test of metadata balance params
+		# 'min' threshold (1 < min <= max)
+		# 'max' threshold (min <= max <= #pvs)
+		not vgchange --metadatabalancemin 0 $vg
+		not vgchange --metadatabalancemin 4 $vg
+		vgchange --metadatabalancemin 2 $vg
+		check_vg_field_ $vg vg_mda_balance_min 2
+		not vgchange --metadatabalancemax 4 $vg
+		vgchange --metadatabalancemax 2 $vg
+		check_vg_field_ $vg vg_mda_balance_max 2
+		vgchange --metadatabalancemax 3 $vg
+		check_vg_field_ $vg vg_mda_balance_max 3
+		vgchange --metadatabalancemin 3 $vg
+		check_vg_field_ $vg vg_mda_balance_min 3
 		vgremove -f $vg
 	fi
 done
 done
+
+# Test behavior of metadata balance min / max
+# ensure setting min/max affects underlying pv enable/disable
+
+# Setting a larger min value should trigger enabling mdas
+# Setting a smaller max value should trigger disabling mdas
+# vg_mda_count_disabled should always be consistent with min/max
\ No newline@end of file
-- 
1.6.0.6


