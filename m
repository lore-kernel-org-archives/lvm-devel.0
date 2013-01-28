From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 28 Jan 2013 18:37:36 +0000 (UTC)
Subject: master - Test (RAID): Test for RAID10 activations when devices are missing
Message-ID: <20130128183736.6734B1213@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3cfe9d9b7d77d2641b052c33316fda71d05b0d7
Commit:        a3cfe9d9b7d77d2641b052c33316fda71d05b0d7
Parent:        2be83f45431313947619ac57e9554c59621c371b
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jan 28 12:32:33 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jan 28 12:32:33 2013 -0600

Test (RAID):  Test for RAID10 activations when devices are missing

Test the fix for bug 889358.  RAID10 had been failing to activate when
there were devices that had failed in more than one mirror set.
---
 test/shell/lvchange-partial.sh |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index fe642d4..bc9a514 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -13,7 +13,7 @@
 
 aux target_at_least dm-raid 1 1 0 || skip
 
-aux prepare_vg 2
+aux prepare_vg 4
 
 lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
 lvchange -an $vg/$lv1
@@ -64,3 +64,17 @@ not lvchange --zero y $vg/$lv1
 not lvchange --resync -ay $vg/$lv1
 not lvchange --resync --addtag foo $vg/$lv1
 
+aux enable_dev "$dev1"
+lvremove -ff $vg
+
+# rhbz 889358
+# Should be able to activate when RAID10
+# has failed devs in different mirror sets.
+if aux target_at_least dm-raid 1 3 2; then
+	lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
+	aux wait_for_sync $vg $lv1
+	lvchange -an $vg/$lv1
+	aux disable_dev "$dev1" "$dev3"
+	lvchange -ay $vg/$lv1 --partial
+	lvchange -an $vg/$lv1
+fi


