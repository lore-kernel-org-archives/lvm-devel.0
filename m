From: David Teigland <teigland@sourceware.org>
Date: Thu, 6 Jun 2019 16:33:27 -0400
Subject: master - tests: pvscan-autoactivate check for machine-id
Message-ID: <201906062033.x56KXRCp032121@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c315112a3b7d01e56cbd2ecb3d05f55d44a50e12
Commit:        c315112a3b7d01e56cbd2ecb3d05f55d44a50e12
Parent:        2b241eb1f666e93f47917f2495e900bf80c9d5ff
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 6 15:32:42 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 6 15:32:42 2019 -0500

tests: pvscan-autoactivate check for machine-id

---
 test/shell/pvscan-autoactivate.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 362a4ff..d674dc5 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -134,6 +134,8 @@ not ls "$RUNDIR/lvm/pvs_online/$PVID3"
 
 # pvscan cache ignores pv in a foreign vg
 
+if [ -e "/etc/machine-id" ]; then
+
 aux lvmconf "global/system_id_source = machineid"
 
 _clear_online_files
@@ -168,6 +170,8 @@ cat tmp
 grep $lv2 tmp
 check lv_field $vg2/$lv2 lv_active "" --foreign
 
+fi
+
 
 # Test the case where pvscan --cache -aay (with no devs)
 # gets the final PV to complete the VG, where that final PV


