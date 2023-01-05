From: David Teigland <teigland@sourceware.org>
Date: Thu,  5 Jan 2023 20:49:00 +0000 (GMT)
Subject: main - tests: vgimportclone with incomplete pv list and nomda pv
Message-ID: <20230105204900.5BA5F3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=789904bd57442f783d50f7076c7f9ee188dbd33b
Commit:        789904bd57442f783d50f7076c7f9ee188dbd33b
Parent:        c4b898a53eec39bc28b5451e7fde87945303a644
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 5 14:47:49 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 5 14:47:49 2023 -0600

tests: vgimportclone with incomplete pv list and nomda pv

---
 test/shell/vgimportclone.sh | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 97d146b9e..e1b9d3832 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -14,7 +14,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_devs 2
+aux prepare_devs 3
 
 vgcreate $SHARED --metadatasize 128k $vg1 "$dev1"
 lvcreate -l100%FREE -n $lv1 $vg1
@@ -85,6 +85,25 @@ vgchange -an $vg1 $vg2
 
 vgremove -ff $vg1 $vg2
 
+pvremove "$dev1"
+pvremove "$dev2"
+
+# Test vgimportclone with incomplete list of devs, and with nomda PV.
+vgcreate $SHARED --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -l1 -an $vg1
+not vgimportclone -n newvgname "$dev1"
+not vgimportclone -n newvgname "$dev2"
+not vgimportclone -n newvgname "$dev3"
+not vgimportclone -n newvgname "$dev1" "$dev2"
+not vgimportclone -n newvgname "$dev1" "$dev3"
+not vgimportclone -n newvgname "$dev2" "$dev3"
+vgimportclone -n ${vg1}new "$dev1" "$dev2" "$dev3"
+lvs ${vg1}new
+vgremove -y ${vg1}new
+pvremove "$dev1"
+pvremove "$dev2"
+pvremove "$dev3"
+
 # Verify that if we provide the -n|--basevgname,
 # the number suffix is not added unnecessarily.
 vgcreate $SHARED --metadatasize 128k A${vg1}B "$dev1"

