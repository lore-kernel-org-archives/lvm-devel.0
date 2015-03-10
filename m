From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 10 Mar 2015 14:59:12 +0000 (UTC)
Subject: master - tests: update to not run vgconvert -M with lvmetad
Message-ID: <20150310145912.C2C80611BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7290759b059c65e2dbd56e498186b4b8acc8315
Commit:        c7290759b059c65e2dbd56e498186b4b8acc8315
Parent:        f5cc96a54e9563b8aa5445a049facbe30a59fb39
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 10 09:59:52 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 10 09:59:52 2015 -0500

tests: update to not run vgconvert -M with lvmetad

---
 test/shell/metadata.sh       |    3 +++
 test/shell/pvcreate-usage.sh |   12 ++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 3adb684..251942f 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -57,6 +57,9 @@ check pv_field "$dev3" pe_start $pv_align
 
 pvs --units k -o name,pe_start,vg_mda_size,vg_name $(cat DEVICES)
 
+# vgconvert -M does not work with lvmetad
+test -e LOCAL_LVMETAD && exit 0
+
 # upgrade from v1 to v2 metadata
 vgconvert -M2 $vg
 
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 48d2ceb..5e916c3 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -131,18 +131,30 @@ check pv_field "$dev1" pv_mda_count 2
 
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
+if test ! -e LOCAL_LVMETAD; then
 pvcreate --dataalignment 256k "$dev1"
 vgcreate -s 1m $vg "$dev1"
 vgconvert -M1 $vg
 vgconvert -M2 $vg
 check pv_field "$dev1" pe_start 256.00k
 vgremove $vg
+fi
 
 #COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
+if test ! -e LOCAL_LVMETAD; then
 pvcreate --dataalignment 10k "$dev1"
 vgcreate -s 1m $vg "$dev1"
 not vgconvert -M1 $vg
 vgremove $vg
+fi
+
+#COMM 'vgconvert -M is disallowed with lvmetad'
+if test -e LOCAL_LVMETAD; then
+pvcreate "$dev1"
+vgcreate $vg "$dev1"
+not vgconvert -M1 $vg
+vgremove $vg
+fi
 
 #COMM 'vgcfgrestore allows pe_start=0'
 #basically it produces nonsense, but it tests vgcfgrestore,


