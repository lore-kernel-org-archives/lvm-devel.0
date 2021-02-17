From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:43 +0000 (GMT)
Subject: main - tests: check resize of cached vdopool
Message-ID: <20210217105443.91002382E818@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19e137358008ce0a73c980d10cfdeaad7f9a5045
Commit:        19e137358008ce0a73c980d10cfdeaad7f9a5045
Parent:        5bf1dba9eb8a8b77410e386e59dadeb27801b14e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 11:50:27 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:53:18 2021 +0100

tests: check resize of cached vdopool

---
 test/shell/lvconvert-cache-vdo.sh | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-cache-vdo.sh b/test/shell/lvconvert-cache-vdo.sh
index 8e2894877..39caf5e03 100644
--- a/test/shell/lvconvert-cache-vdo.sh
+++ b/test/shell/lvconvert-cache-vdo.sh
@@ -17,6 +17,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+percent_() {
+	get lv_field $vg/vpool data_percent | cut -d. -f1
+}
+
 aux have_vdo 6 2 0 || skip
 aux have_cache 1 3 0 || skip
 
@@ -41,9 +45,15 @@ lvchange -ay $vg
 check dev_md5sum $vg $lv1
 
 lvconvert --yes --cache --cachepool cpool $vg/vpool
-lvconvert --splitcache $vg/vpool
+
+VDODATA="$(percent_)"
+# Check resize of cached VDO pool
+lvextend -L+1G $vg/vpool
 
 lvs -a $vg
+# Check after resize usage is reduced
+test "$(percent_)" -lt $VDODATA
+lvconvert --splitcache $vg/vpool
 
 lvconvert --yes --cache --cachepool cpool $vg/$lv1
 check dev_md5sum $vg $lv1


