From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 10 Feb 2014 18:02:36 +0000 (UTC)
Subject: master - autoreconf: latest changes
Message-ID: <20140210180236.3529B61023@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0d64554e6067edfcc4ed782d5e685cdd12ff894
Commit:        a0d64554e6067edfcc4ed782d5e685cdd12ff894
Parent:        fd41dd8f9ca38a31144ab7f8ed6a14b455dd7611
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 10 19:02:18 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 10 19:02:18 2014 +0100

autoreconf: latest changes

---
 configure               |   62 +++++++++++++++++++++++++----------------------
 lib/misc/configure.h.in |    6 ++--
 2 files changed, 36 insertions(+), 32 deletions(-)

diff --git a/configure b/configure
index 20d99dd..735137b 100755
--- a/configure
+++ b/configure
@@ -606,7 +606,6 @@ kernelvsn
 missingkernel
 kerneldir
 interface
-CACHE
 CMIRRORD_PIDFILE
 CLVMD_PIDFILE
 LVMETAD_PIDFILE
@@ -689,6 +688,7 @@ CLUSTER
 CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
+CACHE
 BUILD_LVMETAD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
@@ -1617,7 +1617,6 @@ Optional Packages:
   --with-mirrors=TYPE     mirror support: internal/shared/none
                           [[TYPE=internal]]
   --with-raid=TYPE        raid support: internal/shared/none [[TYPE=internal]]
-  --with-cache=TYPE       cache support: internal/shared/none [[TYPE=internal]]
   --with-replicators=TYPE replicator support: internal/shared/none
                           [[TYPE=none]]
   --with-thin=TYPE        thin provisioning support: internal/shared/none
@@ -1625,6 +1624,8 @@ Optional Packages:
   --with-thin-check=PATH  thin_check tool: [[autodetect]]
   --with-thin-dump=PATH   thin_dump tool: [[autodetect]]
   --with-thin-repair=PATH thin_repair tool: [[autodetect]]
+  --with-cache=TYPE       cache support: internal/shared/none
+                          [[TYPE=internal]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-default-pid-dir=PID_DIR
@@ -7120,31 +7121,6 @@ $as_echo "#define RAID_INTERNAL 1" >>confdefs.h
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include cache" >&5
-$as_echo_n "checking whether to include cache... " >&6; }
-
-# Check whether --with-cache was given.
-if test "${with_cache+set}" = set; then :
-  withval=$with_cache; CACHE=$withval
-else
-  CACHE=internal
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
-$as_echo "$CACHE" >&6; }
-
-if [ "x$CACHE" != xnone -a "x$CACHE" != xinternal -a "x$CACHE" != xshared ];
- then  as_fn_error $? "--with-cache parameter invalid
-" "$LINENO" 5
-fi;
-
-if test x$CACHE = xinternal; then
-
-$as_echo "#define CACHE_INTERNAL 1" >>confdefs.h
-
-fi
-
-################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include replicators" >&5
 $as_echo_n "checking whether to include replicators... " >&6; }
 
@@ -7559,6 +7535,30 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include cache" >&5
+$as_echo_n "checking whether to include cache... " >&6; }
+
+# Check whether --with-cache was given.
+if test "${with_cache+set}" = set; then :
+  withval=$with_cache; CACHE=$withval
+else
+  CACHE=internal
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
+$as_echo "$CACHE" >&6; }
+
+if [ "x$CACHE" != xnone -a "x$CACHE" != xinternal -a "x$CACHE" != xshared ];
+ then  as_fn_error $? "--with-cache parameter invalid
+" "$LINENO" 5
+fi;
+
+if test x$CACHE = xinternal; then
+
+$as_echo "#define CACHE_INTERNAL 1" >>confdefs.h
+
+fi
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
@@ -11452,8 +11452,9 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/cache_segtype/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_red_hat.service scripts/clvmd_init_red_hat scripts/lvm2_clvmd_red_hat.service scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12169,9 +12170,9 @@ do
     "lib/replicator/Makefile") CONFIG_FILES="$CONFIG_FILES lib/replicator/Makefile" ;;
     "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
     "lib/raid/Makefile") CONFIG_FILES="$CONFIG_FILES lib/raid/Makefile" ;;
-    "lib/cache_segtype/Makefile") CONFIG_FILES="$CONFIG_FILES lib/cache_segtype/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "lib/thin/Makefile") CONFIG_FILES="$CONFIG_FILES lib/thin/Makefile" ;;
+    "lib/cache_segtype/Makefile") CONFIG_FILES="$CONFIG_FILES lib/cache_segtype/Makefile" ;;
     "libdaemon/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/Makefile" ;;
     "libdaemon/client/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/client/Makefile" ;;
     "libdaemon/server/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/server/Makefile" ;;
@@ -12186,7 +12187,10 @@ do
     "scripts/blkdeactivate.sh") CONFIG_FILES="$CONFIG_FILES scripts/blkdeactivate.sh" ;;
     "scripts/blk_availability_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_init_red_hat" ;;
     "scripts/blk_availability_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_systemd_red_hat.service" ;;
+    "scripts/lvm2_cluster_activation_red_hat.sh") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_red_hat.sh" ;;
+    "scripts/lvm2_cluster_activation_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_red_hat.service" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
+    "scripts/lvm2_clvmd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_clvmd_red_hat.service" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 0acb9b7..c1f088e 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -3,6 +3,9 @@
 /* Define to 1 to use libblkid detection of signatures when wiping. */
 #undef BLKID_WIPING_SUPPORT
 
+/* Define to 1 to include built-in support for cache. */
+#undef CACHE_INTERNAL
+
 /* Define to 1 if the `closedir' function returns void instead of `int'. */
 #undef CLOSEDIR_VOID
 
@@ -558,9 +561,6 @@
 /* The path to 'thin_repair', if available. */
 #undef THIN_REPAIR_CMD
 
-/* Define to 1 to include built-in support for cache[pool] segment types. */
-#undef CACHE_INTERNAL
-
 /* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
 #undef TIME_WITH_SYS_TIME
 


