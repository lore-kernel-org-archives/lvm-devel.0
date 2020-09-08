From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:03:43 +0000 (GMT)
Subject: master - tests: check for cache_version that supports v2
Message-ID: <20200908220343.DC24F385702B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8dea63d30fd336051ec549d96c70abef6a9bfdec
Commit:        8dea63d30fd336051ec549d96c70abef6a9bfdec
Parent:        ce5ea07411d57a2bd276d8d29e46ce30b957f657
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 20:35:55 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 21:23:03 2020 +0200

tests: check for cache_version that supports v2

---
 test/shell/cache-single-split.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/cache-single-split.sh b/test/shell/cache-single-split.sh
index 7fc17867c..a6deb0dc9 100644
--- a/test/shell/cache-single-split.sh
+++ b/test/shell/cache-single-split.sh
@@ -48,6 +48,11 @@ mount_umount()
 aux have_cache 1 10 0 || skip
 which mkfs.xfs || skip
 
+case $(cache_check -V) in
+# support for v2 starts with version 0.7
+0.[0..6]*) skip 'At least version 0.7 of cache_check tool is needed.' ;;
+esac
+
 mount_dir="mnt"
 mkdir -p "$mount_dir"
 


