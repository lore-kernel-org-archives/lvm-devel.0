From: David Teigland <teigland@sourceware.org>
Date: Thu, 9 Mar 2017 11:44:19 -0500
Subject: master - tests relative-sign-options.sh: skip without thin
Message-ID: <201703091644.v29GiJns013367@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43bcd7393ca6d45583d2e64c9a6fcf8a7ed06487
Commit:        43bcd7393ca6d45583d2e64c9a6fcf8a7ed06487
Parent:        aa312722234621b7917e6cd51a39a323eb777079
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 9 10:43:41 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 9 10:43:41 2017 -0600

tests relative-sign-options.sh: skip without thin

---
 test/shell/relative-sign-options.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index 314f6b1..f1dab45 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -17,6 +17,8 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
+aux have_thin 1 0 0 || skip
+
 aux prepare_vg 1 256
 
 lvcreate -an -n $lv1 -l4 $vg


