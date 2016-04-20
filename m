From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Apr 2016 22:35:54 +0000 (UTC)
Subject: master - tests: minor update
Message-ID: <20160420223554.18797608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ce486e881a96db24a1f46a99110b0eb7009b0de
Commit:        7ce486e881a96db24a1f46a99110b0eb7009b0de
Parent:        545b58542cec657af5125d16125732b424274982
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 20 23:21:03 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 21 00:34:01 2016 +0200

tests: minor update

---
 test/shell/pvmove-background.sh |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
index 000de1c..26970d4 100644
--- a/test/shell/pvmove-background.sh
+++ b/test/shell/pvmove-background.sh
@@ -21,11 +21,15 @@ for mode in "--atomic" ""
 do
 lvcreate -aey -l1 -n $lv1 $vg "$dev1"
 
-lvs -o +devices | grep "$dev1"
+lvs -o +devices | tee out
+grep "$dev1" out
+
 LVM_TEST_TAG="kill_me_$PREFIX" pvmove $mode -i 1 -b "$dev1" "$dev2"
 sleep 5 # arbitrary...
-lvs -o +devices | not grep "pvmove"
-lvs -o +devices | grep "$dev2"
+lvs -o +devices | tee out
+not grep "pvmove" out
+lvs -o +devices | tee out
+grep "$dev2" out
 
 lvremove -ff $vg
 done


