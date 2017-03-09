From: David Teigland <teigland@sourceware.org>
Date: Thu, 9 Mar 2017 12:30:47 -0500
Subject: master - tests relative-sign-options: only skip thin part
Message-ID: <201703091730.v29HUlOC011452@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=716c3453343009536daf459f10761bd6f322e221
Commit:        716c3453343009536daf459f10761bd6f322e221
Parent:        43bcd7393ca6d45583d2e64c9a6fcf8a7ed06487
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 9 11:29:54 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 9 11:29:54 2017 -0600

tests relative-sign-options: only skip thin part

---
 test/shell/relative-sign-options.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index f1dab45..3bf076a 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -17,8 +17,6 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
-aux have_thin 1 0 0 || skip
-
 aux prepare_vg 1 256
 
 lvcreate -an -n $lv1 -l4 $vg
@@ -70,13 +68,15 @@ lvcreate -an -n $lv6 -l1 $vg
 lvresize -y -l+100%FREE $vg/$lv6
 lvremove $vg/$lv6
 
+if aux have_thin 1 0 0 ; then
 # relative poolmetadatasize
-
 lvcreate --type thin-pool -L64 --poolmetadatasize 32 -n $lv7 $vg
 lvresize --poolmetadatasize 64 $vg/$lv7
 lvresize --poolmetadatasize +8 $vg/$lv7
 not lvresize -y --poolmetadatasize -8 $vg/$lv7
 
 lvextend --poolmetadatasize +8 $vg/$lv7
+not lvextend -y --poolmetadatasize -8 $vg/$lv7
+fi
 
 vgremove -y $vg


