From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:47:11 +0000 (UTC)
Subject: master - tests: update lvresize testing
Message-ID: <20170219234711.01DE160563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f2639d01d8e1ac6e95ad7855abb93b5cd260a22
Commit:        5f2639d01d8e1ac6e95ad7855abb93b5cd260a22
Parent:        13dd1ca757ab861bcd8f761f60e3c17384ae6326
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 19 22:59:21 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 20 00:44:12 2017 +0100

tests: update lvresize testing

Add missing tests for some lvresize acceptable options.
---
 test/shell/lvresize-usage.sh |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index a136147..35f6e57 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -34,9 +34,26 @@ lvremove -ff $vg
 
 lvcreate -L 10M -n lv $vg "$dev1"
 lvextend -L +10M $vg/lv "$dev2"
+lvextend --type striped -m0 -L +10M $vg/lv "$dev2"
 
 # Attempt to reduce with lvextend and vice versa:
 not lvextend -L 16M $vg/lv
 not lvreduce -L 32M $vg/lv
 
 lvremove -ff $vg
+
+lvcreate --type mirror -L 4 -n $lv1 $vg
+# Incorrent name for resized LV
+not lvextend --type mirror -L 10 -n $lv1 $vg
+# Same size
+not lvextend --type mirror -L 4 $vg/$lv1
+# Cannot use any '-' or '+'  sign for --mirror arg
+not lvextend --type mirror -L+2 -m-1 $vg/$lv1
+not lvextend --type mirror -L+2 -m+1 $vg/$lv1
+
+lvextend --type mirror -L+4 -m1 $vg/$lv1
+
+lvs -a $vg
+check  lv_field $vg/$lv1 size "8.00m"
+
+lvremove -ff $vg


