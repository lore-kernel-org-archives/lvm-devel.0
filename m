From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 12 Oct 2015 10:55:52 +0000 (UTC)
Subject: master - tests: test vgimportclone and -n option
Message-ID: <20151012105552.3EBDC60F68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bd63df237bc3426d1ebd41b103430063846b3ab
Commit:        5bd63df237bc3426d1ebd41b103430063846b3ab
Parent:        75420282e17e44d5c7b56126a5c7fd170f0ef417
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 12 12:54:35 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 12 12:55:39 2015 +0200

tests: test vgimportclone and -n option

---
 test/shell/vgimportclone.sh |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 0b1af38..53c8b00 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -71,3 +71,28 @@ lvchange -ay $vg1/$lv1 $vg2/$lv1
 vgchange -an $vg1 $vg2
 
 vgremove -ff $vg1 $vg2
+
+# Verify that if we provide the -n|--basevgname,
+# the number suffix is not added unnecessarily.
+vgcreate --metadatasize 128k A${vg1}B "$dev1"
+
+# vg1B is not the same as Avg1B - we don't need number suffix
+dd if="$dev1" of="$dev2" bs=256K count=1
+aux notify_lvmetad "$dev2"
+vgimportclone -n ${vg1}B "$dev2"
+check pv_field "$dev2" vg_name ${vg1}B
+
+# Avg1 is not the same as Avg1B - we don't need number suffix
+dd if="$dev1" of="$dev2" bs=256K count=1
+aux notify_lvmetad "$dev2"
+vgimportclone -n A${vg1} "$dev2"
+check pv_field "$dev2" vg_name A${vg1}
+
+# Avg1B is the same as Avg1B - we need to add the number suffix
+dd if="$dev1" of="$dev2" bs=256K count=1
+aux notify_lvmetad "$dev2"
+vgimportclone -n A${vg1}B "$dev2"
+aux vgs
+check pv_field "$dev2" vg_name A${vg1}B1
+
+vgremove -ff A${vg1}B A${vg1}B1


