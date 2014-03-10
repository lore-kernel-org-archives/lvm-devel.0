From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:25 +0000 (UTC)
Subject: master - tests: skip another kernel
Message-ID: <20140310112725.A9AF0603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=41e1b12e036ef2079586c4c567eae060c2635062
Commit:        41e1b12e036ef2079586c4c567eae060c2635062
Parent:        d913fcbd4616279829fd495e6384b661b897c6df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 22:38:06 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:10 2014 +0100

tests: skip another kernel

This kernel has still buggy kmem_cache debugging so skip it for raid456.
---
 test/lib/aux.sh                |    6 ++++++
 test/shell/lvchange-raid456.sh |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5d2d188..b2d73a6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -671,8 +671,14 @@ raid456_replace_works() {
 # old instance to be preserved and causes a colision (and thus failure) in
 # kmem_cache_create().  I see this regularly in testing the following
 # kernels:
+#
+# This seems to be finaly resolved with this patch:
+# http://www.redhat.com/archives/dm-devel/2014-March/msg00008.html
+# so we need to put here exlusion for kernes which do trace SLUB
+#
 	case $(uname -r) in
 	  3.10.11-200.fc19.i686|3.10.11-200.fc19.x86_64) return 1 ;;
+	  3.13.5-101.fc19.i686.PAE) return 1 ;;
 	esac
 }
 
diff --git a/test/shell/lvchange-raid456.sh b/test/shell/lvchange-raid456.sh
index 41a0dfd..83f82c3 100644
--- a/test/shell/lvchange-raid456.sh
+++ b/test/shell/lvchange-raid456.sh
@@ -13,6 +13,7 @@ TEST_RAID=raid456
 
 . shell/lvchange-raid.sh
 
+aux raid456_replace_works || skip
 aux target_at_least dm-raid 1 5 2 || skip
 
 run_types raid4 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"


