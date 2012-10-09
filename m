From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 23:49:13 +0000 (UTC)
Subject: master - test: Skip thin tests if thin support is configured out.
Message-ID: <20121009234913.3A902246B@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e523f01d07d7d819c2f0d9b1595e628ddffea24
Commit:        6e523f01d07d7d819c2f0d9b1595e628ddffea24
Parent:        d760669e80f029a4d507e91ad431431b627f5555
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 10 00:20:22 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 10 00:20:22 2012 +0200

test: Skip thin tests if thin support is configured out.

---
 test/Makefile.in                 |    1 +
 test/api/thin_percent.sh         |    2 +-
 test/lib/aux.sh                  |    6 ++++++
 test/shell/discards-thin.sh      |    2 +-
 test/shell/lvconvert-thin.sh     |    2 +-
 test/shell/lvcreate-thin-snap.sh |    2 +-
 test/shell/lvcreate-thin.sh      |    2 +-
 7 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index da97f2c..6d7ee2c 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -98,6 +98,7 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
+	echo 'export THIN=@THIN@' >> $@-t
 	mv $@-t $@
 
 LIB = lib/not lib/should lib/harness \
diff --git a/test/api/thin_percent.sh b/test/api/thin_percent.sh
index bba33ba..9287cf3 100644
--- a/test/api/thin_percent.sh
+++ b/test/api/thin_percent.sh
@@ -13,7 +13,7 @@
 
 . lib/test
 
-aux target_at_least dm-thin-pool 1 0 0 || skip
+aux have_thin 1 0 0 || skip
 
 # disable thin_check if not present in system
 which thin_check || aux lvmconf 'global/thin_check_executable = ""'
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6cfd6db..d972d10 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -530,6 +530,12 @@ target_at_least()
 	test "$revision" -ge "$3" 2>/dev/null || return 1
 }
 
+have_thin()
+{
+    target_at_least dm-thin-pool "$@" || exit 1
+    test "$THIN" = shared || test "$THIN" = internal || exit 1
+}
+
 test -f DEVICES && devs=$(cat DEVICES)
 
 #unset LVM_VALGRIND
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 28300d9..ec3bd1f 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -18,7 +18,7 @@
 #
 # Main
 #
-aux target_at_least dm-thin-pool 1 1 0 || skip
+aux have_thin 1 1 0 || skip
 
 aux prepare_pvs 2 64
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 3ad3248..abaa620 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -15,7 +15,7 @@
 #
 # Main
 #
-aux target_at_least dm-thin-pool 1 0 0 || skip
+aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 4 64
 
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 0e91222..2ee8748 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -26,7 +26,7 @@ check_lv_field_modules_()
 #
 # Main
 #
-aux target_at_least dm-thin-pool 1 0 0 || skip
+aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 2 64
 
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 32ffef8..7ba97ed 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -29,7 +29,7 @@ check_lv_field_modules_()
 #
 # Main
 #
-aux target_at_least dm-thin-pool 1 0 0 || skip
+aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 2 64
 


