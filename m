From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 13:41:49 +0000 (UTC)
Subject: master - tests: check warn about belong is printed
Message-ID: <20160223134149.1080F60A54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d7e83c73cba507c4e5d798dbfe00314a4850b02
Commit:        5d7e83c73cba507c4e5d798dbfe00314a4850b02
Parent:        c0b836e316c20b8ed4325331cf33ef36815eb233
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 14:38:26 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:41:24 2016 +0100

tests: check warn about belong is printed

---
 test/shell/pvremove-usage.sh |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index 94c606b..08c8b24 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -54,14 +54,17 @@ for mdacp in 0 1 2; do
     vgcreate $vg "$dev1" "$dev2"
 
     # pvremove -f fails when pv in a vg (---metadatacopies $mdacp)
-    not pvremove -f "$dev1"
+    not pvremove -f "$dev1" 2>&1 | tee out
+    grep "belongs" out
     pvs "$dev1"
 
     # pvremove -ff fails without confirmation when pv in a vg (---metadatacopies $mdacp)
-    echo n | not pvremove -ff "$dev1"
+    not pvremove -ff "$dev1" 2>&1 | tee out
+    grep "belongs" out
 
     # pvremove -ff succeds with confirmation when pv in a vg (---metadatacopies $mdacp)
-    pvremove -ffy "$dev1"
+    pvremove -ffy "$dev1" 2>&1 | tee out
+    grep "belongs" out
     not pvs "$dev1"
 
     vgreduce --removemissing $vg


