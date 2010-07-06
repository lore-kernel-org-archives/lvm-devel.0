From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  6 Jul 2010 18:12:02 -0400
Subject: [PATCH] Test failed commit of mda on new pv - failed vgextend.
Message-ID: <1278454322-3016-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Test the auto-repair capability when we fail committing to an mda
on a new pv adding to a vg.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-inconsistent-metadata.sh |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/test/t-inconsistent-metadata.sh b/test/t-inconsistent-metadata.sh
index fbbea15..f33f37e 100644
--- a/test/t-inconsistent-metadata.sh
+++ b/test/t-inconsistent-metadata.sh
@@ -63,3 +63,13 @@ grep "Inconsistent metadata found for VG $vg" cmd.out
 vgs 2>&1 | tee cmd.out
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
+
+echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
+vgremove -f $vg
+pvremove -ff $devs
+pvcreate $devs
+backup_dev $dev2
+vgcreate $vg $dev1
+vgextend $vg $dev2
+restore_dev $dev2
+compare_two_fields_ vgs $vg vg_mda_count pvs $dev2 vg_mda_count
-- 
1.6.0.6


