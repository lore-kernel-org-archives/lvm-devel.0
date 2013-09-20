From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 20 Sep 2013 16:35:40 +0000 (UTC)
Subject: master - test: Blacklist fedora-19 kernel for RAID4/5/6 dev replace tests
Message-ID: <20130920163540.08EED61481@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cafde608909b87aedeb76f0eda1397f7bf98fea4
Commit:        cafde608909b87aedeb76f0eda1397f7bf98fea4
Parent:        bd75844024ad4a2e66c7743c50e189a00c233284
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Sep 20 11:33:29 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Sep 20 11:33:29 2013 -0500

test: Blacklist fedora-19 kernel for RAID4/5/6 dev replace tests

A know issue with kmem_cach is causing failures while testing
RAID 4/5/6 device replacement.  Blacklist the offending kernel
so that these tests are not performed there.
---
 test/lib/aux.sh              |   33 +++++++++++++++++++++++++++++++++
 test/shell/lvconvert-raid.sh |    2 ++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6194492..7939949 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -615,6 +615,39 @@ skip_if_mirror_recovery_broken() {
         if test `uname -r` = 3.3.4-5.fc17.x86_64; then skip; fi
 }
 
+skip_if_raid456_replace_broken() {
+# The way kmem_cache aliasing is done in the kernel is broken.
+# It causes RAID 4/5/6 tests to fail.
+#
+# The problem with kmem_cache* is this:
+# *) Assume CONFIG_SLUB is set
+# 1) kmem_cache_create(name="foo-a")
+# - creates new kmem_cache structure
+# 2) kmem_cache_create(name="foo-b")
+# - If identical cache characteristics, it will be merged with the previously
+#   created cache associated with "foo-a".  The cache's refcount will be
+#   incremented and an alias will be created via sysfs_slab_alias().
+# 3) kmem_cache_destroy(<ptr>)
+# - Attempting to destroy cache associated with "foo-a", but instead the
+#   refcount is simply decremented.  I don't even think the sysfs aliases are
+#   ever removed...
+# 4) kmem_cache_create(name="foo-a")
+# - This FAILS because kmem_cache_sanity_check colides with the existing
+#   name ("foo-a") associated with the non-removed cache.
+#
+# This is a problem for RAID (specifically dm-raid) because the name used
+# for the kmem_cache_create is ("raid%d-%p", level, mddev).  If the cache
+# persists for long enough, the memory address of an old mddev will be
+# reused for a new mddev - causing an identical formulation of the cache
+# name.  Even though kmem_cache_destory had long ago been used to delete
+# the old cache, the merging of caches has cause the name and cache of that
+# old instance to be preserved and causes a colision (and thus failure) in
+# kmem_cache_create().  I see this regularly in testing the following
+# kernels:
+        if test `uname -r` = 3.10.11-200.fc19.i686; then skip; fi
+        if test `uname -r` = 3.10.11-200.fc19.x86_64; then skip; fi
+}
+
 udev_wait() {
 	pgrep udev >/dev/null || return 0
 	which udevadm >/dev/null || return 0
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 4c08386..6762db2 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -206,6 +206,8 @@ for i in {1..3}; do
 	lvremove -ff $vg
 done
 
+aux skip_if_raid456_replace_broken
+
 # RAID 4/5/6 (can replace up to 'parity' devices)
 for i in 4 5 6; do
 	lvcreate --type raid$i -i 3 -l 3 -n $lv1 $vg


