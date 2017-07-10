From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:44 -0400
Subject: master - tests: export many shell vars with 1 command
Message-ID: <201707101232.v6ACWiOP022668@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c87e1afa0327c60621075f581bffb30b33735442
Commit:        c87e1afa0327c60621075f581bffb30b33735442
Parent:        c48149cf80c6582c2369bc7f8a33d794021d9dae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 13:33:55 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: export many shell vars with 1 command

---
 test/Makefile.in     |   36 ++++++++++++++++++++----------------
 test/lib/inittest.sh |    7 ++++---
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index c399596..eee9bf2 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -273,22 +273,26 @@ lib/flavour-%: $(srcdir)/lib/flavour-%.sh .lib-dir-stamp
 	cp $< $@
 
 lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
-	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
-	echo 'export THIN=@THIN@' >> $@-t
-	echo 'export RAID=@RAID@' >> $@-t
-	echo 'export CACHE=@CACHE@' >> $@-t
-	echo 'export LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
-	echo 'export LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
-	echo 'export DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
-	echo 'export CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
-	echo 'export LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD- at THIN_CHECK_CMD@}' >> $@-t
-	echo 'export LVM_TEST_THIN_DUMP_CMD=$${LVM_TEST_THIN_DUMP_CMD- at THIN_DUMP_CMD@}' >> $@-t
-	echo 'export LVM_TEST_THIN_REPAIR_CMD=$${LVM_TEST_THIN_REPAIR_CMD- at THIN_REPAIR_CMD@}' >> $@-t
-	echo 'export LVM_TEST_THIN_RESTORE_CMD=$${LVM_TEST_THIN_RESTORE_CMD- at THIN_RESTORE_CMD@}' >> $@-t
-	echo 'export LVM_TEST_CACHE_CHECK_CMD=$${LVM_TEST_CACHE_CHECK_CMD- at CACHE_CHECK_CMD@}' >> $@-t
-	echo 'export LVM_TEST_CACHE_DUMP_CMD=$${LVM_TEST_CACHE_DUMP_CMD- at CACHE_DUMP_CMD@}' >> $@-t
-	echo 'export LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD- at CACHE_REPAIR_CMD@}' >> $@-t
-	echo 'export LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD- at CACHE_RESTORE_CMD@}' >> $@-t
+	echo 'DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
+	echo 'THIN=@THIN@' >> $@-t
+	echo 'RAID=@RAID@' >> $@-t
+	echo 'CACHE=@CACHE@' >> $@-t
+	echo 'LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
+	echo 'LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
+	echo 'DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
+	echo 'CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
+	echo 'LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD- at THIN_CHECK_CMD@}' >> $@-t
+	echo 'LVM_TEST_THIN_DUMP_CMD=$${LVM_TEST_THIN_DUMP_CMD- at THIN_DUMP_CMD@}' >> $@-t
+	echo 'LVM_TEST_THIN_REPAIR_CMD=$${LVM_TEST_THIN_REPAIR_CMD- at THIN_REPAIR_CMD@}' >> $@-t
+	echo 'LVM_TEST_THIN_RESTORE_CMD=$${LVM_TEST_THIN_RESTORE_CMD- at THIN_RESTORE_CMD@}' >> $@-t
+	echo 'LVM_TEST_CACHE_CHECK_CMD=$${LVM_TEST_CACHE_CHECK_CMD- at CACHE_CHECK_CMD@}' >> $@-t
+	echo 'LVM_TEST_CACHE_DUMP_CMD=$${LVM_TEST_CACHE_DUMP_CMD- at CACHE_DUMP_CMD@}' >> $@-t
+	echo 'LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD- at CACHE_REPAIR_CMD@}' >> $@-t
+	echo 'LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD- at CACHE_RESTORE_CMD@}' >> $@-t
+	echo 'export DM_UDEV_SYNCHRONISATION THIN RAID CACHE\' >> $@-t
+	echo ' LVMETAD_PIDFILE LVMPOLLD_PIDFILE DMEVENTD_PIDFILE CLVMD_PIDFILE\' >> $@-t
+	echo ' LVM_TEST_THIN_CHECK_CMD LVM_TEST_THIN_DUMP_CMD LVM_TEST_THIN_REPAIR_CMD LVM_TEST_THIN_RESTORE_CMD\' >> $@-t
+	echo ' LVM_TEST_CACHE_CHECK_CMD LVM_TEST_CACHE_DUMP_CMD LVM_TEST_CACHE_REPAIR_CMD LVM_TEST_CACHE_RESTORE_CMD' >> $@-t
 	mv $@-t $@
 
 lib/paths-installed: lib/paths-common
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index f959b71..d3844b4 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -57,9 +57,10 @@ TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \
 RUNNING_DMEVENTD=$(pgrep dmeventd || true)
 
 export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
-export LVM_LOG_FILE_EPOCH=DEBUG
-export LVM_LOG_FILE_MAX_LINES=100000
-export LVM_EXPECTED_EXIT_STATUS=1
+LVM_LOG_FILE_EPOCH=DEBUG
+LVM_LOG_FILE_MAX_LINES=100000
+LVM_EXPECTED_EXIT_STATUS=1
+export LVM_LOG_FILE_EPOCH LVM_LOG_FILE_MAX_LINES LVM_EXPECTED_EXIT_STATUS
 
 test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
 trap 'aux teardown' EXIT # don't forget to clean up


