From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 31 Mar 2016 10:22:22 +0000 (UTC)
Subject: master - tests: fixed cache target reacts faster
Message-ID: <20160331102222.3543060E7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c57798463078325a7b7b1221d154312a20678e93
Commit:        c57798463078325a7b7b1221d154312a20678e93
Parent:        bc5376b151f4a5993c223de51f0218aa95184471
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 31 12:00:20 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 31 12:21:40 2016 +0200

tests: fixed cache target reacts faster

After kernel fixed in 4.6 cache target reacts promptly
and switches to Fail-ed state when disk error is detected.

Handle both cases in test...
---
 test/shell/lvconvert-repair-cache.sh |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 60b0b5d..1fdfd3f 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -101,13 +101,15 @@ sync
 # Seriously damage cache metadata
 aux error_dev "$dev1" 2054:2
 
-# Here we usually for the 1st. notice needs_check
-check lv_attr_bit state $vg/$lv1 "c"
-
-sleep .1
-
-# And now cache is finaly Failed
-check lv_attr_bit health $vg/$lv1 "F"
+# On fixed kernel we get instant Fail here
+get lv_field  $vg/$lv1 lv_attr | tee out
+grep "Cwi-a-C-F-" out || {
+	# while on older unfixed we just notice needs_check
+	grep "Cwi-c-C---" out
+	sleep .1
+	# And now cache is finaly Failed
+	check lv_attr_bit health $vg/$lv1 "F"
+}
 check lv_field $vg/$lv1 lv_health_status "failed"
 
 aux disable_dev "$dev1"


