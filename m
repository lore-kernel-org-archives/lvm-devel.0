From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:38 -0400
Subject: master - tests: drop useless literal
Message-ID: <201707101232.v6ACWc60022630@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff2242036b9719c51a7f000dcb91f3ad5aa2580a
Commit:        ff2242036b9719c51a7f000dcb91f3ad5aa2580a
Parent:        5214e62f095909da03fac49d2a9e4fa7dabf7244
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 19:45:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: drop useless literal

Here was usage of '\' unneeded.
---
 test/shell/vgchange-many.sh |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index 72dcc0c..2c73e48 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -30,23 +30,23 @@ vgcreate -s 128K $vg $(cat DEVICES)
 vgcfgbackup -f data $vg
 
 # Generate a lot of devices (size of 1 extent)
-awk -v DEVICES=$DEVICES '/^\t\}/ { \
-    printf("\t}\n\tlogical_volumes {\n");\
+awk -v DEVICES=$DEVICES '/^\t\}/ {
+    printf("\t}\n\tlogical_volumes {\n");
     cnt=0;
-    for (i = 0; i < DEVICES; i++) { \
-	printf("\t\tlvol%06d  {\n", i);\
-	printf("\t\t\tid = \"%06d-1111-2222-3333-2222-1111-%06d\"\n", i, i); \
-	print "\t\t\tstatus = [\"READ\", \"WRITE\", \"VISIBLE\"]"; \
-	print "\t\t\tsegment_count = 1"; \
-	print "\t\t\tsegment1 {"; \
-	print "\t\t\t\tstart_extent = 0"; \
-	print "\t\t\t\textent_count = 1"; \
-	print "\t\t\t\ttype = \"striped\""; \
-	print "\t\t\t\tstripe_count = 1"; \
-	print "\t\t\t\tstripes = ["; \
-	print "\t\t\t\t\t\"pv0\", " cnt++; \
-	printf("\t\t\t\t]\n\t\t\t}\n\t\t}\n"); \
-      } \
+    for (i = 0; i < DEVICES; i++) {
+	printf("\t\tlvol%06d  {\n", i);
+	printf("\t\t\tid = \"%06d-1111-2222-3333-2222-1111-%06d\"\n", i, i);
+	print "\t\t\tstatus = [\"READ\", \"WRITE\", \"VISIBLE\"]";
+	print "\t\t\tsegment_count = 1";
+	print "\t\t\tsegment1 {";
+	print "\t\t\t\tstart_extent = 0";
+	print "\t\t\t\textent_count = 1";
+	print "\t\t\t\ttype = \"striped\"";
+	print "\t\t\t\tstripe_count = 1";
+	print "\t\t\t\tstripes = [";
+	print "\t\t\t\t\t\"pv0\", " cnt++;
+	printf("\t\t\t\t]\n\t\t\t}\n\t\t}\n");
+      }
   }
   {print}
 ' data >data_new


