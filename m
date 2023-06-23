From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:44 +0000 (GMT)
Subject: main - tests: improve test for machine_id
Message-ID: <20230623160944.C99743858434@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aed91e49aec64f8375583c7e0febd7b689e69e29
Commit:        aed91e49aec64f8375583c7e0febd7b689e69e29
Parent:        39d6a9601fd3d85ac4237a4731297cddfd5ecb1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 14:43:07 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:06:22 2023 +0200

tests: improve test for machine_id

---
 test/shell/system_id.sh | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 14d2c6fd4..486fba1c3 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -24,10 +24,13 @@ print_lvmlocal() {
 
 aux prepare_devs 5
 
-SIDFILE="etc/lvm_test.conf"
-LVMLOCAL="etc/lvmlocal.conf"
+# get lvm.conf location in a form of: etc=path
+eval "$(lvmconfig global/etc)"
 
-DFDIR="$LVM_SYSTEM_DIR/devices"
+SIDFILE="$etc/lvm_test.conf"
+LVMLOCAL="$etc/lvmlocal.conf"
+
+DFDIR="$etc/devices"
 DF="$DFDIR/system.devices"
 
 # Avoid system id validation in the devices file
@@ -50,10 +53,6 @@ vgcreate $vg1 "$dev1"
 check vg_field $vg1 systemid "$SID"
 vgremove $vg1
 
-# FIXME - print 'life' config data
-#eval "$(lvmconfig global/etc 2>/dev/null || lvmconfig --type default global/etc)"
-etc="/etc"
-
 ## machineid
 if [ -e "$etc/machine-id" ]; then
 SID=$(cat "$etc/machine-id")
@@ -708,4 +707,3 @@ vgs -o+systemid $vg1
 check vg_field $vg1 systemid "$SID"
 grep "No system ID found from system_id_source" err
 vgremove $vg1
-

