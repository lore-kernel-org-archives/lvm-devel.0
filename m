From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:33 -0500
Subject: master - tests: check inactive extorig resize
Message-ID: <201802282022.w1SKMXlg009819@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc4855acbe98cea36228afeeaa6ce7f800459308
Commit:        cc4855acbe98cea36228afeeaa6ce7f800459308
Parent:        052f28746d1d90883f63e9fb1ef86efb03133fe7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 28 19:03:20 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:15:55 2018 +0100

tests: check inactive extorig resize

---
 test/shell/lvresize-thin-external-origin.sh |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index aa5e4bf..6dbfe4a 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -43,8 +43,15 @@ not lvresize -L+10 $vg/$lv1
 lvresize -L-5 -f $vg/$lv1
 check lv_field $vg/$lv1 lv_size "5.00" --units m --nosuffix
 
+# Inactive LV cannot be resized as well
+lvchange -an $vg
 not lvresize -L+15 -y $vg/$lv1
 check lv_field $vg/$lv1 lv_size "5.00" --units m --nosuffix
+lvchange -ay $vg/$lv1
+
+not lvresize -L+15 -y $vg/$lv1
+check lv_field $vg/$lv1 lv_size "5.00" --units m --nosuffix
+
 
 # Try to resize again back up to the size of external origin
 lvresize -L+5 -f $vg/$lv1


