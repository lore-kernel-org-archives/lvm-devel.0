From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:32 +0000 (UTC)
Subject: master - tests: check we recognize broken table entry
Message-ID: <20161205161532.B7706602B1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=022d3af06853ba4e627e098ac04ef1a8f9806edc
Commit:        022d3af06853ba4e627e098ac04ef1a8f9806edc
Parent:        36b211b464a02cf054a838ccf9139379897cf973
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 1 10:45:37 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:12:42 2016 +0100

tests: check we recognize broken table entry

One (initial) test to recognize we see a mismatching
table entry for cache LV.
---
 test/shell/lvs-cache.sh |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index a06a023..2c518d0 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -22,6 +22,25 @@ SKIP_WITH_LVMPOLLD=1
 aux have_cache 1 3 0 || skip
 aux prepare_vg 5 8000
 
+# Use 10M origin size
+lvcreate -L10 -n $lv1 $vg
+lvcreate -H -L5 $vg/$lv1
+
+# replace 10M size with 5M size of cache device
+NEWCLINE=$(dmsetup table $vg-$lv1 | sed 's/20480/10240/')
+dmsetup reload $vg-$lv1 --table "$NEWCLINE"
+dmsetup resume $vg-$lv1
+
+# Check that mismatching cache target is shown by lvs
+lvs -a $vg 2>&1 | grep "WARNING"
+check lv_attr_bit state $vg/$lv1 "X"
+
+lvs -o+lv_active $vg
+
+lvremove -f $vg
+
+
+
 lvcreate --type cache-pool -L10 $vg/cpool
 lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
 lvs -o lv_name,cache_policy


