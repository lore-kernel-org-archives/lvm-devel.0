From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:49 +0000 (GMT)
Subject: master - tests: failure of zeroing fails command
Message-ID: <20200624130249.7CDCA393C8B3@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=094d6f80ddb6d8a1c64977dfaae4073827063fe3
Commit:        094d6f80ddb6d8a1c64977dfaae4073827063fe3
Parent:        88b92d4225b90db82047f3bac55d8059918e9c1b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 14:10:18 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

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


