From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:27 +0000 (UTC)
Subject: master - test: Disable lvmetad debug log on another bunch of tests.
Message-ID: <20150205134327.A73D960E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17575403d487d8f0deeceea78520f53b68c8573c
Commit:        17575403d487d8f0deeceea78520f53b68c8573c
Parent:        1f727f3f3d925af35877ad572ba606965bc6f1e7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 08:31:53 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Disable lvmetad debug log on another bunch of tests.

---
 test/shell/mirror-vgreduce-removemissing.sh |    3 +++
 test/shell/process-each-lv.sh               |    3 +++
 test/shell/pvmove-basic.sh                  |    5 ++++-
 test/shell/vgsplit-operation.sh             |    3 +++
 4 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index fd71696..8891369 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -14,6 +14,9 @@ test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
 
 . lib/inittest
 
+# disable lvmetad logging as it bogs down test systems
+test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+
 lv_is_on_ ()
 {
 	local lv=$vg/$1
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 0260951..355e92e 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -13,6 +13,9 @@ test_description='Exercise toollib process_each_lv'
 
 . lib/inittest
 
+# disable lvmetad logging as it bogs down test systems
+test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+
 aux prepare_devs 10
 
 #
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index c326dc3..e5add05 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -16,6 +16,9 @@ test_description="ensure that pvmove works with basic options"
 
 which md5sum || skip
 
+# disable lvmetad logging as it bogs down test systems
+test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+
 # ---------------------------------------------------------------------
 # Utilities
 
@@ -355,4 +358,4 @@ else
 fi
 
 lvremove -ff $vg
-done
\ No newline at end of file
+done
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 8081b38..6b478e8 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -13,6 +13,9 @@
 
 . lib/inittest
 
+# disable lvmetad logging as it bogs down test systems
+test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+
 COMM() {
 	LAST_TEST="$@"
 }


