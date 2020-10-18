From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:32 +0000 (GMT)
Subject: stable-2.02 - tests: failure of zeroing fails command
Message-ID: <20201018210232.B051A385041B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a46fdf5426596db41b08530ea2a0d4c8d8895ad8
Commit:        a46fdf5426596db41b08530ea2a0d4c8d8895ad8
Parent:        e5010662a19502183fcbcc2a5e755c223ede2744
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 14:10:18 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

tests: failure of zeroing fails command

---
 test/shell/lvcreate-signature-wiping.sh | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index 73fea54fd..18d7a2f7e 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -42,6 +42,13 @@ init_lv_
 test_blkid_ || skip
 lvremove -f $vg/$lv1
 
+# Zeroing stops the command when there is a failure (write error in this case)
+aux error_dev "$dev1" "$(get first_extent_sector "$dev1"):2"
+not lvcreate -l1 -n $lv1 $vg 2>&1 | tee out
+grep "Failed to initialize" out
+aux enable_dev "$dev1"
+
+
 aux lvmconf "allocation/wipe_signatures_when_zeroing_new_lvs = 0"
 
 lvcreate -y -Zn -l1 -n $lv1 $vg 2>&1 | tee out


