From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 26 Apr 2018 07:06:38 -0400
Subject: master - [unit-test] Push the new unit test framwork.
Message-ID: <201804261106.w3QB6c3v002897@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea34dad66fe4a46a2f7ec51c4358144f6cb3ed67
Commit:        ea34dad66fe4a46a2f7ec51c4358144f6cb3ed67
Parent:        c7fdacbc5001f3bdfaa441fedb7da120af5d8af9
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Apr 26 11:59:39 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Apr 26 11:59:39 2018 +0100

[unit-test] Push the new unit test framwork.

See doc/unit-test.txt for details.

Some bcache tests failing.  Probably due to dct changing semantics, will
fix in follow up patch.
---
 .gitignore                                         |    2 +
 Makefile.in                                        |    7 +-
 configure                                          |  175 +----
 configure.in                                       |    7 +-
 doc/unit-tests.txt                                 |  257 +++++
 report-generators/lib/log.rb                       |   40 -
 report-generators/lib/report_templates.rb          |   38 -
 report-generators/lib/reports.rb                   |   58 --
 report-generators/lib/schedule_file.rb             |   56 --
 report-generators/lib/string-store.rb              |   42 -
 report-generators/memcheck.rb                      |   86 --
 report-generators/templates/boiler_plate.rhtml     |   25 -
 report-generators/templates/index.rhtml            |   17 -
 report-generators/templates/memcheck.rhtml         |   30 -
 report-generators/templates/unit_detail.rhtml      |   37 -
 report-generators/templates/unit_test.rhtml        |   23 -
 report-generators/test/example.schedule            |    4 -
 .../test/strings/more_strings/test3.txt            |    1 -
 report-generators/test/strings/test1.txt           |    1 -
 report-generators/test/strings/test2               |    3 -
 report-generators/test/tc_log.rb                   |   36 -
 report-generators/test/tc_schedule_file.rb         |   38 -
 report-generators/test/tc_string_store.rb          |   29 -
 report-generators/test/ts.rb                       |   13 -
 report-generators/title_page.rb                    |   42 -
 report-generators/unit_test.rb                     |   56 --
 reports/stylesheet.css                             |   77 --
 test/unit/Makefile.in                              |   39 -
 test/unit/bcache_t.c                               |  636 ------------
 test/unit/bitset_t.c                               |  129 ---
 test/unit/config_t.c                               |  152 ---
 test/unit/dmlist_t.c                               |   49 -
 test/unit/dmstatus_t.c                             |   72 --
 test/unit/matcher_data.h                           | 1013 --------------------
 test/unit/matcher_t.c                              |   70 --
 test/unit/percent_t.c                              |  101 --
 test/unit/run.c                                    |   39 -
 test/unit/string_t.c                               |   78 --
 test/unit/units.h                                  |   35 -
 unit-test/Makefile.in                              |   40 +
 unit-test/bcache_t.c                               |  783 +++++++++++++++
 unit-test/bitset_t.c                               |  148 +++
 unit-test/config_t.c                               |  167 ++++
 unit-test/dmlist_t.c                               |   49 +
 unit-test/dmstatus_t.c                             |   84 ++
 unit-test/framework.c                              |   66 ++
 unit-test/framework.h                              |   49 +
 unit-test/matcher_data.h                           | 1013 ++++++++++++++++++++
 unit-test/matcher_t.c                              |   89 ++
 unit-test/percent_t.c                              |  102 ++
 unit-test/run.c                                    |  309 ++++++
 unit-test/string_t.c                               |   91 ++
 unit-test/units.h                                  |   46 +
 53 files changed, 3301 insertions(+), 3348 deletions(-)

diff --git a/.gitignore b/.gitignore
index 7e031bf..201cbe5 100644
--- a/.gitignore
+++ b/.gitignore
@@ -79,3 +79,5 @@ test/lib/vgrename
 test/lib/vgs
 test/lib/vgscan
 test/lib/vgsplit
+
+unit-test/unit-test
diff --git a/Makefile.in b/Makefile.in
index 146ed55..2420267 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -43,8 +43,7 @@ endif
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = conf include man test scripts \
     libdaemon lib tools daemons libdm \
-    udev po liblvm python \
-    unit-tests/datastruct unit-tests/mm unit-tests/regex
+    udev po liblvm python
 tools.distclean: test.distclean
 endif
 DISTCLEAN_DIRS += lcov_reports*
@@ -97,7 +96,7 @@ endif
 DISTCLEAN_TARGETS += cscope.out
 CLEAN_DIRS += autom4te.cache
 
-check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock unit: all
+check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock unit-test: all
 	$(MAKE) -C test $(@)
 
 conf.generate man.generate: tools
@@ -212,7 +211,7 @@ endif
 endif
 
 ifeq ("$(TESTING)", "yes")
-include test/unit/Makefile
+include unit-test/Makefile
 endif
 
 ifneq ($(shell which ctags),)
diff --git a/configure b/configure
index 5011089..63ca480 100755
--- a/configure
+++ b/configure
@@ -707,9 +707,7 @@ FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
 DMEVENTD_PATH
-AIO_LIBS
 DL_LIBS
-AIO
 DEVMAPPER
 DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_LVMPOLLD
@@ -783,8 +781,6 @@ LOCKD_SANLOCK_LIBS
 LOCKD_SANLOCK_CFLAGS
 VALGRIND_LIBS
 VALGRIND_CFLAGS
-CUNIT_LIBS
-CUNIT_CFLAGS
 GENPNG
 GENHTML
 LCOV
@@ -957,7 +953,6 @@ enable_profiling
 enable_testing
 enable_valgrind_pool
 enable_devmapper
-enable_aio
 enable_lvmetad
 enable_lvmpolld
 enable_lvmlockd_sanlock
@@ -1047,8 +1042,6 @@ DLM_CFLAGS
 DLM_LIBS
 SACKPT_CFLAGS
 SACKPT_LIBS
-CUNIT_CFLAGS
-CUNIT_LIBS
 VALGRIND_CFLAGS
 VALGRIND_LIBS
 LOCKD_SANLOCK_CFLAGS
@@ -1707,7 +1700,6 @@ Optional Features:
   --enable-testing        enable testing targets in the makefile
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
-  --disable-aio           disable asynchronous I/O
   --enable-lvmetad        enable the LVM Metadata Daemon
   --enable-lvmpolld       enable the LVM Polling Daemon
   --enable-lvmlockd-sanlock
@@ -1894,9 +1886,6 @@ Some influential environment variables:
   SACKPT_CFLAGS
               C compiler flags for SACKPT, overriding pkg-config
   SACKPT_LIBS linker flags for SACKPT, overriding pkg-config
-  CUNIT_CFLAGS
-              C compiler flags for CUNIT, overriding pkg-config
-  CUNIT_LIBS  linker flags for CUNIT, overriding pkg-config
   VALGRIND_CFLAGS
               C compiler flags for VALGRIND, overriding pkg-config
   VALGRIND_LIBS
@@ -3195,7 +3184,6 @@ case "$host_os" in
 		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
-		AIO=yes
 		BUILD_LVMETAD=no
 		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
@@ -3215,7 +3203,6 @@ case "$host_os" in
 		CLDNOWHOLEARCHIVE=
 		LIB_SUFFIX=dylib
 		DEVMAPPER=yes
-		AIO=no
 		ODIRECT=no
 		DM_IOCTLS=no
 		SELINUX=no
@@ -11623,101 +11610,6 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $TESTING" >&5
 $as_echo "$TESTING" >&6; }
 
-if test "$TESTING" = yes; then
-	pkg_config_init
-
-pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for CUNIT" >&5
-$as_echo_n "checking for CUNIT... " >&6; }
-
-if test -n "$CUNIT_CFLAGS"; then
-    pkg_cv_CUNIT_CFLAGS="$CUNIT_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"cunit >= 2.0\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "cunit >= 2.0") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_CUNIT_CFLAGS=`$PKG_CONFIG --cflags "cunit >= 2.0" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-if test -n "$CUNIT_LIBS"; then
-    pkg_cv_CUNIT_LIBS="$CUNIT_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"cunit >= 2.0\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "cunit >= 2.0") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_CUNIT_LIBS=`$PKG_CONFIG --libs "cunit >= 2.0" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-
-
-
-if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
-else
-        _pkg_short_errors_supported=no
-fi
-        if test $_pkg_short_errors_supported = yes; then
-	        CUNIT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "cunit >= 2.0" 2>&1`
-        else
-	        CUNIT_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "cunit >= 2.0" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$CUNIT_PKG_ERRORS" >&5
-
-	as_fn_error $? "Package requirements (cunit >= 2.0) were not met:
-
-$CUNIT_PKG_ERRORS
-
-Consider adjusting the PKG_CONFIG_PATH environment variable if you
-installed software in a non-standard prefix.
-
-Alternatively, you may set the environment variables CUNIT_CFLAGS
-and CUNIT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." "$LINENO" 5
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
-is in your PATH or set the PKG_CONFIG environment variable to the full
-path to pkg-config.
-
-Alternatively, you may set the environment variables CUNIT_CFLAGS
-and CUNIT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-
-To get pkg-config, see <http://pkg-config.freedesktop.org/>.
-See \`config.log' for more details" "$LINENO" 5; }
-else
-	CUNIT_CFLAGS=$pkg_cv_CUNIT_CFLAGS
-	CUNIT_LIBS=$pkg_cv_CUNIT_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
-
-fi
-fi
-
 ################################################################################
 TESTSUITE_DATA='${datarootdir}/lvm2-testsuite'
 # double eval needed ${datarootdir} -> ${prefix}/share -> real path
@@ -11845,67 +11737,6 @@ $as_echo "#define DEVMAPPER_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use asynchronous I/O" >&5
-$as_echo_n "checking whether to asynchronous I/O... " >&6; }
-# Check whether --enable-aio was given.
-if test "${enable_aio+set}" = set; then :
-  enableval=$enable_aio; AIO=$enableval
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $AIO" >&5
-$as_echo "$AIO" >&6; }
-
-if test "$AIO" = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for io_setup in -laio" >&5
-$as_echo_n "checking for io_setup in -laio... " >&6; }
-if ${ac_cv_lib_aio_io_setup+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  ac_check_lib_save_LIBS=$LIBS
-LIBS="-laio  $LIBS"
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char io_setup ();
-int
-main ()
-{
-return io_setup ();
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
-  ac_cv_lib_aio_io_setup=yes
-else
-  ac_cv_lib_aio_io_setup=no
-fi
-rm -f core conftest.err conftest.$ac_objext \
-    conftest$ac_exeext conftest.$ac_ext
-LIBS=$ac_check_lib_save_LIBS
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_aio_io_setup" >&5
-$as_echo "$ac_cv_lib_aio_io_setup" >&6; }
-if test "x$ac_cv_lib_aio_io_setup" = xyes; then :
-
-$as_echo "#define AIO_SUPPORT 1" >>confdefs.h
-
-		AIO_LIBS="-laio"
-		AIO_SUPPORT=yes
-else
-  AIO_LIBS=
-		AIO_SUPPORT=no
-fi
-
-fi
-
-################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build LVMetaD" >&5
 $as_echo_n "checking whether to build LVMetaD... " >&6; }
 # Check whether --enable-lvmetad was given.
@@ -15857,10 +15688,8 @@ _ACEOF
 
 
 
-
-
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/
 Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_h
 at.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/
 Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_h
 at.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile unit-test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16634,7 +16463,7 @@ do
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
-    "test/unit/Makefile") CONFIG_FILES="$CONFIG_FILES test/unit/Makefile" ;;
+    "unit-test/Makefile") CONFIG_FILES="$CONFIG_FILES unit-test/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "udev/Makefile") CONFIG_FILES="$CONFIG_FILES udev/Makefile" ;;
 
diff --git a/configure.in b/configure.in
index 0d268e8..461c21b 100644
--- a/configure.in
+++ b/configure.in
@@ -1076,11 +1076,6 @@ AC_ARG_ENABLE(testing,
 	      TESTING=$enableval, TESTING=no)
 AC_MSG_RESULT($TESTING)
 
-if test "$TESTING" = yes; then
-	pkg_config_init
-	PKG_CHECK_MODULES(CUNIT, cunit >= 2.0)
-fi
-
 ################################################################################
 dnl -- Set LVM2 testsuite data
 TESTSUITE_DATA='${datarootdir}/lvm2-testsuite'
@@ -2251,7 +2246,7 @@ scripts/lvmdump.sh
 scripts/Makefile
 test/Makefile
 test/api/Makefile
-test/unit/Makefile
+unit-test/Makefile
 tools/Makefile
 udev/Makefile
 ])
diff --git a/doc/unit-tests.txt b/doc/unit-tests.txt
new file mode 100644
index 0000000..55bbceb
--- /dev/null
+++ b/doc/unit-tests.txt
@@ -0,0 +1,257 @@
+Building unit tests
+===================
+
+  make unit-unit/unit-test
+
+
+Running unit tests
+==================
+
+The tests leave no artifacts at the moment, so you can just run
+unit-test/unit-test from wherever you want.
+
+  ./unit-test <list|run> [pattern]
+
+Listing tests
+-------------
+
+Every test has a symbolic path associated with it.  Just like file paths they
+are split into components separated by '/'s.  The 'list' command will show you
+a tree of these tests, along with some description text.
+
+
+ejt at devel-vm1:~/lvm2/unit-test/$ ./unit-test list
+base
+  data-struct
+    bitset
+      and  .................................................  and all bits
+      equal  ...............................................  equality
+      get_next  ............................................  get next set bit
+    list
+      splice  ..............................................  joining lists together
+    string
+      asprint  .............................................  tests asprint
+      strncpy  .............................................  tests string copying
+  device
+    bcache
+      block-size-multiple-page  ............................  block size must be a multiple of page size
+      block-size-positive  .................................  block size must be positive
+      blocks-get-evicted  ..................................  block get evicted with many reads
+      cache-blocks-positive  ...............................  nr cache blocks must be positive
+      create-destroy  ......................................  simple create/destroy
+      flush-waits  .........................................  flush waits for all dirty
+      get-reads  ...........................................  bcache_get() triggers read
+      prefetch-never-waits  ................................  too many prefetches does not trigger a wait
+      prefetch-reads  ......................................  prefetch issues a read
+      read-multiple-files  .................................  read from multiple files
+      reads-cached  ........................................  repeated reads are cached
+      writeback-occurs  ....................................  dirty data gets written back
+      zero-flag-dirties  ...................................  zeroed data counts as dirty
+  formatting
+    percent
+      0  ...................................................  Pretty printing of percentages near 0%
+      100  .................................................  Pretty printing of percentages near 100%
+  regex
+    fingerprints  ..........................................  not sure
+    matching  ..............................................  test the matcher with a variety of regexes
+dm
+  target
+    mirror
+      status  ..............................................  parsing mirror status
+metadata
+  config
+    cascade  ...............................................  cascade
+    clone  .................................................  duplicating a config tree
+    parse  .................................................  parsing various
+
+
+An optional 'pattern' argument may be specified to select subsets of tests.
+This pattern is a posix regex and does a substring match, so you will need to
+use anchors if you particularly want the match at the beginning or end of the
+string.
+
+ejt at devel-vm1:~/lvm2/unit-test/$ ./unit-test list data-struct
+base
+  data-struct
+    bitset
+      and  .................................................  and all bits
+      equal  ...............................................  equality
+      get_next  ............................................  get next set bit
+    list
+      splice  ..............................................  joining lists together
+    string
+      asprint  .............................................  tests asprint
+      strncpy  .............................................  tests string copying
+
+ejt at devel-vm1:~/lvm2/unit-test/$ ./unit-test list s$
+base
+  device
+    bcache
+      flush-waits  .........................................  flush waits for all dirty
+      get-reads  ...........................................  bcache_get() triggers read
+      prefetch-never-waits  ................................  too many prefetches does not trigger a wait
+      prefetch-reads  ......................................  prefetch issues a read
+      read-multiple-files  .................................  read from multiple files
+      writeback-occurs  ....................................  dirty data gets written back
+      zero-flag-dirties  ...................................  zeroed data counts as dirty
+  regex
+    fingerprints  ..........................................  not sure
+dm
+  target
+    mirror
+      status  ..............................................  parsing mirror status
+
+
+Running tests
+=============
+
+'make run-unit-test' from the top level will run all unit tests.  But I tend to
+run it by hand to I can select just the tests I'm working on.
+
+Use the 'run' command to run the tests.  Currently all logging goes to stderr,
+so the test runner prints a line at the start of the test and a line
+indicating success or failure at the end.
+
+ejt at devel-vm1:~/lvm2/unit-test/$ ./unit-test run bcache/block-size
+[RUN    ] /base/device/bcache/block-size-multiple-page
+bcache block size must be a multiple of page size
+bcache block size must be a multiple of page size
+bcache block size must be a multiple of page size
+bcache block size must be a multiple of page size
+[     OK] /base/device/bcache/block-size-multiple-page
+
+[RUN    ] /base/device/bcache/block-size-positive
+bcache must have a non zero block size
+[     OK] /base/device/bcache/block-size-positive
+
+
+2/2 tests passed
+
+
+ejt at devel-vm1:~/lvm2/unit-test/$ ./unit-test run data-struct
+[RUN    ] /base/data-struct/bitset/and
+[     OK] /base/data-struct/bitset/and
+
+[RUN    ] /base/data-struct/bitset/equal
+[     OK] /base/data-struct/bitset/equal
+
+[RUN    ] /base/data-struct/bitset/get_next
+[     OK] /base/data-struct/bitset/get_next
+
+[RUN    ] /base/data-struct/list/splice
+[     OK] /base/data-struct/list/splice
+
+[RUN    ] /base/data-struct/string/asprint
+[     OK] /base/data-struct/string/asprint
+
+[RUN    ] /base/data-struct/string/strncpy
+[     OK] /base/data-struct/string/strncpy
+
+
+6/6 tests passed
+
+
+Writing tests
+=============
+
+[See unit-test/framework.h and unit-test/units.h for the details]
+
+Tests are grouped together into 'suites', all tests in a suite share a
+'fixture'.  A fixture is a void * to any object you want; use it to set up any
+common environment that you need for the tests to run (eg, creating a dm_pool).
+
+Test suites have nothing to do with the test paths, you can have tests from
+different suites with similar paths, the runner sorts things for you.
+
+Put your tests in a file in unit-test/, with '_t' at the end of the name
+(convention only, nothing relies on this).
+
+#include "units.h"
+
+Then write any fixtures you need:
+
+eg,
+static void *_mem_init(void) {
+	struct dm_pool *mem = dm_pool_create("bitset test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+Then write your tests, which should take the void * that was returned by your
+fixture.  Use the T_ASSERT* macros to indicate failure.
+
+eg,
+static void test_equal(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
+
+        int i, j;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                dm_bit_set(bs1, i);
+                dm_bit_set(bs2, i);
+        }
+
+        T_ASSERT(dm_bitset_equal(bs1, bs2));
+        T_ASSERT(dm_bitset_equal(bs2, bs1));
+
+        for (i = 0; i < NR_BITS; i++) {
+                bit_flip(bs1, i);
+                T_ASSERT(!dm_bitset_equal(bs1, bs2));
+                T_ASSERT(!dm_bitset_equal(bs2, bs1));
+
+                T_ASSERT(dm_bitset_equal(bs1, bs1)); /* comparing with self */
+                bit_flip(bs1, i);
+        }
+}
+
+At the end of your test file you should write a function that builds one or
+more test suites and adds them to the list of all suites that is passed in.  I
+tend to write a little macro (T) to save typing the same test path repeatedly.
+
+eg,
+#define T(path, desc, fn) register_test(ts, "/base/data-struct/bitset/" path, desc, fn)
+
+void bitset_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("get_next", "get next set bit", test_get_next);
+	T("equal", "equality", test_equal);
+	T("and", "and all bits", test_and);
+
+	dm_list_add(all_tests, &ts->list);
+}
+
+Then you need to declare your registration function and call it in units.h.
+
+
+// Declare the function that adds tests suites here ...
+  ...
+void bitset_tests(struct dm_list *suites);
+  ...
+
+// ... and call it in here.
+static inline void register_all_tests(struct dm_list *suites)
+{
+	...
+	bitset_tests(suites);
+	...
+}
+
+Finally add your test file to the Makefile.in and rerun configure.
+
diff --git a/report-generators/lib/log.rb b/report-generators/lib/log.rb
deleted file mode 100644
index cf74fc4..0000000
--- a/report-generators/lib/log.rb
+++ /dev/null
@@ -1,40 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# Merely wraps the logger library with a bit of standard policy.
-require 'logger'
-
-module Log
-  $log = Logger.new(STDERR)
-
-  def init(io_)
-    $log = Logger.new(io_)
-  end
-end
-
-def fatal(*args)
-  $log.fatal(*args)
-end
-
-def error(*args)
-  $log.error(*args)
-end
-
-def info(*args)
-  $log.info(*args)
-end
-
-def warning(*args)
-  $log.warn(*args)
-end
-
-def debug(*args)
-  $log.debug(*args)
-end
diff --git a/report-generators/lib/report_templates.rb b/report-generators/lib/report_templates.rb
deleted file mode 100644
index 3da29ab..0000000
--- a/report-generators/lib/report_templates.rb
+++ /dev/null
@@ -1,38 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# Policy for the location of report templates
-require 'string-store'
-
-class TemplateStringStore < StringStore
-  def initialize()
-    super(['report-generators/templates'])
-  end
-end
-
-module ReportTemplates
-  def generate_report(report, bs, dest_path = nil)
-    include Reports
-    reports = ReportRegister.new
-    template_store = TemplateStringStore.new
-    report = reports.get_report(report)
-    erb = ERB.new(template_store.lookup(report.template))
-    body = erb.result(bs)
-    title = report.short_desc
-
-    erb = ERB.new(template_store.lookup("boiler_plate.rhtml"))
-    txt = erb.result(binding)
-
-    dest_path = dest_path.nil? ? report.path : dest_path
-    dest_path.open("w") do |out|
-      out.puts txt
-    end
-  end
-end
diff --git a/report-generators/lib/reports.rb b/report-generators/lib/reports.rb
deleted file mode 100644
index 2930f83..0000000
--- a/report-generators/lib/reports.rb
+++ /dev/null
@@ -1,58 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# Data about the various reports we support
-require 'log'
-require 'pathname'
-
-module Reports
-  Report = Struct.new(:short_desc, :desc, :path, :template)
-
-  class ReportRegister
-    attr_reader :reports
-
-    private
-    def add_report(sym, *args)
-      @reports[sym] = Report.new(*args)
-    end
-
-    public
-    def initialize()
-      @reports = Hash.new
-
-      add_report(:unit_test,
-                 "Unit Tests",
-                 "unit tests",
-                 Pathname.new("reports/unit.html"),
-                 Pathname.new("unit_test.rhtml"))
-
-      add_report(:memcheck,
-                 "Memory Tests",
-                 "unit tests with valgrind memory checking",
-                 Pathname.new("reports/memcheck.html"),
-                 Pathname.new("memcheck.rhtml"))
-
-      add_report(:unit_detail,
-                 "Unit Test Detail",
-                 "unit test detail",
-                 Pathname.new("reports/unit_detail.html"), # FIXME replace this with a lambda
-                 Pathname.new("unit_detail.rhtml"))
-    end
-
-    def get_report(sym)
-      raise RuntimeError, "unknown report '#{sym}'" unless @reports.member?(sym)
-      @reports[sym]
-    end
-
-    def each(&block)
-      @reports.each(&block)
-    end
-  end
-end
diff --git a/report-generators/lib/schedule_file.rb b/report-generators/lib/schedule_file.rb
deleted file mode 100644
index d695f57..0000000
--- a/report-generators/lib/schedule_file.rb
+++ /dev/null
@@ -1,56 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# Parses the simple colon delimited test schedule files.
-
-ScheduledTest = Struct.new(:desc, :command_line, :status, :output)
-
-class Schedule
-  attr_reader :dir, :schedules
-
-  def initialize(dir, ss)
-    @dir = dir
-    @schedules = ss
-  end
-
-  def run
-    Dir::chdir(@dir.to_s) do
-      @schedules.each do |s|
-        reader, writer = IO.pipe
-        print "#{s.desc} ... "
-        pid = spawn(s.command_line, [ STDERR, STDOUT ] => writer)
-        writer.close
-        _, s.status = Process::waitpid2(pid)
-        puts (s.status.success? ? "pass" : "fail")
-        s.output = reader.read
-      end
-    end
-  end
-
-  def self.read(dir, io)
-    ss = Array.new
-
-    io.readlines.each do |line|
-      case line.strip
-      when /^\#.*/
-        next
-
-      when /([^:]+):(.*)/
-        ss << ScheduledTest.new($1.strip, $2.strip)
-
-      else
-        raise RuntimeError, "badly formatted schedule line"
-      end  
-    end
-
-    Schedule.new(dir, ss)
-  end
-end
-
diff --git a/report-generators/lib/string-store.rb b/report-generators/lib/string-store.rb
deleted file mode 100644
index 66d2231..0000000
--- a/report-generators/lib/string-store.rb
+++ /dev/null
@@ -1,42 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# Provides a simple way of accessing the contents of files by a symbol
-# name.  Useful for erb templates.
-
-require 'pathname'
-
-class StringStore
-  attr_accessor :path
-
-  def initialize(p)
-    @paths = p.nil? ? Array.new : p # FIXME: do we need to copy p ?
-  end
-
-  def lookup(sym)
-    files = expansions(sym)
-
-    @paths.each do |p|
-      files.each do |f|
-        pn = Pathname.new("#{p}/#{f}")
-        if pn.file?
-          return pn.read
-        end
-      end
-    end
-
-    raise RuntimeError, "unknown string entry: #{sym}"
-  end
-
-  private
-  def expansions(sym)
-    ["#{sym}", "#{sym}.txt"]
-  end
-end
diff --git a/report-generators/memcheck.rb b/report-generators/memcheck.rb
deleted file mode 100644
index 1dccd21..0000000
--- a/report-generators/memcheck.rb
+++ /dev/null
@@ -1,86 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# Reads the schedule files given on the command line.  Runs them and
-# generates the reports.
-
-# FIXME: a lot of duplication with unit_test.rb
-
-require 'schedule_file'
-require 'pathname'
-require 'reports'
-require 'erb'
-require 'report_templates'
-
-include ReportTemplates
-
-schedules = ARGV.map do |f|
-  p = Pathname.new(f)
-  Schedule.read(p.dirname, p)
-end
-
-total_passed = 0
-total_failed = 0
-
-# We need to make sure the lvm shared libs are in the LD_LIBRARY_PATH
-ENV['LD_LIBRARY_PATH'] = `pwd`.strip + "/libdm:" + (ENV['LD_LIBRARY_PATH'] || '')
-
-ENV['TEST_TOOL'] = "valgrind --leak-check=full --show-reachable=yes"
-
-schedules.each do |s|
-  s.run
-
-  s.schedules.each do |t|
-    if t.status.success?
-      total_passed += 1
-    else
-      total_failed += 1
-    end
-  end
-end
-
-def mangle(txt)
-  txt.gsub(/\s+/, '_')
-end
-
-MemcheckStats = Struct.new(:definitely_lost, :indirectly_lost, :possibly_lost, :reachable)
-
-def format(bytes, blocks)
-  "#{bytes} bytes, #{blocks} blocks"
-end
-
-# Examines the output for details of leaks
-def extract_stats(t)
-  d = i = p = r = '-'
-
-  t.output.split("\n").each do |l|
-    case l
-    when /==\d+==    definitely lost: ([0-9,]+) bytes in ([0-9,]+) blocks/
-        d = format($1, $2)
-    when /==\d+==    indirectly lost: ([0-9,]+) bytes in ([0-9,]+) blocks/
-        i = format($1, $2)
-    when /==\d+==    possibly lost: ([0-9,]+) bytes in ([0-9,]+) blocks/
-        p = format($1, $2)
-    when /==\d+==    still reachable: ([0-9,]+) bytes in ([0-9,]+) blocks/
-        r = format($1, $2)
-    end
-  end
-
-  MemcheckStats.new(d, i, p, r)
-end
-
-generate_report(:memcheck, binding)
-
-# now we generate a detail report for each schedule
-schedules.each do |s|
-  s.schedules.each do |t|
-    generate_report(:unit_detail, binding, Pathname.new("reports/memcheck_#{mangle(t.desc)}.html"))
-  end
-end
diff --git a/report-generators/templates/boiler_plate.rhtml b/report-generators/templates/boiler_plate.rhtml
deleted file mode 100644
index 23f01cb..0000000
--- a/report-generators/templates/boiler_plate.rhtml
+++ /dev/null
@@ -1,25 +0,0 @@
-<html>
-<head>
-<META http-equiv="Content-Type" content="text/html; charset=US-ASCII">
-<title><%= title %></title>
-<link title="Style" type="text/css" rel="stylesheet" href="stylesheet.css">
-</head>
-
-<body>
-<div id="banner">
-<h2><%= title %></h2>
-</div>
-<div id="main">
-  <div id="controls">
-    <table>
-      <tr><td><a href="index.html">Generation times</a></td></tr>
-      <tr><td><a href="unit.html">Unit tests</a></td></tr>
-      <tr><td><a href="memcheck.html">Memory tests</a></td></tr>
-    </table>
-  </div>
-
-  <div id="body">
-    <%= body %>
-  </div>
-</div>
-</body>
diff --git a/report-generators/templates/index.rhtml b/report-generators/templates/index.rhtml
deleted file mode 100644
index 6d72081..0000000
--- a/report-generators/templates/index.rhtml
+++ /dev/null
@@ -1,17 +0,0 @@
-<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
-<tr><th>Report</th><th>Generation time</th></tr>
-<% [:unit_test, :memcheck].each do |sym| %>
-<% r = reports.get_report(sym) %>
-<tr>
-  <td>
-    <% if r.path.file? %>
-    <a href="<%= r.path.to_s.gsub(/^reports\//, '') %>"><%= r.short_desc %></a>
-    <% else %>
-    <%= r.short_desc %>
-    <% end %>
-  </td>
-  <td><%= safe_mtime(r) %></td>
-</tr>
-<% end %>
-</table>
-
diff --git a/report-generators/templates/memcheck.rhtml b/report-generators/templates/memcheck.rhtml
deleted file mode 100644
index 75872ed..0000000
--- a/report-generators/templates/memcheck.rhtml
+++ /dev/null
@@ -1,30 +0,0 @@
-<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
-  <tr><th>Tests passed</th><th>Tests failed</th></tr>
-  <tr><td class="pass"><%= total_passed %></td><td <%= total_failed == 0 ? "" : "class=\"fail\""%>><%= total_failed %></td></tr>
-</table>
-
-<% schedules.each do |s| %>
-<h3><%= s.dir.sub('./unit-tests/', '') %></h3>
-<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
-<tr><th>Test</th><th>Result</th><th>Definitely lost</th><th>indirectly lost</th><th>possibly lost</th><th>still reachable</th><tr>
-
-<% s.schedules.each do |t| %>
-<tr>
-  <td>
-  <a href="memcheck_<%= mangle(t.desc) %>.html"><%= t.desc %></a>
-  </td>
-  <% if t.status.success? %>
-  <td class="pass">pass</td>
-  <% else %>
-  <td class="fail">fail</td>
-  <% end %>
- 
-  <% stats = extract_stats(t) %>
-  <td><%= stats.definitely_lost %></td>
-  <td><%= stats.indirectly_lost %></td>
-  <td><%= stats.possibly_lost %></td>
-  <td><%= stats.reachable %></td>
-</tr>
-<% end %>
-</table>
-<% end %>
diff --git a/report-generators/templates/unit_detail.rhtml b/report-generators/templates/unit_detail.rhtml
deleted file mode 100644
index 5324f07..0000000
--- a/report-generators/templates/unit_detail.rhtml
+++ /dev/null
@@ -1,37 +0,0 @@
-<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
-<tr><th>Test</th><th>Result</th></tr>
-<tr>
-  <td>
-  <%= t.desc %>
-  </td>
-  <% if t.status.success? %>
-  <td class="pass">pass</td>
-  <% else %>
-  <td class="fail">fail</td>
-  <% end %>
-</tr>
-</table>
-
-<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
-<tr><th>Command line</th></tr>
-<tr>
-  <td>
-  <pre>
-<%= t.command_line %>
-  </pre>
-  </td>
-</tr>
-</table>
-
-
-<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
-<tr><th>Output</th></tr>
-<tr>
-  <td>
-  <pre>
-<%= t.output %>
-  </pre>
-  </td>
-</tr>
-</table>
-
diff --git a/report-generators/templates/unit_test.rhtml b/report-generators/templates/unit_test.rhtml
deleted file mode 100644
index 3137abd..0000000
--- a/report-generators/templates/unit_test.rhtml
+++ /dev/null
@@ -1,23 +0,0 @@
-<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
-  <tr><th>Tests passed</th><th>Tests failed</th></tr>
-  <tr><td class="pass"><%= total_passed %></td><td <%= total_failed == 0 ? "" : "class=\"fail\""%>><%= total_failed %></td></tr>
-</table>
-
-<% schedules.each do |s| %>
-<h3><%= s.dir.sub('./unit-tests/', '') %></h3>
-<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
-<tr><th>Test</th><th>Result</th></tr>
-<% s.schedules.each do |t| %>
-<tr>
-  <td>
-  <a href="detail_<%= mangle(t.desc) %>.html"><%= t.desc %></a>
-  </td>
-  <% if t.status.success? %>
-  <td class="pass">pass</td>
-  <% else %>
-  <td class="fail">fail</td>
-  <% end %>
-</tr>
-<% end %>
-</table>
-<% end %>
diff --git a/report-generators/test/example.schedule b/report-generators/test/example.schedule
deleted file mode 100644
index f617187..0000000
--- a/report-generators/test/example.schedule
+++ /dev/null
@@ -1,4 +0,0 @@
-# This is a comment
-description number 1:$TEST_TOOL ls
-foo bar:   $TEST_TOOL du -hs .
-   	this comment is prefixed with whitespace: $TEST_TOOL date
\ No newline at end of file
diff --git a/report-generators/test/strings/more_strings/test3.txt b/report-generators/test/strings/more_strings/test3.txt
deleted file mode 100644
index 3e9ffe0..0000000
--- a/report-generators/test/strings/more_strings/test3.txt
+++ /dev/null
@@ -1 +0,0 @@
-lorem
diff --git a/report-generators/test/strings/test1.txt b/report-generators/test/strings/test1.txt
deleted file mode 100644
index af5626b..0000000
--- a/report-generators/test/strings/test1.txt
+++ /dev/null
@@ -1 +0,0 @@
-Hello, world!
diff --git a/report-generators/test/strings/test2 b/report-generators/test/strings/test2
deleted file mode 100644
index 54d55bf..0000000
--- a/report-generators/test/strings/test2
+++ /dev/null
@@ -1,3 +0,0 @@
-one
-two
-three
\ No newline at end of file
diff --git a/report-generators/test/tc_log.rb b/report-generators/test/tc_log.rb
deleted file mode 100644
index 8ed3396..0000000
--- a/report-generators/test/tc_log.rb
+++ /dev/null
@@ -1,36 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-require 'test/unit'
-require 'stringio'
-require 'log'
-
-class TestLog < Test::Unit::TestCase
-  include Log
-
-  private
-  def remove_timestamps(l)
-    l.gsub(/\[[^\]]*\]/, '')
-  end
-
-  public
-  def test_log
-    StringIO.open do |out|
-      init(out)
-
-      info("msg1")
-      warning("msg2")
-      debug("msg3")
-
-      assert_equal("I,   INFO -- : msg1\nW,   WARN -- : msg2\nD,  DEBUG -- : msg3\n",
-                   remove_timestamps(out.string))
-    end
-  end
-end
diff --git a/report-generators/test/tc_schedule_file.rb b/report-generators/test/tc_schedule_file.rb
deleted file mode 100644
index 00f9ec3..0000000
--- a/report-generators/test/tc_schedule_file.rb
+++ /dev/null
@@ -1,38 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-require 'test/unit'
-require 'pathname'
-require 'schedule_file'
-
-class TestScheduleFile < Test::Unit::TestCase
-  def test_reading
-    p = Pathname.new("report-generators/test/example.schedule")
-    p.open do |f|
-      s = Schedule.read(p.dirname, f)
-
-      assert_equal(3, s.schedules.size)
-      assert_equal(s.schedules[2].desc, "this comment is prefixed with whitespace")
-      assert_equal(s.schedules[0].command_line, "$TEST_TOOL ls")
-    end
-  end
-
-  def test_running
-    p = Pathname.new("report-generators/test/example.schedule")
-    p.open do |f|
-      s = Schedule.read(p.dirname, f)
-      s.run
-
-      s.schedules.each do |t|
-        assert(t.status.success?)
-      end
-    end
-  end
-end
diff --git a/report-generators/test/tc_string_store.rb b/report-generators/test/tc_string_store.rb
deleted file mode 100644
index 127e0a8..0000000
--- a/report-generators/test/tc_string_store.rb
+++ /dev/null
@@ -1,29 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-require 'string-store'
-require 'test/unit'
-
-class TestStringStore < Test::Unit::TestCase
-  def setup
-    @ss = StringStore.new(['report-generators/test/strings',
-                           'report-generators/test/strings/more_strings'])
-  end
-
-  def test_lookup
-    assert_equal("Hello, world!\n", @ss.lookup(:test1))
-    assert_equal("one\ntwo\nthree", @ss.lookup(:test2))
-    assert_equal("lorem\n", @ss.lookup(:test3))
-
-    assert_raises(RuntimeError) do
-      @ss.lookup(:unlikely_name)
-    end
-  end
-end
diff --git a/report-generators/test/ts.rb b/report-generators/test/ts.rb
deleted file mode 100644
index 0501780..0000000
--- a/report-generators/test/ts.rb
+++ /dev/null
@@ -1,13 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-require 'tc_log'
-require 'tc_string_store'
-require 'tc_schedule_file'
diff --git a/report-generators/title_page.rb b/report-generators/title_page.rb
deleted file mode 100644
index 66e5b03..0000000
--- a/report-generators/title_page.rb
+++ /dev/null
@@ -1,42 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# This generates the index for the reports, including generation
-# times.
-
-require 'log'
-require 'string-store'
-require 'reports'
-require 'erb'
-require 'report_templates'
-
-include Reports
-
-reports = ReportRegister.new
-
-def safe_mtime(r)
-  r.path.file? ? r.path.mtime.to_s : "not generated"
-end
-
-template_store = TemplateStringStore.new
-
-# FIXME: use generate_report() method
-erb = ERB.new(template_store.lookup("index.rhtml"))
-body = erb.result(binding)
-title = "Generation times"
-
-erb = ERB.new(template_store.lookup("boiler_plate.rhtml"))
-txt = erb.result(binding)
-
-Pathname.new("reports/index.html").open("w") do |f|
-  f.puts txt
-end
-
-
diff --git a/report-generators/unit_test.rb b/report-generators/unit_test.rb
deleted file mode 100644
index 1e5c895..0000000
--- a/report-generators/unit_test.rb
+++ /dev/null
@@ -1,56 +0,0 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# Reads the schedule files given on the command line.  Runs them and
-# generates the reports.
-
-require 'schedule_file'
-require 'pathname'
-require 'reports'
-require 'erb'
-require 'report_templates'
-
-include ReportTemplates
-
-schedules = ARGV.map do |f|
-  p = Pathname.new(f)
-  Schedule.read(p.dirname, p)
-end
-
-total_passed = 0
-total_failed = 0
-
-# We need to make sure the lvm shared libs are in the LD_LIBRARY_PATH
-ENV['LD_LIBRARY_PATH'] = `pwd`.strip + "/libdm:" + (ENV['LD_LIBRARY_PATH'] || '')
-
-schedules.each do |s|
-  s.run
-
-  s.schedules.each do |t|
-    if t.status.success?
-      total_passed += 1
-    else
-      total_failed += 1
-    end
-  end
-end
-
-def mangle(txt)
-  txt.gsub(/\s+/, '_')
-end
-
-generate_report(:unit_test, binding)
-
-# now we generate a detail report for each schedule
-schedules.each do |s|
-  s.schedules.each do |t|
-    generate_report(:unit_detail, binding, Pathname.new("reports/detail_#{mangle(t.desc)}.html"))
-  end
-end
diff --git a/reports/stylesheet.css b/reports/stylesheet.css
deleted file mode 100644
index 3d41926..0000000
--- a/reports/stylesheet.css
+++ /dev/null
@@ -1,77 +0,0 @@
-/* Styles for main page */
-#banner {
-  background: #9c9;
-  padding-top: 5px;
-  padding-bottom: 5px;
-  border-bottom: 2px solid;
-  font: small-caps 20px/20px "Times New Roman", serif;
-  color: #282;
-  text-align: center;
-}
-
-#banner img {
-  float: left;
-}
-
-#main {
-  margin-left: 0em;
-  padding-top: 4ex;
-  padding-left: 2em;
-  background: white;
-}
-
-h1 {
-  font:  150% sans-serif;
-  color: #226;
-  border-bottom: 3px dotted #77d;
-}
-
-body {
-    font: normal 75% verdana,arial,helvetica;
-    color:#000000;
-}
-
-table tr td, table tr th {
-  font-size: 75%;
-}
-
-table.stripes tr th {
-    font-weight: bold;
-    text-align: left;
-    background: #a0a0a0;
-}
-
-table.stripes tr td {
-    background: #ccccc0;
-}
-
-td.pass {
-  color: green;
-}
-
-td.fail {
-  color: red;
-  font-weight: bold;
-}
-
-#main {
-    padding-left: 0em;
-}
-
-#controls {
-  float: left;
-  padding-top: 1em;
-  padding-left: 1em;
-  padding-right: 1em;
-  padding-bottom: 1em;
-  width: 14em;
-  border-right: 2px solid;
-}
-
-#body {
-  margin-left: 16em;
-  padding-top: 4ex;
-  padding-left: 2em;
-  background: white;
-  border-left: 2px solid;
-}
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
deleted file mode 100644
index a070329..0000000
--- a/test/unit/Makefile.in
+++ /dev/null
@@ -1,39 +0,0 @@
-# Copyright (C) 2011-2018 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-UNIT_SOURCE=\
-	test/unit/bcache_t.c \
-
-
-#	test/unit/run.c
-
-#	test/unit/bitset_t.c\
-#	test/unit/config_t.c\
-#	test/unit/dmlist_t.c\
-#	test/unit/dmstatus_t.c\
-#	test/unit/matcher_t.c\
-#	test/unit/percent_t.c\
-#	test/unit/string_t.c\
-
-UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
-
-UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio
-
-test/unit/run: $(UNIT_OBJECTS) libdm/libdevmapper.$(LIB_SUFFIX) lib/liblvm-internal.a
-	@echo "    [LD] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
-	      -o $@ $(UNIT_OBJECTS) $(UNIT_LDLIBS)
-
-.PHONEY: unit-test
-unit-test: test/unit/run
-	@echo Running unit tests
-	LD_LIBRARY_PATH=libdm test/unit/run
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
deleted file mode 100644
index 07a45fe..0000000
--- a/test/unit/bcache_t.c
+++ /dev/null
@@ -1,636 +0,0 @@
-/*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <setjmp.h>
-
-#include "bcache.h"
-
-#define SHOW_MOCK_CALLS 0
-
-/*----------------------------------------------------------------
- * Assertions
- *--------------------------------------------------------------*/
-
-static jmp_buf _test_k;
-#define TEST_FAILED 1
-
-static void _fail(const char *fmt, ...)
-	__attribute__((format (printf, 1, 2)));
-
-
-static void _fail(const char *fmt, ...)
-{
-	va_list ap;
-
-	va_start(ap, fmt);
-	vfprintf(stderr, fmt, ap);
-	va_end(ap);
-	fprintf(stderr, "\n");
-
-	longjmp(_test_k, TEST_FAILED);
-}
-
-#define T_ASSERT(e) if (!(e)) {_fail("assertion failed: '%s'", # e);}
-
-/*----------------------------------------------------------------
- * Mock engine
- *--------------------------------------------------------------*/
-struct mock_engine {
-	struct io_engine e;
-	struct dm_list expected_calls;
-	struct dm_list issued_io;
-	unsigned max_io;
-	sector_t block_size;
-};
-
-enum method {
-	E_DESTROY,
-	E_ISSUE,
-	E_WAIT,
-	E_MAX_IO
-};
-
-struct mock_call {
-	struct dm_list list;
-	enum method m;
-
-	bool match_args;
-	enum dir d;
-	int fd;
-	block_address b;
-};
-
-struct mock_io {
-	struct dm_list list;
-	int fd;
-	sector_t sb;
-	sector_t se;
-	void *data;
-	void *context;
-};
-
-static const char *_show_method(enum method m)
-{
-	switch (m) {
-	case E_DESTROY:
-		return "destroy()";
-	case E_ISSUE:
-		return "issue()";
-	case E_WAIT:
-		return "wait()";
-	case E_MAX_IO:
-		return "max_io()";
-	}
-
-	return "<unknown>";
-}
-
-static void _expect(struct mock_engine *e, enum method m)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = m;
-	mc->match_args = false;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static void _expect_read(struct mock_engine *e, int fd, block_address b)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = E_ISSUE;
-	mc->match_args = true;
-	mc->d = DIR_READ;
-	mc->fd = fd;
-	mc->b = b;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static void _expect_write(struct mock_engine *e, int fd, block_address b)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = E_ISSUE;
-	mc->match_args = true;
-	mc->d = DIR_WRITE;
-	mc->fd = fd;
-	mc->b = b;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static struct mock_call *_match_pop(struct mock_engine *e, enum method m)
-{
-
-	struct mock_call *mc;
-
-	if (dm_list_empty(&e->expected_calls))
-		_fail("unexpected call to method %s\n", _show_method(m));
-
-	mc = dm_list_item(e->expected_calls.n, struct mock_call);
-	dm_list_del(&mc->list);
-
-	if (mc->m != m)
-		_fail("expected %s, but got %s\n", _show_method(mc->m), _show_method(m));
-#if SHOW_MOCK_CALLS
-	else
-		fprintf(stderr, "%s called (expected)\n", _show_method(m));
-#endif
-
-	return mc;
-}
-
-static void _match(struct mock_engine *e, enum method m)
-{
-	free(_match_pop(e, m));
-}
-
-static void _no_outstanding_expectations(struct mock_engine *e)
-{
-	struct mock_call *mc;
-
-	if (!dm_list_empty(&e->expected_calls)) {
-		fprintf(stderr, "unsatisfied expectations:\n");
-		dm_list_iterate_items (mc, &e->expected_calls)
-			fprintf(stderr, "  %s\n", _show_method(mc->m));
-	}
-	T_ASSERT(dm_list_empty(&e->expected_calls));
-}
-
-static struct mock_engine *_to_mock(struct io_engine *e)
-{
-	return container_of(e, struct mock_engine, e);
-}
-
-static void _mock_destroy(struct io_engine *e)
-{
-	struct mock_engine *me = _to_mock(e);
-
-	_match(me, E_DESTROY);
-	T_ASSERT(dm_list_empty(&me->issued_io));
-	T_ASSERT(dm_list_empty(&me->expected_calls));
-	free(_to_mock(e));
-}
-
-static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
-	      		sector_t sb, sector_t se, void *data, void *context)
-{
-	struct mock_io *io;
-	struct mock_call *mc;
-	struct mock_engine *me = _to_mock(e);
-
-	mc = _match_pop(me, E_ISSUE);
-	if (mc->match_args) {
-		T_ASSERT(d == mc->d);
-		T_ASSERT(fd == mc->fd);
-		T_ASSERT(sb == mc->b * me->block_size);
-		T_ASSERT(se == (mc->b + 1) * me->block_size);
-	}
-	free(mc);
-
-	io = malloc(sizeof(*io));
-	if (!io)
-		abort();
-
-	io->fd = fd;
-	io->sb = sb;
-	io->se = se;
-	io->data = data;
-	io->context = context;
-
-	dm_list_add(&me->issued_io, &io->list);
-	return true;
-}
-
-static bool _mock_wait(struct io_engine *e, io_complete_fn fn)
-{
-	struct mock_io *io;
-	struct mock_engine *me = _to_mock(e);
-	_match(me, E_WAIT);
-
-	// FIXME: provide a way to control how many are completed and whether
-	// they error.
-	T_ASSERT(!dm_list_empty(&me->issued_io));
-	io = dm_list_item(me->issued_io.n, struct mock_io);
-	dm_list_del(&io->list);
-	fn(io->context, 0);
-	return true;
-}
-
-static unsigned _mock_max_io(struct io_engine *e)
-{
-	struct mock_engine *me = _to_mock(e);
-	_match(me, E_MAX_IO);
-	return me->max_io;
-}
-
-static struct mock_engine *_mock_create(unsigned max_io, sector_t block_size)
-{
-	struct mock_engine *m = malloc(sizeof(*m));
-
-	m->e.destroy = _mock_destroy;
-	m->e.issue = _mock_issue;
-	m->e.wait = _mock_wait;
-	m->e.max_io = _mock_max_io;
-
-	m->max_io = max_io;
-	m->block_size = block_size;
-	dm_list_init(&m->expected_calls);
-	dm_list_init(&m->issued_io);
-
-	return m;
-}
-
-/*----------------------------------------------------------------
- * Fixtures
- *--------------------------------------------------------------*/
-struct fixture {
-	struct mock_engine *me;
-	struct bcache *cache;
-};
-
-static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_blocks)
-{
-	struct fixture *f = malloc(sizeof(*f));
-
-	f->me = _mock_create(16, block_size);
-	T_ASSERT(f->me);
-
-	_expect(f->me, E_MAX_IO);
-	f->cache = bcache_create(block_size, nr_cache_blocks, &f->me->e);
-	T_ASSERT(f->cache);
-
-	return f;
-}
-
-static void _fixture_exit(struct fixture *f)
-{
-	_expect(f->me, E_DESTROY);
-	bcache_destroy(f->cache);
-
-	free(f);
-}
-
-static void *_small_fixture_init(void)
-{
-	return _fixture_init(128, 16);
-}
-
-static void _small_fixture_exit(void *context)
-{
-	_fixture_exit(context);
-}
-
-static void *_large_fixture_init(void)
-{
-	return _fixture_init(128, 1024);
-}
-
-static void _large_fixture_exit(void *context)
-{
-	_fixture_exit(context);
-}
-
-/*----------------------------------------------------------------
- * Tests
- *--------------------------------------------------------------*/
-#define MEG 2048
-#define SECTOR_SHIFT 9
-
-static void good_create(sector_t block_size, unsigned nr_cache_blocks)
-{
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16, 128);
-
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
-	T_ASSERT(cache);
-
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
-}
-
-static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
-{
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16, 128);
-
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
-	T_ASSERT(!cache);
-
-	_expect(me, E_DESTROY);
-	me->e.destroy(&me->e);
-}
-
-static void test_create(void *fixture)
-{
-	good_create(8, 16);
-}
-
-static void test_nr_cache_blocks_must_be_positive(void *fixture)
-{
-	bad_create(8, 0);
-}
-
-static void test_block_size_must_be_positive(void *fixture)
-{
-	bad_create(0, 16);
-}
-
-static void test_block_size_must_be_multiple_of_page_size(void *fixture)
-{
-	static unsigned _bad_examples[] = {3, 9, 13, 1025};
-
-	unsigned i;
-
-	for (i = 0; i < DM_ARRAY_SIZE(_bad_examples); i++)
-		bad_create(_bad_examples[i], 16);
-
-	for (i = 1; i < 1000; i++)
-		good_create(i * 8, 16);
-}
-
-static void test_get_triggers_read(void *context)
-{
-	struct fixture *f = context;
-
-	int fd = 17;   // arbitrary key
-	struct block *b;
-
-	_expect_read(f->me, fd, 0);
-	_expect(f->me, E_WAIT);
-	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
-	bcache_put(b);
-}
-
-static void test_repeated_reads_are_cached(void *context)
-{
-	struct fixture *f = context;
-
-	int fd = 17;   // arbitrary key
-	unsigned i;
-	struct block *b;
-
-	_expect_read(f->me, fd, 0);
-	_expect(f->me, E_WAIT);
-	for (i = 0; i < 100; i++) {
-		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
-		bcache_put(b);
-	}
-}
-
-static void test_block_gets_evicted_with_many_reads(void *context)
-{
-	struct fixture *f = context;
-
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	const unsigned nr_cache_blocks = 16;
-
-	int fd = 17;   // arbitrary key
-	unsigned i;
-	struct block *b;
-
-	for (i = 0; i < nr_cache_blocks; i++) {
-		_expect_read(me, fd, i);
-		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
-		bcache_put(b);
-	}
-
-	// Not enough cache blocks to hold this one
-	_expect_read(me, fd, nr_cache_blocks);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b));
-	bcache_put(b);
-
-	// Now if we run through we should find one block has been
-	// evicted.  We go backwards because the oldest is normally
-	// evicted first.
-	_expect(me, E_ISSUE);
-	_expect(me, E_WAIT);
-	for (i = nr_cache_blocks; i; i--) {
-		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b));
-		bcache_put(b);
-	}
-}
-
-static void test_prefetch_issues_a_read(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	const unsigned nr_cache_blocks = 16;
-
-	int fd = 17;   // arbitrary key
-	unsigned i;
-	struct block *b;
-
-	for (i = 0; i < nr_cache_blocks; i++) {
-		// prefetch should not wait
-		_expect_read(me, fd, i);
-		bcache_prefetch(cache, fd, i);
-	}
-
-
-	for (i = 0; i < nr_cache_blocks; i++) {
-		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
-		bcache_put(b);
-	}
-}
-
-static void test_too_many_prefetches_does_not_trigger_a_wait(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-
-	const unsigned nr_cache_blocks = 16;
-	int fd = 17;   // arbitrary key
-	unsigned i;
-
-	for (i = 0; i < 10 * nr_cache_blocks; i++) {
-		// prefetch should not wait
-		if (i < nr_cache_blocks)
-			_expect_read(me, fd, i);
-		bcache_prefetch(cache, fd, i);
-	}
-
-	// Destroy will wait for any in flight IO triggered by prefetches.
-	for (i = 0; i < nr_cache_blocks; i++)
-		_expect(me, E_WAIT);
-}
-
-static void test_dirty_data_gets_written_back(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-
-	int fd = 17;   // arbitrary key
-	struct block *b;
-
-	// Expect the read
-	_expect_read(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
-	bcache_put(b);
-
-	// Expect the write
-	_expect_write(me, fd, 0);
-	_expect(me, E_WAIT);
-}
-
-static void test_zeroed_data_counts_as_dirty(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-
-	int fd = 17;   // arbitrary key
-	struct block *b;
-
-	// No read
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
-	bcache_put(b);
-
-	// Expect the write
-	_expect_write(me, fd, 0);
-	_expect(me, E_WAIT);
-}
-
-static void test_flush_waits_for_all_dirty(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-
-	const unsigned count = 16;
-	int fd = 17;   // arbitrary key
-	unsigned i;
-	struct block *b;
-
-	for (i = 0; i < count; i++) {
-		if (i % 2) {
-			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b));
-		} else {
-			_expect_read(me, fd, i);
-			_expect(me, E_WAIT);
-			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
-		}
-		bcache_put(b);
-	}
-
-	for (i = 0; i < count; i++) {
-		if (i % 2)
-			_expect_write(me, fd, i);
-	}
-
-	for (i = 0; i < count; i++) {
-		if (i % 2)
-			_expect(me, E_WAIT);
-	}
-
-	bcache_flush(cache);
-	_no_outstanding_expectations(me);
-}
-
-static void test_multiple_files(void * context)
-{
-	static int _fds[] = {1, 128, 345, 678, 890};
-
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	unsigned i;
-
-	for (i = 0; i < DM_ARRAY_SIZE(_fds); i++) {
-		_expect_read(me, _fds[i], 0);
-		_expect(me, E_WAIT);
-
-		T_ASSERT(bcache_get(cache, _fds[i], 0, 0, &b));
-		bcache_put(b);
-	}
-}
-
-// Tests to be written
-// Open multiple files and prove the blocks are coming from the correct file
-// show invalidate works
-// show invalidate_fd works
-// show writeback is working
-// check zeroing
-
-struct test_details {
-	const char *path;
-	const char *desc;
-	void (*fn)(void *);
-	void *(*fixture_init)(void);
-	void (*fixture_exit)(void *);
-};
-
-#define PATH "device/bcache/"
-#define TEST(path, name, fn) {PATH path, name, fn, NULL, NULL}
-#define TEST_S(path, name, fn) {PATH path, name, fn, _small_fixture_init, _small_fixture_exit}
-#define TEST_L(path, name, fn) {PATH path, name, fn, _large_fixture_init, _large_fixture_exit}
-
-int main(int argc, char **argv)
-{
-	static struct test_details _tests[] = {
-		TEST("create-destroy", "simple create/destroy", test_create),
-		TEST("cache-blocks-positive", "nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive),
-		TEST("block-size-positive", "block size must be positive", test_block_size_must_be_positive),
-		TEST("block-size-multiple-page", "block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size),
-		TEST_S("get-reads", "bcache_get() triggers read", test_get_triggers_read),
-		TEST_S("reads-cached", "repeated reads are cached", test_repeated_reads_are_cached),
-		TEST_S("blocks-get-evicted", "block get evicted with many reads", test_block_gets_evicted_with_many_reads),
-		TEST_S("prefetch-reads", "prefetch issues a read", test_prefetch_issues_a_read),
-		TEST_S("prefetch-never-waits", "too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait),
-		TEST_S("writeback-occurs", "dirty data gets written back", test_dirty_data_gets_written_back),
-		TEST_S("zero-flag-dirties", "zeroed data counts as dirty", test_zeroed_data_counts_as_dirty),
-		TEST_L("flush waits for all dirty", "flush waits for all dirty", test_flush_waits_for_all_dirty),
-		TEST_S("read-multiple-files", "read from multiple files", test_multiple_files),
-	};
-
-	// We have to declare these as volatile because of the setjmp()
-	volatile unsigned i = 0, passed = 0;
-
-	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
-		void *fixture;
-		struct test_details *t = _tests + i;
-		fprintf(stderr, "[RUN    ] %s\n", t->path);
-
-		if (setjmp(_test_k))
-			fprintf(stderr, "[   FAIL] %s\n", t->path);
-		else {
-			if (t->fixture_init)
-				fixture = t->fixture_init();
-			else
-				fixture = NULL;
-
-			t->fn(fixture);
-
-			if (t->fixture_exit)
-				t->fixture_exit(fixture);
-
-			passed++;
-			fprintf(stderr, "[     OK] %s\n", t->path);
-		}
-	}
-
-	fprintf(stderr, "\n%u/%lu tests passed\n", passed, DM_ARRAY_SIZE(_tests));
-
-	return 0;
-}
diff --git a/test/unit/bitset_t.c b/test/unit/bitset_t.c
deleted file mode 100644
index dadb9ec..0000000
--- a/test/unit/bitset_t.c
+++ /dev/null
@@ -1,129 +0,0 @@
-/*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-
-enum {
-        NR_BITS = 137
-};
-
-static struct dm_pool *mem;
-
-int bitset_init(void) {
-	mem = dm_pool_create("bitset test", 1024);
-	return mem == NULL;
-}
-
-int bitset_fini(void) {
-	dm_pool_destroy(mem);
-	return 0;
-}
-
-static void test_get_next(void)
-{
-        int i, j, last = 0, first;
-        dm_bitset_t bs = dm_bitset_create(mem, NR_BITS);
-
-        for (i = 0; i < NR_BITS; i++)
-                CU_ASSERT(!dm_bit(bs, i));
-
-        for (i = 0, j = 1; i < NR_BITS; i += j, j++)
-                dm_bit_set(bs, i);
-
-        first = 1;
-        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
-                if (first) {
-                        last = dm_bit_get_first(bs);
-                        first = 0;
-                } else
-                        last = dm_bit_get_next(bs, last);
-
-                CU_ASSERT(last == i);
-        }
-
-        CU_ASSERT(dm_bit_get_next(bs, last) == -1);
-}
-
-static void bit_flip(dm_bitset_t bs, int bit)
-{
-        int old = dm_bit(bs, bit);
-        if (old)
-                dm_bit_clear(bs, bit);
-        else
-                dm_bit_set(bs, bit);
-}
-
-static void test_equal(void)
-{
-        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
-        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
-
-        int i, j;
-        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
-                dm_bit_set(bs1, i);
-                dm_bit_set(bs2, i);
-        }
-
-        CU_ASSERT(dm_bitset_equal(bs1, bs2));
-        CU_ASSERT(dm_bitset_equal(bs2, bs1));
-
-        for (i = 0; i < NR_BITS; i++) {
-                bit_flip(bs1, i);
-                CU_ASSERT(!dm_bitset_equal(bs1, bs2));
-                CU_ASSERT(!dm_bitset_equal(bs2, bs1));
-
-                CU_ASSERT(dm_bitset_equal(bs1, bs1)); /* comparing with self */
-                bit_flip(bs1, i);
-        }
-}
-
-static void test_and(void)
-{
-        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
-        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
-        dm_bitset_t bs3 = dm_bitset_create(mem, NR_BITS);
-
-        int i, j;
-        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
-                dm_bit_set(bs1, i);
-                dm_bit_set(bs2, i);
-        }
-
-        dm_bit_and(bs3, bs1, bs2);
-
-        CU_ASSERT(dm_bitset_equal(bs1, bs2));
-        CU_ASSERT(dm_bitset_equal(bs1, bs3));
-        CU_ASSERT(dm_bitset_equal(bs2, bs3));
-
-        dm_bit_clear_all(bs1);
-        dm_bit_clear_all(bs2);
-
-        for (i = 0; i < NR_BITS; i++) {
-                if (i % 2)
-                        dm_bit_set(bs1, i);
-                else
-                        dm_bit_set(bs2, i);
-        }
-
-        dm_bit_and(bs3, bs1, bs2);
-        for (i = 0; i < NR_BITS; i++)
-                CU_ASSERT(!dm_bit(bs3, i));
-}
-
-CU_TestInfo bitset_list[] = {
-	{ (char*)"get_next", test_get_next },
-	{ (char*)"equal", test_equal },
-	{ (char*)"and", test_and },
-	CU_TEST_INFO_NULL
-};
diff --git a/test/unit/config_t.c b/test/unit/config_t.c
deleted file mode 100644
index 342667e..0000000
--- a/test/unit/config_t.c
+++ /dev/null
@@ -1,152 +0,0 @@
-/*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-
-static struct dm_pool *mem;
-
-int config_init(void) {
-	mem = dm_pool_create("config test", 1024);
-	return mem == NULL;
-}
-
-int config_fini(void) {
-	dm_pool_destroy(mem);
-	return 0;
-}
-
-static const char *conf =
-	"id = \"yada-yada\"\n"
-	"seqno = 15\n"
-	"status = [\"READ\", \"WRITE\"]\n"
-	"flags = []\n"
-	"extent_size = 8192\n"
-	"physical_volumes {\n"
-	"    pv0 {\n"
-	"        id = \"abcd-efgh\"\n"
-	"    }\n"
-	"    pv1 {\n"
-	"        id = \"bbcd-efgh\"\n"
-	"    }\n"
-	"    pv2 {\n"
-	"        id = \"cbcd-efgh\"\n"
-	"    }\n"
-	"}\n";
-
-static const char *overlay =
-	"id = \"yoda-soda\"\n"
-	"flags = [\"FOO\"]\n"
-	"physical_volumes {\n"
-	"    pv1 {\n"
-	"        id = \"hgfe-dcba\"\n"
-	"    }\n"
-	"    pv3 {\n"
-	"        id = \"dbcd-efgh\"\n"
-	"    }\n"
-	"}\n";
-
-static void test_parse(void)
-{
-	struct dm_config_tree *tree = dm_config_from_string(conf);
-	const struct dm_config_value *value;
-
-	CU_ASSERT((long) tree);
-	CU_ASSERT(dm_config_has_node(tree->root, "id"));
-	CU_ASSERT(dm_config_has_node(tree->root, "physical_volumes"));
-	CU_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0"));
-	CU_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0/id"));
-
-	CU_ASSERT(!strcmp(dm_config_find_str(tree->root, "id", "foo"), "yada-yada"));
-	CU_ASSERT(!strcmp(dm_config_find_str(tree->root, "idt", "foo"), "foo"));
-
-	CU_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/bb", "foo"), "foo"));
-	CU_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
-
-	CU_ASSERT(!dm_config_get_uint32(tree->root, "id", NULL));
-	CU_ASSERT(dm_config_get_uint32(tree->root, "extent_size", NULL));
-
-	/* FIXME: Currently everything parses as a list, even if it's not */
-	// CU_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
-	// CU_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
-
-	CU_ASSERT(dm_config_get_list(tree->root, "flags", &value));
-	CU_ASSERT(value->next == NULL); /* an empty list */
-	CU_ASSERT(dm_config_get_list(tree->root, "status", &value));
-	CU_ASSERT(value->next != NULL); /* a non-empty list */
-
-	dm_config_destroy(tree);
-}
-
-static void test_clone(void)
-{
-	struct dm_config_tree *tree = dm_config_from_string(conf);
-	struct dm_config_node *n = dm_config_clone_node(tree, tree->root, 1);
-	const struct dm_config_value *value;
-
-	/* Check that the nodes are actually distinct. */
-	CU_ASSERT(n != tree->root);
-	CU_ASSERT(n->sib != tree->root->sib);
-	CU_ASSERT(dm_config_find_node(n, "physical_volumes") != NULL);
-	CU_ASSERT(dm_config_find_node(tree->root, "physical_volumes") != NULL);
-	CU_ASSERT(dm_config_find_node(n, "physical_volumes") != dm_config_find_node(tree->root, "physical_volumes"));
-
-	CU_ASSERT(dm_config_has_node(n, "id"));
-	CU_ASSERT(dm_config_has_node(n, "physical_volumes"));
-	CU_ASSERT(dm_config_has_node(n, "physical_volumes/pv0"));
-	CU_ASSERT(dm_config_has_node(n, "physical_volumes/pv0/id"));
-
-	CU_ASSERT(!strcmp(dm_config_find_str(n, "id", "foo"), "yada-yada"));
-	CU_ASSERT(!strcmp(dm_config_find_str(n, "idt", "foo"), "foo"));
-
-	CU_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/bb", "foo"), "foo"));
-	CU_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
-
-	CU_ASSERT(!dm_config_get_uint32(n, "id", NULL));
-	CU_ASSERT(dm_config_get_uint32(n, "extent_size", NULL));
-
-	/* FIXME: Currently everything parses as a list, even if it's not */
-	// CU_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
-	// CU_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
-
-	CU_ASSERT(dm_config_get_list(n, "flags", &value));
-	CU_ASSERT(value->next == NULL); /* an empty list */
-	CU_ASSERT(dm_config_get_list(n, "status", &value));
-	CU_ASSERT(value->next != NULL); /* a non-empty list */
-
-	dm_config_destroy(tree);
-}
-
-static void test_cascade(void)
-{
-	struct dm_config_tree *t1 = dm_config_from_string(conf),
-		              *t2 = dm_config_from_string(overlay),
-		              *tree = dm_config_insert_cascaded_tree(t2, t1);
-
-	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "id", "foo"), "yoda-soda"));
-	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "idt", "foo"), "foo"));
-
-	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv0/bb", "foo"), "foo"));
-	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv1/id", "foo"), "hgfe-dcba"));
-	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv3/id", "foo"), "dbcd-efgh"));
-
-	dm_config_destroy(t1);
-	dm_config_destroy(t2);
-}
-
-CU_TestInfo config_list[] = {
-	{ (char*)"parse", test_parse },
-	{ (char*)"clone", test_clone },
-	{ (char*)"cascade", test_cascade },
-	CU_TEST_INFO_NULL
-};
diff --git a/test/unit/dmlist_t.c b/test/unit/dmlist_t.c
deleted file mode 100644
index f582e83..0000000
--- a/test/unit/dmlist_t.c
+++ /dev/null
@@ -1,49 +0,0 @@
-/*
- * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-
-int dmlist_init(void)
-{
-	return 0;
-}
-
-int dmlist_fini(void)
-{
-	return 0;
-}
-
-static void test_dmlist_splice(void)
-{
-	struct dm_list a[10];
-	struct dm_list list1;
-	struct dm_list list2;
-	unsigned i;
-
-	dm_list_init(&list1);
-	dm_list_init(&list2);
-
-	for (i = 0; i < DM_ARRAY_SIZE@; i++)
-		dm_list_add(&list1, &a[i]);
-
-	dm_list_splice(&list2, &list1);
-	CU_ASSERT_EQUAL(dm_list_size(&list1), 0);
-	CU_ASSERT_EQUAL(dm_list_size(&list2), 10);
-}
-
-CU_TestInfo dmlist_list[] = {
-	{ (char*)"dmlist_splice", test_dmlist_splice },
-	//{ (char*)"dmlist", test_strncpy },
-	CU_TEST_INFO_NULL
-};
diff --git a/test/unit/dmstatus_t.c b/test/unit/dmstatus_t.c
deleted file mode 100644
index 00af56d..0000000
--- a/test/unit/dmstatus_t.c
+++ /dev/null
@@ -1,72 +0,0 @@
-/*
- * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-
-static struct dm_pool *_mem;
-
-int dmstatus_init(void)
-{
-	_mem = dm_pool_create("dmstatus test", 1024);
-	return (_mem == NULL);
-}
-
-int dmstatus_fini(void)
-{
-	dm_pool_destroy(_mem);
-	return 0;
-}
-
-static void _test_mirror_status(void)
-{
-	struct dm_status_mirror *s = NULL;
-
-	CU_ASSERT(dm_get_status_mirror(_mem,
-				       "2 253:1 253:2 80/81 1 AD 3 disk 253:0 A",
-				       &s));
-	if (s) {
-		CU_ASSERT_EQUAL(s->total_regions, 81);
-		CU_ASSERT_EQUAL(s->insync_regions, 80);
-		CU_ASSERT_EQUAL(s->dev_count, 2);
-		CU_ASSERT_EQUAL(s->devs[0].health, 'A');
-		CU_ASSERT_EQUAL(s->devs[0].major, 253);
-		CU_ASSERT_EQUAL(s->devs[0].minor, 1);
-		CU_ASSERT_EQUAL(s->devs[1].health, 'D');
-		CU_ASSERT_EQUAL(s->devs[1].major, 253);
-		CU_ASSERT_EQUAL(s->devs[1].minor, 2);
-		CU_ASSERT_EQUAL(s->log_count, 1);
-		CU_ASSERT_EQUAL(s->logs[0].major, 253);
-		CU_ASSERT_EQUAL(s->logs[0].minor, 0);
-		CU_ASSERT_EQUAL(s->logs[0].health, 'A');
-		CU_ASSERT(!strcmp(s->log_type, "disk"));
-	}
-
-	CU_ASSERT(dm_get_status_mirror(_mem,
-				       "4 253:1 253:2 253:3 253:4 10/10 1 ADFF 1 core",
-				       &s));
-	if (s) {
-		CU_ASSERT_EQUAL(s->total_regions, 10);
-		CU_ASSERT_EQUAL(s->insync_regions, 10);
-		CU_ASSERT_EQUAL(s->dev_count, 4);
-		CU_ASSERT_EQUAL(s->devs[3].minor, 4);
-		CU_ASSERT_EQUAL(s->devs[3].health, 'F');
-		CU_ASSERT_EQUAL(s->log_count, 0);
-		CU_ASSERT(!strcmp(s->log_type, "core"));
-	}
-}
-
-CU_TestInfo dmstatus_list[] = {
-	{ (char*)"mirror_status", _test_mirror_status },
-	CU_TEST_INFO_NULL
-};
diff --git a/test/unit/matcher_data.h b/test/unit/matcher_data.h
deleted file mode 100644
index 97dbbfe..0000000
--- a/test/unit/matcher_data.h
+++ /dev/null
@@ -1,1013 +0,0 @@
-struct check_item {
-	const char *str;
-	int expected;
-};
-
-static const char *dev_patterns[] = {
-	"loop/[0-9]+",
-	"hd[a-d][0-5]+",
-	NULL
-};
-
-static const char *nonprint_patterns[] = {
-	"foo\x80" "bar",
-	"foo\xc2" "b",
-	"\x80",
-	NULL
-};
-
-static const struct check_item nonprint[] = {
-	{ "foo\x2e" "bar", 0 },
-	{ "foo\x80" "bar", 3 },
-	{ "foo\xc2" "b", 2 },
-	{ "\x80", 3 },
-	{ NULL, 0 }
-};
-
-static const char *random_patterns[] = {
-	"(((a?)(([Ub]*)|z))((([qr]|X)+)([Qn]*)))+",
-	"[HZejtuw]*",
-	"((B|s)*)|(((([Fv]l)(N+))(([el]|C)(tJ)))?)",
-	"((([Ma]?)|(t*))*)|((([cm]E)|(M?))|(([BE][EV])|([Qj][Mh])))",
-	"(((([bw]*)|([IO]*))((zK)*))|(((pU)|(i|q))|((z?)|([HL]?))))*",
-	"((([Pt]?)|[Tr])?)((Hq)*)",
-	"[HOXcfgikosvwxz]",
-	"[BCEFGHNPTUWfjlprsy]",
-	"((((aD)*)|([Xo]+))+)(([HKn](([Eq]|[JQ])(I*)))*)",
-	"([LNWYeghv]|e)*",
-	"(((y(L*))*)|((([EP]+)(W+))*))*",
-	"U*",
-	"((((R+)(W|[Qr]))|([py]+))+)([LM]*)",
-	"(([DOjx](D(b?)))|([Ke]*))*",
-	"((([ls](c|[FT]))*)([JS]*))*",
-	"((l?)|(([Gz]+)|(D*)))*",
-	"[ABgjn]",
-	"(((q|[dg])?)|([Uk]*))((([Fl]?)|([Ry]+))|(([IR]|c)|(T?)))",
-	"((([an]|P)|[Jw])((a*)|(m*)))*",
-	"((((R[ht])(h+))?)|(([pz](n?))+))+",
-	"(((([Dc]b)([Sp][Ii]))|((k|F)*))|[Uiovz])*",
-	"[Res]*",
-	"[Zl]|a",
-	"^[ANZdf]$",
-	"[En]|(((Q+)(U+))([pt]*))",
-	"[ADEIMQUWXZhklrsvz]",
-	"(((S(y*))*)|(j*))*",
-	"n*",
-	"[NUau]*",
-	"((((Z*)(D|[Nd]))|(([np]|B)+))|(([Xy][Fi])*))+",
-	"((([EZ]?)|(d[HR]))*)((([Hg]|q)(P+))*)",
-	"q",
-	"((m*)|(p|B))|((((x?)|(t+))(([Sb][PX])(O|[HM])))+)",
-	"((((A*)(z[RS]))*)|(((z+)(Q*))+))*",
-	"(((M*)([Uu]*))+)|[Uk]",
-	"[imv]",
-	"[GLSchtw](([Yw]((F[Dd])|([Tw]+)))?)",
-	"([MOZj]*)(S|[Wknr])",
-	"((G|q)*)[BHKN]",
-	"((((NW)|([Ao]?))|((l|[UV])+))+)|((i|(z*))*)",
-	"((((Z+)|([IR]?))|(L*))|([JKQ]+))+",
-	"([Bdin](S*))+",
-	"[HLNSTp]*",
-	"(((J*)([Bq]|[Yu]))*)|([Kv]*)",
-	"(((([BJ]|[Zy])(wI))*)(y*))+",
-	"(((hF)+)|(H*))*",
-	"((([QU][Pj])([GQ]?))+)|[PWo]",
-	"(((([cq][BX])?)|((f[DI])*))*)(([GM]*)[SVYr])",
-	"(([Zt]*)|((qx)|(([BV]+)(f?))))*",
-	"[ILWYhsx]*",
-	"(([Uy]*)|[sv])|([NSc]*)",
-	"((c*)|([JUfhy]?))+",
-	"(((q*)([So]*))(((g[jq])(j?))+))*",
-	"((b+)|(((T+)([fw]T))?))*",
-	"((([DS]?)|([Th]|u))(Q*))*",
-	"[FKLX]|((([fw](L?))(([gq]*)|(O?)))?)",
-	"((([HZ]+)u)*)|[APWijn]",
-	"(e*)|(((v?)|((J+)(Hb)))?)",
-	"(e|((w+)f))*",
-	"[BEHKPQVdelnqy]",
-	"((((B|N)(s*))|[Rr])(((g?)|([rv]+))+))+",
-	"(((s*)|(K*))([AP]G))*",
-	"[CELTp]",
-	"(([Fq]?)|([Al]+))*",
-	"((((r?)|(y[jx]))|([mp]*))+)|((B(S*))*)",
-	"((([Eq]+)|(Y[ds]))|(x|(i|[Ku])))[IJNrvy]",
-	"((([NO]*)[Ix])+)([Jenq]+)",
-	"(((([HP]*)(j|y))*)[Ylqvy])*",
-	"[PTv]+",
-	"[AINSZhpx]|([EOYZ]*)",
-	"([ABCFQv]*)((([Zx]|h)+)|([ej]*))",
-	"((([pr]*)|(([Dq]|p)|(H?)))?)([NRUXmoq]*)",
-	"(([er]*)|([mx]*))(((nV)([am]?))+)",
-	"[BHPRlpu]",
-	"(((([Ah]|[tx])|(e|[uy]))?)((([fl]+)([Vz]|v))*))*",
-	"[AGdm]",
-	"(((K*)^(O*)$)|(B?))*",
-	"((([Ks]|[Ka])*)|([FSTab]?))?",
-	"(([kw]+)[ei])(([Hy]*)(([Mc]*)|(G|f)))",
-	"((((e*)|(Zf))|(R|[nq]))((([Jz]v)([Rj]+))+))*",
-	"(((a?)|(e?))(([Uc]*)(S+)))*",
-	"((((E+)([MZ]?))+)|(((s|[Az])|z)*))?",
-	"((((i[MO])*)|((LH)*))|(((BA)|([AI]+))|[Ug]))*",
-	"[EGHILcho]*",
-	"(((Z[vw])?)((z|g)+))(((H|U)([iv]Q))|([qw]?))",
-	"(([ehmr]|((L[Uw])*))+)((a+)I)",
-	"[EKNSWYagj](((v|[TX])|([Uk]+))*)",
-	"(((R[Mo])|(O*))|([Fm]|([qw]*)))((m*)|((S|[Ki])?))",
-	"((((kP)|c)?)((([do]+)|([Gi]?))*))*",
-	"((^(B|W)$|([Ww]+))([no]*))|((([iv]?)|(M*))|((x|L)?))",
-	"[AEGPRSbcfhsy]",
-	"[Wbcf]|((([MO]?)|([NT]|m))(([Oo]?)([Wg]*)))",
-	"(((YZ)*)[PQVei])*",
-	"[GJKYt][AEGWdegmnt]",
-	"^[CDEGJKNUVYZagkv]$",
-	"([DPWbx]*)|(((q|B)|(P|u))((M[Bq])*))",
-	"[FHIJRTVYZdiorsuvz]*",
-	"([MWoqvz]*)|^(l*)",
-	"(((I|[Rx])*)((X[Mf])([Xa]L)))([Ha]|([HY]*))",
-	"(((l|[Sd])*)((([Ix]+)|([XY]?))(Z*)))+",
-	NULL
-};
-
-struct check_item devices[] = {
-	{ "/dev", 0 },
-	{ "/dev/.devfsd", 0 },
-	{ "/dev/cpu", 0 },
-	{ "/dev/cpu/mtrr", 0 },
-	{ "/dev/netlink", 0 },
-	{ "/dev/netlink/route", 0 },
-	{ "/dev/netlink/skip", 0 },
-	{ "/dev/netlink/USERSOCK", 0 },
-	{ "/dev/netlink/fwmonitor", 0 },
-	{ "/dev/netlink/ARPD", 0 },
-	{ "/dev/netlink/ROUTE6", 0 },
-	{ "/dev/netlink/IP6_FW", 0 },
-	{ "/dev/netlink/tap0", 0 },
-	{ "/dev/netlink/tap1", 0 },
-	{ "/dev/netlink/tap2", 0 },
-	{ "/dev/netlink/tap3", 0 },
-	{ "/dev/netlink/tap4", 0 },
-	{ "/dev/netlink/tap5", 0 },
-	{ "/dev/netlink/tap6", 0 },
-	{ "/dev/netlink/tap7", 0 },
-	{ "/dev/netlink/tap8", 0 },
-	{ "/dev/netlink/tap9", 0 },
-	{ "/dev/netlink/tap10", 0 },
-	{ "/dev/netlink/tap11", 0 },
-	{ "/dev/netlink/tap12", 0 },
-	{ "/dev/netlink/tap13", 0 },
-	{ "/dev/netlink/tap14", 0 },
-	{ "/dev/netlink/tap15", 0 },
-	{ "/dev/shm", 0 },
-	{ "/dev/mem", 0 },
-	{ "/dev/kmem", 0 },
-	{ "/dev/null", 0 },
-	{ "/dev/port", 0 },
-	{ "/dev/zero", 0 },
-	{ "/dev/full", 0 },
-	{ "/dev/random", 0 },
-	{ "/dev/urandom", 0 },
-	{ "/dev/tty", 0 },
-	{ "/dev/console", 0 },
-	{ "/dev/vc", 0 },
-	{ "/dev/vc/1", 0 },
-	{ "/dev/vc/2", 0 },
-	{ "/dev/vc/3", 0 },
-	{ "/dev/vc/4", 0 },
-	{ "/dev/vc/5", 0 },
-	{ "/dev/vc/6", 0 },
-	{ "/dev/vc/7", 0 },
-	{ "/dev/vc/8", 0 },
-	{ "/dev/vc/9", 0 },
-	{ "/dev/vc/10", 0 },
-	{ "/dev/vc/11", 0 },
-	{ "/dev/vc/12", 0 },
-	{ "/dev/vc/13", 0 },
-	{ "/dev/vc/14", 0 },
-	{ "/dev/vc/15", 0 },
-	{ "/dev/vc/16", 0 },
-	{ "/dev/vc/17", 0 },
-	{ "/dev/vc/18", 0 },
-	{ "/dev/vc/19", 0 },
-	{ "/dev/vc/20", 0 },
-	{ "/dev/vc/21", 0 },
-	{ "/dev/vc/22", 0 },
-	{ "/dev/vc/23", 0 },
-	{ "/dev/vc/24", 0 },
-	{ "/dev/vc/25", 0 },
-	{ "/dev/vc/26", 0 },
-	{ "/dev/vc/27", 0 },
-	{ "/dev/vc/28", 0 },
-	{ "/dev/vc/29", 0 },
-	{ "/dev/vc/30", 0 },
-	{ "/dev/vc/31", 0 },
-	{ "/dev/vc/32", 0 },
-	{ "/dev/vc/33", 0 },
-	{ "/dev/vc/34", 0 },
-	{ "/dev/vc/35", 0 },
-	{ "/dev/vc/36", 0 },
-	{ "/dev/vc/37", 0 },
-	{ "/dev/vc/38", 0 },
-	{ "/dev/vc/39", 0 },
-	{ "/dev/vc/40", 0 },
-	{ "/dev/vc/41", 0 },
-	{ "/dev/vc/42", 0 },
-	{ "/dev/vc/43", 0 },
-	{ "/dev/vc/44", 0 },
-	{ "/dev/vc/45", 0 },
-	{ "/dev/vc/46", 0 },
-	{ "/dev/vc/47", 0 },
-	{ "/dev/vc/48", 0 },
-	{ "/dev/vc/49", 0 },
-	{ "/dev/vc/50", 0 },
-	{ "/dev/vc/51", 0 },
-	{ "/dev/vc/52", 0 },
-	{ "/dev/vc/53", 0 },
-	{ "/dev/vc/54", 0 },
-	{ "/dev/vc/55", 0 },
-	{ "/dev/vc/56", 0 },
-	{ "/dev/vc/57", 0 },
-	{ "/dev/vc/58", 0 },
-	{ "/dev/vc/59", 0 },
-	{ "/dev/vc/60", 0 },
-	{ "/dev/vc/61", 0 },
-	{ "/dev/vc/62", 0 },
-	{ "/dev/vc/63", 0 },
-	{ "/dev/vc/0", 0 },
-	{ "/dev/ptmx", 0 },
-	{ "/dev/misc", 0 },
-	{ "/dev/misc/psaux", 0 },
-	{ "/dev/pty", 0 },
-	{ "/dev/pty/m0", 0 },
-	{ "/dev/pty/m1", 0 },
-	{ "/dev/pty/m2", 0 },
-	{ "/dev/pty/m3", 0 },
-	{ "/dev/pty/m4", 0 },
-	{ "/dev/pty/m5", 0 },
-	{ "/dev/pty/m6", 0 },
-	{ "/dev/pty/m7", 0 },
-	{ "/dev/pty/m8", 0 },
-	{ "/dev/pty/m9", 0 },
-	{ "/dev/pty/m10", 0 },
-	{ "/dev/pty/m11", 0 },
-	{ "/dev/pty/m12", 0 },
-	{ "/dev/pty/m13", 0 },
-	{ "/dev/pty/m14", 0 },
-	{ "/dev/pty/m15", 0 },
-	{ "/dev/pty/m16", 0 },
-	{ "/dev/pty/m17", 0 },
-	{ "/dev/pty/m18", 0 },
-	{ "/dev/pty/m19", 0 },
-	{ "/dev/pty/m20", 0 },
-	{ "/dev/pty/m21", 0 },
-	{ "/dev/pty/m22", 0 },
-	{ "/dev/pty/m23", 0 },
-	{ "/dev/pty/m24", 0 },
-	{ "/dev/pty/m25", 0 },
-	{ "/dev/pty/m26", 0 },
-	{ "/dev/pty/m27", 0 },
-	{ "/dev/pty/m28", 0 },
-	{ "/dev/pty/m29", 0 },
-	{ "/dev/pty/m30", 0 },
-	{ "/dev/pty/m31", 0 },
-	{ "/dev/pty/m32", 0 },
-	{ "/dev/pty/m33", 0 },
-	{ "/dev/pty/m34", 0 },
-	{ "/dev/pty/m35", 0 },
-	{ "/dev/pty/m36", 0 },
-	{ "/dev/pty/m37", 0 },
-	{ "/dev/pty/m38", 0 },
-	{ "/dev/pty/m39", 0 },
-	{ "/dev/pty/m40", 0 },
-	{ "/dev/pty/m41", 0 },
-	{ "/dev/pty/m42", 0 },
-	{ "/dev/pty/m43", 0 },
-	{ "/dev/pty/m44", 0 },
-	{ "/dev/pty/m45", 0 },
-	{ "/dev/pty/m46", 0 },
-	{ "/dev/pty/m47", 0 },
-	{ "/dev/pty/m48", 0 },
-	{ "/dev/pty/m49", 0 },
-	{ "/dev/pty/m50", 0 },
-	{ "/dev/pty/m51", 0 },
-	{ "/dev/pty/m52", 0 },
-	{ "/dev/pty/m53", 0 },
-	{ "/dev/pty/m54", 0 },
-	{ "/dev/pty/m55", 0 },
-	{ "/dev/pty/m56", 0 },
-	{ "/dev/pty/m57", 0 },
-	{ "/dev/pty/m58", 0 },
-	{ "/dev/pty/m59", 0 },
-	{ "/dev/pty/m60", 0 },
-	{ "/dev/pty/m61", 0 },
-	{ "/dev/pty/m62", 0 },
-	{ "/dev/pty/m63", 0 },
-	{ "/dev/pty/m64", 0 },
-	{ "/dev/pty/m65", 0 },
-	{ "/dev/pty/m66", 0 },
-	{ "/dev/pty/m67", 0 },
-	{ "/dev/pty/m68", 0 },
-	{ "/dev/pty/m69", 0 },
-	{ "/dev/pty/m70", 0 },
-	{ "/dev/pty/m71", 0 },
-	{ "/dev/pty/m72", 0 },
-	{ "/dev/pty/m73", 0 },
-	{ "/dev/pty/m74", 0 },
-	{ "/dev/pty/m75", 0 },
-	{ "/dev/pty/m76", 0 },
-	{ "/dev/pty/m77", 0 },
-	{ "/dev/pty/m78", 0 },
-	{ "/dev/pty/m79", 0 },
-	{ "/dev/pty/m80", 0 },
-	{ "/dev/pty/m81", 0 },
-	{ "/dev/pty/m82", 0 },
-	{ "/dev/pty/m83", 0 },
-	{ "/dev/pty/m84", 0 },
-	{ "/dev/pty/m85", 0 },
-	{ "/dev/pty/m86", 0 },
-	{ "/dev/pty/m87", 0 },
-	{ "/dev/pty/m88", 0 },
-	{ "/dev/pty/m89", 0 },
-	{ "/dev/pty/m90", 0 },
-	{ "/dev/pty/m91", 0 },
-	{ "/dev/pty/m92", 0 },
-	{ "/dev/pty/m93", 0 },
-	{ "/dev/pty/m94", 0 },
-	{ "/dev/pty/m95", 0 },
-	{ "/dev/pty/m96", 0 },
-	{ "/dev/pty/m97", 0 },
-	{ "/dev/pty/m98", 0 },
-	{ "/dev/pty/m99", 0 },
-	{ "/dev/pty/m100", 0 },
-	{ "/dev/pty/m101", 0 },
-	{ "/dev/pty/m102", 0 },
-	{ "/dev/pty/m103", 0 },
-	{ "/dev/pty/m104", 0 },
-	{ "/dev/pty/m105", 0 },
-	{ "/dev/pty/m106", 0 },
-	{ "/dev/pty/m107", 0 },
-	{ "/dev/pty/m108", 0 },
-	{ "/dev/pty/m109", 0 },
-	{ "/dev/pty/m110", 0 },
-	{ "/dev/pty/m111", 0 },
-	{ "/dev/pty/m112", 0 },
-	{ "/dev/pty/m113", 0 },
-	{ "/dev/pty/m114", 0 },
-	{ "/dev/pty/m115", 0 },
-	{ "/dev/pty/m116", 0 },
-	{ "/dev/pty/m117", 0 },
-	{ "/dev/pty/m118", 0 },
-	{ "/dev/pty/m119", 0 },
-	{ "/dev/pty/m120", 0 },
-	{ "/dev/pty/m121", 0 },
-	{ "/dev/pty/m122", 0 },
-	{ "/dev/pty/m123", 0 },
-	{ "/dev/pty/m124", 0 },
-	{ "/dev/pty/m125", 0 },
-	{ "/dev/pty/m126", 0 },
-	{ "/dev/pty/m127", 0 },
-	{ "/dev/pty/m128", 0 },
-	{ "/dev/pty/m129", 0 },
-	{ "/dev/pty/m130", 0 },
-	{ "/dev/pty/m131", 0 },
-	{ "/dev/pty/m132", 0 },
-	{ "/dev/pty/m133", 0 },
-	{ "/dev/pty/m134", 0 },
-	{ "/dev/pty/m135", 0 },
-	{ "/dev/pty/m136", 0 },
-	{ "/dev/pty/m137", 0 },
-	{ "/dev/pty/m138", 0 },
-	{ "/dev/pty/m139", 0 },
-	{ "/dev/pty/m140", 0 },
-	{ "/dev/pty/m141", 0 },
-	{ "/dev/pty/m142", 0 },
-	{ "/dev/pty/m143", 0 },
-	{ "/dev/pty/m144", 0 },
-	{ "/dev/pty/m145", 0 },
-	{ "/dev/pty/m146", 0 },
-	{ "/dev/pty/m147", 0 },
-	{ "/dev/pty/m148", 0 },
-	{ "/dev/pty/m149", 0 },
-	{ "/dev/pty/m150", 0 },
-	{ "/dev/pty/m151", 0 },
-	{ "/dev/pty/m152", 0 },
-	{ "/dev/pty/m153", 0 },
-	{ "/dev/pty/m154", 0 },
-	{ "/dev/pty/m155", 0 },
-	{ "/dev/pty/m156", 0 },
-	{ "/dev/pty/m157", 0 },
-	{ "/dev/pty/m158", 0 },
-	{ "/dev/pty/m159", 0 },
-	{ "/dev/pty/m160", 0 },
-	{ "/dev/pty/m161", 0 },
-	{ "/dev/pty/m162", 0 },
-	{ "/dev/pty/m163", 0 },
-	{ "/dev/pty/m164", 0 },
-	{ "/dev/pty/m165", 0 },
-	{ "/dev/pty/m166", 0 },
-	{ "/dev/pty/m167", 0 },
-	{ "/dev/pty/m168", 0 },
-	{ "/dev/pty/m169", 0 },
-	{ "/dev/pty/m170", 0 },
-	{ "/dev/pty/m171", 0 },
-	{ "/dev/pty/m172", 0 },
-	{ "/dev/pty/m173", 0 },
-	{ "/dev/pty/m174", 0 },
-	{ "/dev/pty/m175", 0 },
-	{ "/dev/pty/m176", 0 },
-	{ "/dev/pty/m177", 0 },
-	{ "/dev/pty/m178", 0 },
-	{ "/dev/pty/m179", 0 },
-	{ "/dev/pty/m180", 0 },
-	{ "/dev/pty/m181", 0 },
-	{ "/dev/pty/m182", 0 },
-	{ "/dev/pty/m183", 0 },
-	{ "/dev/pty/m184", 0 },
-	{ "/dev/pty/m185", 0 },
-	{ "/dev/pty/m186", 0 },
-	{ "/dev/pty/m187", 0 },
-	{ "/dev/pty/m188", 0 },
-	{ "/dev/pty/m189", 0 },
-	{ "/dev/pty/m190", 0 },
-	{ "/dev/pty/m191", 0 },
-	{ "/dev/pty/m192", 0 },
-	{ "/dev/pty/m193", 0 },
-	{ "/dev/pty/m194", 0 },
-	{ "/dev/pty/m195", 0 },
-	{ "/dev/pty/m196", 0 },
-	{ "/dev/pty/m197", 0 },
-	{ "/dev/pty/m198", 0 },
-	{ "/dev/pty/m199", 0 },
-	{ "/dev/pty/m200", 0 },
-	{ "/dev/pty/m201", 0 },
-	{ "/dev/pty/m202", 0 },
-	{ "/dev/pty/m203", 0 },
-	{ "/dev/pty/m204", 0 },
-	{ "/dev/pty/m205", 0 },
-	{ "/dev/pty/m206", 0 },
-	{ "/dev/pty/m207", 0 },
-	{ "/dev/pty/m208", 0 },
-	{ "/dev/pty/m209", 0 },
-	{ "/dev/pty/m210", 0 },
-	{ "/dev/pty/m211", 0 },
-	{ "/dev/pty/m212", 0 },
-	{ "/dev/pty/m213", 0 },
-	{ "/dev/pty/m214", 0 },
-	{ "/dev/pty/m215", 0 },
-	{ "/dev/pty/m216", 0 },
-	{ "/dev/pty/m217", 0 },
-	{ "/dev/pty/m218", 0 },
-	{ "/dev/pty/m219", 0 },
-	{ "/dev/pty/m220", 0 },
-	{ "/dev/pty/m221", 0 },
-	{ "/dev/pty/m222", 0 },
-	{ "/dev/pty/m223", 0 },
-	{ "/dev/pty/m224", 0 },
-	{ "/dev/pty/m225", 0 },
-	{ "/dev/pty/m226", 0 },
-	{ "/dev/pty/m227", 0 },
-	{ "/dev/pty/m228", 0 },
-	{ "/dev/pty/m229", 0 },
-	{ "/dev/pty/m230", 0 },
-	{ "/dev/pty/m231", 0 },
-	{ "/dev/pty/m232", 0 },
-	{ "/dev/pty/m233", 0 },
-	{ "/dev/pty/m234", 0 },
-	{ "/dev/pty/m235", 0 },
-	{ "/dev/pty/m236", 0 },
-	{ "/dev/pty/m237", 0 },
-	{ "/dev/pty/m238", 0 },
-	{ "/dev/pty/m239", 0 },
-	{ "/dev/pty/m240", 0 },
-	{ "/dev/pty/m241", 0 },
-	{ "/dev/pty/m242", 0 },
-	{ "/dev/pty/m243", 0 },
-	{ "/dev/pty/m244", 0 },
-	{ "/dev/pty/m245", 0 },
-	{ "/dev/pty/m246", 0 },
-	{ "/dev/pty/m247", 0 },
-	{ "/dev/pty/m248", 0 },
-	{ "/dev/pty/m249", 0 },
-	{ "/dev/pty/m250", 0 },
-	{ "/dev/pty/m251", 0 },
-	{ "/dev/pty/m252", 0 },
-	{ "/dev/pty/m253", 0 },
-	{ "/dev/pty/m254", 0 },
-	{ "/dev/pty/m255", 0 },
-	{ "/dev/pts", 0 },
-	{ "/dev/pts/0", 0 },
-	{ "/dev/pts/1", 0 },
-	{ "/dev/pts/2", 0 },
-	{ "/dev/pts/3", 0 },
-	{ "/dev/pts/4", 0 },
-	{ "/dev/pts/5", 0 },
-	{ "/dev/pts/6", 0 },
-	{ "/dev/pts/7", 0 },
-	{ "/dev/vcc", 0 },
-	{ "/dev/vcc/0", 0 },
-	{ "/dev/vcc/a", 0 },
-	{ "/dev/vcc/1", 0 },
-	{ "/dev/vcc/a1", 0 },
-	{ "/dev/vcc/2", 0 },
-	{ "/dev/vcc/a2", 0 },
-	{ "/dev/vcc/3", 0 },
-	{ "/dev/vcc/a3", 0 },
-	{ "/dev/vcc/5", 0 },
-	{ "/dev/vcc/a5", 0 },
-	{ "/dev/vcc/4", 0 },
-	{ "/dev/vcc/a4", 0 },
-	{ "/dev/vcc/6", 0 },
-	{ "/dev/vcc/a6", 0 },
-	{ "/dev/vcc/7", 0 },
-	{ "/dev/vcc/a7", 0 },
-	{ "/dev/tts", 0 },
-	{ "/dev/tts/0", 0 },
-	{ "/dev/cua", 0 },
-	{ "/dev/cua/0", 0 },
-	{ "/dev/ide", 0 },
-	{ "/dev/ide/host0", 0 },
-	{ "/dev/ide/host0/bus0", 0 },
-	{ "/dev/ide/host0/bus0/target0", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/disc", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part1", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part2", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part3", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part4", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part5", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part6", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part7", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part8", 0 },
-	{ "/dev/ide/host0/bus0/target1", 0 },
-	{ "/dev/ide/host0/bus0/target1/lun0", 0 },
-	{ "/dev/ide/host0/bus0/target1/lun0/disc", 0 },
-	{ "/dev/ide/host0/bus0/target1/lun0/part1", 0 },
-	{ "/dev/ide/host0/bus1", 0 },
-	{ "/dev/ide/host0/bus1/target0", 0 },
-	{ "/dev/ide/host0/bus1/target0/lun0", 0 },
-	{ "/dev/ide/host0/bus1/target0/lun0/disc", 0 },
-	{ "/dev/ide/host0/bus1/target0/lun0/part1", 0 },
-	{ "/dev/ide/host0/bus1/target1", 0 },
-	{ "/dev/ide/host0/bus1/target1/lun0", 0 },
-	{ "/dev/discs", 0 },
-	{ "/dev/discs/disc0", 0 },
-	{ "/dev/discs/disc1", 0 },
-	{ "/dev/discs/disc2", 0 },
-	{ "/dev/floppy", 0 },
-	{ "/dev/floppy/0u1440", 0 },
-	{ "/dev/floppy/0u1680", 0 },
-	{ "/dev/floppy/0u1722", 0 },
-	{ "/dev/floppy/0u1743", 0 },
-	{ "/dev/floppy/0u1760", 0 },
-	{ "/dev/floppy/0u1920", 0 },
-	{ "/dev/floppy/0u1840", 0 },
-	{ "/dev/floppy/0u1600", 0 },
-	{ "/dev/floppy/0u360", 0 },
-	{ "/dev/floppy/0u720", 0 },
-	{ "/dev/floppy/0u820", 0 },
-	{ "/dev/floppy/0u830", 0 },
-	{ "/dev/floppy/0u1040", 0 },
-	{ "/dev/floppy/0u1120", 0 },
-	{ "/dev/floppy/0u800", 0 },
-	{ "/dev/floppy/0", 0 },
-	{ "/dev/loop", 0 },
-	{ "/dev/loop/0", 1 },
-	{ "/dev/loop/1", 1 },
-	{ "/dev/loop/2", 1 },
-	{ "/dev/loop/3", 1 },
-	{ "/dev/loop/4", 1 },
-	{ "/dev/loop/5", 1 },
-	{ "/dev/loop/6", 1 },
-	{ "/dev/loop/7", 1 },
-	{ "/dev/cdroms", 0 },
-	{ "/dev/sound", 0 },
-	{ "/dev/sound/dsp", 0 },
-	{ "/dev/sound/dsp1", 0 },
-	{ "/dev/sound/mixer", 0 },
-	{ "/dev/sound/midi", 0 },
-	{ "/dev/usb", 0 },
-	{ "/dev/root", 0 },
-	{ "/dev/initctl", 0 },
-	{ "/dev/xconsole", 0 },
-	{ "/dev/fd", 0 },
-	{ "/dev/stdin", 0 },
-	{ "/dev/stdout", 0 },
-	{ "/dev/stderr", 0 },
-	{ "/dev/route", 0 },
-	{ "/dev/skip", 0 },
-	{ "/dev/USERSOCK", 0 },
-	{ "/dev/fwmonitor", 0 },
-	{ "/dev/ARPD", 0 },
-	{ "/dev/ROUTE6", 0 },
-	{ "/dev/IP6_FW", 0 },
-	{ "/dev/tap0", 0 },
-	{ "/dev/tap1", 0 },
-	{ "/dev/tap2", 0 },
-	{ "/dev/tap3", 0 },
-	{ "/dev/tap4", 0 },
-	{ "/dev/tap5", 0 },
-	{ "/dev/tap6", 0 },
-	{ "/dev/tap7", 0 },
-	{ "/dev/tap8", 0 },
-	{ "/dev/tap9", 0 },
-	{ "/dev/tap10", 0 },
-	{ "/dev/tap11", 0 },
-	{ "/dev/tap12", 0 },
-	{ "/dev/tap13", 0 },
-	{ "/dev/tap14", 0 },
-	{ "/dev/tap15", 0 },
-	{ "/dev/tty1", 0 },
-	{ "/dev/tty2", 0 },
-	{ "/dev/tty3", 0 },
-	{ "/dev/tty4", 0 },
-	{ "/dev/tty5", 0 },
-	{ "/dev/tty6", 0 },
-	{ "/dev/tty7", 0 },
-	{ "/dev/tty8", 0 },
-	{ "/dev/tty9", 0 },
-	{ "/dev/tty10", 0 },
-	{ "/dev/tty11", 0 },
-	{ "/dev/tty12", 0 },
-	{ "/dev/tty13", 0 },
-	{ "/dev/tty14", 0 },
-	{ "/dev/tty15", 0 },
-	{ "/dev/tty16", 0 },
-	{ "/dev/tty17", 0 },
-	{ "/dev/tty18", 0 },
-	{ "/dev/tty19", 0 },
-	{ "/dev/tty20", 0 },
-	{ "/dev/tty21", 0 },
-	{ "/dev/tty22", 0 },
-	{ "/dev/tty23", 0 },
-	{ "/dev/tty24", 0 },
-	{ "/dev/tty25", 0 },
-	{ "/dev/tty26", 0 },
-	{ "/dev/tty27", 0 },
-	{ "/dev/tty28", 0 },
-	{ "/dev/tty29", 0 },
-	{ "/dev/tty30", 0 },
-	{ "/dev/tty31", 0 },
-	{ "/dev/tty32", 0 },
-	{ "/dev/tty33", 0 },
-	{ "/dev/tty34", 0 },
-	{ "/dev/tty35", 0 },
-	{ "/dev/tty36", 0 },
-	{ "/dev/tty37", 0 },
-	{ "/dev/tty38", 0 },
-	{ "/dev/tty39", 0 },
-	{ "/dev/tty40", 0 },
-	{ "/dev/tty41", 0 },
-	{ "/dev/tty42", 0 },
-	{ "/dev/tty43", 0 },
-	{ "/dev/tty44", 0 },
-	{ "/dev/tty45", 0 },
-	{ "/dev/tty46", 0 },
-	{ "/dev/tty47", 0 },
-	{ "/dev/tty48", 0 },
-	{ "/dev/tty49", 0 },
-	{ "/dev/tty50", 0 },
-	{ "/dev/tty51", 0 },
-	{ "/dev/tty52", 0 },
-	{ "/dev/tty53", 0 },
-	{ "/dev/tty54", 0 },
-	{ "/dev/tty55", 0 },
-	{ "/dev/tty56", 0 },
-	{ "/dev/tty57", 0 },
-	{ "/dev/tty58", 0 },
-	{ "/dev/tty59", 0 },
-	{ "/dev/tty60", 0 },
-	{ "/dev/tty61", 0 },
-	{ "/dev/tty62", 0 },
-	{ "/dev/tty63", 0 },
-	{ "/dev/tty0", 0 },
-	{ "/dev/psaux", 0 },
-	{ "/dev/ptyp0", 0 },
-	{ "/dev/ptyp1", 0 },
-	{ "/dev/ptyp2", 0 },
-	{ "/dev/ptyp3", 0 },
-	{ "/dev/ptyp4", 0 },
-	{ "/dev/ptyp5", 0 },
-	{ "/dev/ptyp6", 0 },
-	{ "/dev/ptyp7", 0 },
-	{ "/dev/ptyp8", 0 },
-	{ "/dev/ptyp9", 0 },
-	{ "/dev/ptypa", 0 },
-	{ "/dev/ptypb", 0 },
-	{ "/dev/ptypc", 0 },
-	{ "/dev/ptypd", 0 },
-	{ "/dev/ptype", 0 },
-	{ "/dev/ptypf", 0 },
-	{ "/dev/ptyq0", 0 },
-	{ "/dev/ptyq1", 0 },
-	{ "/dev/ptyq2", 0 },
-	{ "/dev/ptyq3", 0 },
-	{ "/dev/ptyq4", 0 },
-	{ "/dev/ptyq5", 0 },
-	{ "/dev/ptyq6", 0 },
-	{ "/dev/ptyq7", 0 },
-	{ "/dev/ptyq8", 0 },
-	{ "/dev/ptyq9", 0 },
-	{ "/dev/ptyqa", 0 },
-	{ "/dev/ptyqb", 0 },
-	{ "/dev/ptyqc", 0 },
-	{ "/dev/ptyqd", 0 },
-	{ "/dev/ptyqe", 0 },
-	{ "/dev/ptyqf", 0 },
-	{ "/dev/ptyr0", 0 },
-	{ "/dev/ptyr1", 0 },
-	{ "/dev/ptyr2", 0 },
-	{ "/dev/ptyr3", 0 },
-	{ "/dev/ptyr4", 0 },
-	{ "/dev/ptyr5", 0 },
-	{ "/dev/ptyr6", 0 },
-	{ "/dev/ptyr7", 0 },
-	{ "/dev/ptyr8", 0 },
-	{ "/dev/ptyr9", 0 },
-	{ "/dev/ptyra", 0 },
-	{ "/dev/ptyrb", 0 },
-	{ "/dev/ptyrc", 0 },
-	{ "/dev/ptyrd", 0 },
-	{ "/dev/ptyre", 0 },
-	{ "/dev/ptyrf", 0 },
-	{ "/dev/ptys0", 0 },
-	{ "/dev/ptys1", 0 },
-	{ "/dev/ptys2", 0 },
-	{ "/dev/ptys3", 0 },
-	{ "/dev/ptys4", 0 },
-	{ "/dev/ptys5", 0 },
-	{ "/dev/ptys6", 0 },
-	{ "/dev/ptys7", 0 },
-	{ "/dev/ptys8", 0 },
-	{ "/dev/ptys9", 0 },
-	{ "/dev/ptysa", 0 },
-	{ "/dev/ptysb", 0 },
-	{ "/dev/ptysc", 0 },
-	{ "/dev/ptysd", 0 },
-	{ "/dev/ptyse", 0 },
-	{ "/dev/ptysf", 0 },
-	{ "/dev/ptyt0", 0 },
-	{ "/dev/ptyt1", 0 },
-	{ "/dev/ptyt2", 0 },
-	{ "/dev/ptyt3", 0 },
-	{ "/dev/ptyt4", 0 },
-	{ "/dev/ptyt5", 0 },
-	{ "/dev/ptyt6", 0 },
-	{ "/dev/ptyt7", 0 },
-	{ "/dev/ptyt8", 0 },
-	{ "/dev/ptyt9", 0 },
-	{ "/dev/ptyta", 0 },
-	{ "/dev/ptytb", 0 },
-	{ "/dev/ptytc", 0 },
-	{ "/dev/ptytd", 0 },
-	{ "/dev/ptyte", 0 },
-	{ "/dev/ptytf", 0 },
-	{ "/dev/ptyu0", 0 },
-	{ "/dev/ptyu1", 0 },
-	{ "/dev/ptyu2", 0 },
-	{ "/dev/ptyu3", 0 },
-	{ "/dev/ptyu4", 0 },
-	{ "/dev/ptyu5", 0 },
-	{ "/dev/ptyu6", 0 },
-	{ "/dev/ptyu7", 0 },
-	{ "/dev/ptyu8", 0 },
-	{ "/dev/ptyu9", 0 },
-	{ "/dev/ptyua", 0 },
-	{ "/dev/ptyub", 0 },
-	{ "/dev/ptyuc", 0 },
-	{ "/dev/ptyud", 0 },
-	{ "/dev/ptyue", 0 },
-	{ "/dev/ptyuf", 0 },
-	{ "/dev/ptyv0", 0 },
-	{ "/dev/ptyv1", 0 },
-	{ "/dev/ptyv2", 0 },
-	{ "/dev/ptyv3", 0 },
-	{ "/dev/ptyv4", 0 },
-	{ "/dev/ptyv5", 0 },
-	{ "/dev/ptyv6", 0 },
-	{ "/dev/ptyv7", 0 },
-	{ "/dev/ptyv8", 0 },
-	{ "/dev/ptyv9", 0 },
-	{ "/dev/ptyva", 0 },
-	{ "/dev/ptyvb", 0 },
-	{ "/dev/ptyvc", 0 },
-	{ "/dev/ptyvd", 0 },
-	{ "/dev/ptyve", 0 },
-	{ "/dev/ptyvf", 0 },
-	{ "/dev/ptyw0", 0 },
-	{ "/dev/ptyw1", 0 },
-	{ "/dev/ptyw2", 0 },
-	{ "/dev/ptyw3", 0 },
-	{ "/dev/ptyw4", 0 },
-	{ "/dev/ptyw5", 0 },
-	{ "/dev/ptyw6", 0 },
-	{ "/dev/ptyw7", 0 },
-	{ "/dev/ptyw8", 0 },
-	{ "/dev/ptyw9", 0 },
-	{ "/dev/ptywa", 0 },
-	{ "/dev/ptywb", 0 },
-	{ "/dev/ptywc", 0 },
-	{ "/dev/ptywd", 0 },
-	{ "/dev/ptywe", 0 },
-	{ "/dev/ptywf", 0 },
-	{ "/dev/ptyx0", 0 },
-	{ "/dev/ptyx1", 0 },
-	{ "/dev/ptyx2", 0 },
-	{ "/dev/ptyx3", 0 },
-	{ "/dev/ptyx4", 0 },
-	{ "/dev/ptyx5", 0 },
-	{ "/dev/ptyx6", 0 },
-	{ "/dev/ptyx7", 0 },
-	{ "/dev/ptyx8", 0 },
-	{ "/dev/ptyx9", 0 },
-	{ "/dev/ptyxa", 0 },
-	{ "/dev/ptyxb", 0 },
-	{ "/dev/ptyxc", 0 },
-	{ "/dev/ptyxd", 0 },
-	{ "/dev/ptyxe", 0 },
-	{ "/dev/ptyxf", 0 },
-	{ "/dev/ptyy0", 0 },
-	{ "/dev/ptyy1", 0 },
-	{ "/dev/ptyy2", 0 },
-	{ "/dev/ptyy3", 0 },
-	{ "/dev/ptyy4", 0 },
-	{ "/dev/ptyy5", 0 },
-	{ "/dev/ptyy6", 0 },
-	{ "/dev/ptyy7", 0 },
-	{ "/dev/ptyy8", 0 },
-	{ "/dev/ptyy9", 0 },
-	{ "/dev/ptyya", 0 },
-	{ "/dev/ptyyb", 0 },
-	{ "/dev/ptyyc", 0 },
-	{ "/dev/ptyyd", 0 },
-	{ "/dev/ptyye", 0 },
-	{ "/dev/ptyyf", 0 },
-	{ "/dev/ptyz0", 0 },
-	{ "/dev/ptyz1", 0 },
-	{ "/dev/ptyz2", 0 },
-	{ "/dev/ptyz3", 0 },
-	{ "/dev/ptyz4", 0 },
-	{ "/dev/ptyz5", 0 },
-	{ "/dev/ptyz6", 0 },
-	{ "/dev/ptyz7", 0 },
-	{ "/dev/ptyz8", 0 },
-	{ "/dev/ptyz9", 0 },
-	{ "/dev/ptyza", 0 },
-	{ "/dev/ptyzb", 0 },
-	{ "/dev/ptyzc", 0 },
-	{ "/dev/ptyzd", 0 },
-	{ "/dev/ptyze", 0 },
-	{ "/dev/ptyzf", 0 },
-	{ "/dev/ptya0", 0 },
-	{ "/dev/ptya1", 0 },
-	{ "/dev/ptya2", 0 },
-	{ "/dev/ptya3", 0 },
-	{ "/dev/ptya4", 0 },
-	{ "/dev/ptya5", 0 },
-	{ "/dev/ptya6", 0 },
-	{ "/dev/ptya7", 0 },
-	{ "/dev/ptya8", 0 },
-	{ "/dev/ptya9", 0 },
-	{ "/dev/ptyaa", 0 },
-	{ "/dev/ptyab", 0 },
-	{ "/dev/ptyac", 0 },
-	{ "/dev/ptyad", 0 },
-	{ "/dev/ptyae", 0 },
-	{ "/dev/ptyaf", 0 },
-	{ "/dev/ptyb0", 0 },
-	{ "/dev/ptyb1", 0 },
-	{ "/dev/ptyb2", 0 },
-	{ "/dev/ptyb3", 0 },
-	{ "/dev/ptyb4", 0 },
-	{ "/dev/ptyb5", 0 },
-	{ "/dev/ptyb6", 0 },
-	{ "/dev/ptyb7", 0 },
-	{ "/dev/ptyb8", 0 },
-	{ "/dev/ptyb9", 0 },
-	{ "/dev/ptyba", 0 },
-	{ "/dev/ptybb", 0 },
-	{ "/dev/ptybc", 0 },
-	{ "/dev/ptybd", 0 },
-	{ "/dev/ptybe", 0 },
-	{ "/dev/ptybf", 0 },
-	{ "/dev/ptyc0", 0 },
-	{ "/dev/ptyc1", 0 },
-	{ "/dev/ptyc2", 0 },
-	{ "/dev/ptyc3", 0 },
-	{ "/dev/ptyc4", 0 },
-	{ "/dev/ptyc5", 0 },
-	{ "/dev/ptyc6", 0 },
-	{ "/dev/ptyc7", 0 },
-	{ "/dev/ptyc8", 0 },
-	{ "/dev/ptyc9", 0 },
-	{ "/dev/ptyca", 0 },
-	{ "/dev/ptycb", 0 },
-	{ "/dev/ptycc", 0 },
-	{ "/dev/ptycd", 0 },
-	{ "/dev/ptyce", 0 },
-	{ "/dev/ptycf", 0 },
-	{ "/dev/ptyd0", 0 },
-	{ "/dev/ptyd1", 0 },
-	{ "/dev/ptyd2", 0 },
-	{ "/dev/ptyd3", 0 },
-	{ "/dev/ptyd4", 0 },
-	{ "/dev/ptyd5", 0 },
-	{ "/dev/ptyd6", 0 },
-	{ "/dev/ptyd7", 0 },
-	{ "/dev/ptyd8", 0 },
-	{ "/dev/ptyd9", 0 },
-	{ "/dev/ptyda", 0 },
-	{ "/dev/ptydb", 0 },
-	{ "/dev/ptydc", 0 },
-	{ "/dev/ptydd", 0 },
-	{ "/dev/ptyde", 0 },
-	{ "/dev/ptydf", 0 },
-	{ "/dev/ptye0", 0 },
-	{ "/dev/ptye1", 0 },
-	{ "/dev/ptye2", 0 },
-	{ "/dev/ptye3", 0 },
-	{ "/dev/ptye4", 0 },
-	{ "/dev/ptye5", 0 },
-	{ "/dev/ptye6", 0 },
-	{ "/dev/ptye7", 0 },
-	{ "/dev/ptye8", 0 },
-	{ "/dev/ptye9", 0 },
-	{ "/dev/ptyea", 0 },
-	{ "/dev/ptyeb", 0 },
-	{ "/dev/ptyec", 0 },
-	{ "/dev/ptyed", 0 },
-	{ "/dev/ptyee", 0 },
-	{ "/dev/ptyef", 0 },
-	{ "/dev/vcs", 0 },
-	{ "/dev/vcsa", 0 },
-	{ "/dev/vcs1", 0 },
-	{ "/dev/vcsa1", 0 },
-	{ "/dev/ttyS0", 0 },
-	{ "/dev/cua0", 0 },
-	{ "/dev/hda", 0 },
-	{ "/dev/hda1", 2 },
-	{ "/dev/hda2", 2 },
-	{ "/dev/hda3", 2 },
-	{ "/dev/hda4", 2 },
-	{ "/dev/hda5", 2 },
-	{ "/dev/hda6", 0 },
-	{ "/dev/hda7", 0 },
-	{ "/dev/hda8", 0 },
-	{ "/dev/hdb", 0 },
-	{ "/dev/hdb1", 2 },
-	{ "/dev/hdc", 0 },
-	{ "/dev/hdc1", 2 },
-	{ "/dev/fd0u1440", 0 },
-	{ "/dev/fd0u1680", 0 },
-	{ "/dev/fd0u1722", 0 },
-	{ "/dev/fd0u1743", 0 },
-	{ "/dev/fd0u1760", 0 },
-	{ "/dev/fd0u1920", 0 },
-	{ "/dev/fd0u1840", 0 },
-	{ "/dev/fd0u1600", 0 },
-	{ "/dev/fd0u360", 0 },
-	{ "/dev/fd0u720", 0 },
-	{ "/dev/fd0u820", 0 },
-	{ "/dev/fd0u830", 0 },
-	{ "/dev/fd0u1040", 0 },
-	{ "/dev/fd0u1120", 0 },
-	{ "/dev/fd0u800", 0 },
-	{ "/dev/fd0", 0 },
-	{ "/dev/loop0", 0 },
-	{ "/dev/loop1", 0 },
-	{ "/dev/loop2", 0 },
-	{ "/dev/loop3", 0 },
-	{ "/dev/loop4", 0 },
-	{ "/dev/loop5", 0 },
-	{ "/dev/loop6", 0 },
-	{ "/dev/loop7", 0 },
-	{ "/dev/dsp", 0 },
-	{ "/dev/dsp1", 0 },
-	{ "/dev/mixer", 0 },
-	{ "/dev/midi", 0 },
-	{ "/dev/lvm", 0 },
-	{ "/dev/vg0", 0 },
-	{ "/dev/vg0/group", 0 },
-	{ "/dev/vg0/packages", 0 },
-	{ "/dev/vg0/photos", 0 },
-	{ "/dev/vg0/music", 0 },
-	{ "/dev/log", 0 },
-	{ "/dev/MAKEDEV", 0 },
-	{ "/dev/printer", 0 },
-	{ "/dev/vcs2", 0 },
-	{ "/dev/vcsa2", 0 },
-	{ "/dev/vcs3", 0 },
-	{ "/dev/vcsa3", 0 },
-	{ "/dev/vcs5", 0 },
-	{ "/dev/vcsa5", 0 },
-	{ "/dev/vcs4", 0 },
-	{ "/dev/vcsa4", 0 },
-	{ "/dev/vcs6", 0 },
-	{ "/dev/vcsa6", 0 },
-	{ "/dev/nvidia0", 0 },
-	{ "/dev/nvidia1", 0 },
-	{ "/dev/nvidia2", 0 },
-	{ "/dev/nvidia3", 0 },
-	{ "/dev/nvidiactl", 0 },
-	{ "/dev/vcs7", 0 },
-	{ "/dev/vcsa7", 0 },
-	{ NULL, 0 }
-};
diff --git a/test/unit/matcher_t.c b/test/unit/matcher_t.c
deleted file mode 100644
index f7fac97..0000000
--- a/test/unit/matcher_t.c
+++ /dev/null
@@ -1,70 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-
-#include "matcher_data.h"
-
-static struct dm_pool *mem = NULL;
-
-int regex_init(void) {
-	mem = dm_pool_create("bitset test", 1024);
-	return mem == NULL;
-}
-
-int regex_fini(void) {
-	dm_pool_destroy(mem);
-	return 0;
-}
-
-static struct dm_regex *make_scanner(const char **rx)
-{
-	struct dm_regex *scanner;
-	int nrx = 0;
-	for (; rx[nrx]; ++nrx);
-
-	scanner = dm_regex_create(mem, rx, nrx);
-	CU_ASSERT_FATAL(scanner != NULL);
-	return scanner;
-}
-
-static void test_fingerprints(void) {
-	struct dm_regex *scanner;
-
-	scanner = make_scanner(dev_patterns);
-	CU_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x7f556c09);
-
-	scanner = make_scanner(random_patterns);
-	CU_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x9f11076c);
-}
-
-static void test_matching(void) {
-	struct dm_regex *scanner;
-	int i;
-
-	scanner = make_scanner(dev_patterns);
-	for (i = 0; devices[i].str; ++i)
-		CU_ASSERT_EQUAL(dm_regex_match(scanner, devices[i].str), devices[i].expected - 1);
-
-	scanner = make_scanner(nonprint_patterns);
-	for (i = 0; nonprint[i].str; ++i)
-		CU_ASSERT_EQUAL(dm_regex_match(scanner, nonprint[i].str), nonprint[i].expected - 1);
-}
-
-CU_TestInfo regex_list[] = {
-	{ (char*)"fingerprints", test_fingerprints },
-	{ (char*)"matching", test_matching },
-	CU_TEST_INFO_NULL
-};
diff --git a/test/unit/percent_t.c b/test/unit/percent_t.c
deleted file mode 100644
index 650f381..0000000
--- a/test/unit/percent_t.c
+++ /dev/null
@@ -1,101 +0,0 @@
-/*
- * Copyright (C) 2017 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-
-#include <stdio.h>
-#include <string.h>
-
-int percent_init(void)
-{
-	return 0;
-}
-
-int percent_fini(void)
-{
-	return 0;
-}
-
-static void test_percent_100(void)
-{
-	char buf[32];
-
-        /* Check 100% is shown only for DM_PERCENT_100*/
-	dm_percent_t p_100 = dm_make_percent(100, 100);
-        dm_percent_t p1_100 = dm_make_percent(100000, 100000);
-        dm_percent_t n_100 = dm_make_percent(999999, 1000000);
-
-	CU_ASSERT_EQUAL(p_100, DM_PERCENT_100);
-	CU_ASSERT_EQUAL(p1_100, DM_PERCENT_100);
-	CU_ASSERT_NOT_EQUAL(n_100, DM_PERCENT_100);
-
-        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_100));
-	CU_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_100));
-	CU_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_100));
-	CU_ASSERT_NOT_EQUAL(strcmp(buf, "99.99"), 0); /* Would like to gett */
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_100, 2));
-	CU_ASSERT_EQUAL(strcmp(buf, "99.99"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_100, 3));
-	CU_ASSERT_EQUAL(strcmp(buf, "99.999"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.4f", dm_percent_to_round_float(n_100, 4));
-	CU_ASSERT_EQUAL(strcmp(buf, "99.9999"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_100, 0));
-	CU_ASSERT_EQUAL(strcmp(buf, "99"), 0);
-}
-
-static void test_percent_0(void)
-{
-	char buf[32];
-
-	/* Check 0% is shown only for DM_PERCENT_0 */
-	dm_percent_t p_0 = dm_make_percent(0, 100);
-        dm_percent_t p1_0 = dm_make_percent(0, 100000);
-        dm_percent_t n_0 = dm_make_percent(1, 1000000);
-
-	CU_ASSERT_EQUAL(p_0, DM_PERCENT_0);
-	CU_ASSERT_EQUAL(p1_0, DM_PERCENT_0);
-	CU_ASSERT_NOT_EQUAL(n_0, DM_PERCENT_0);
-
-        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_0));
-	CU_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_0));
-	CU_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_0));
-	CU_ASSERT_NOT_EQUAL(strcmp(buf, "0.01"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_0, 2));
-	CU_ASSERT_EQUAL(strcmp(buf, "0.01"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_0, 3));
-	CU_ASSERT_EQUAL(strcmp(buf, "0.001"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_0, 0));
-	CU_ASSERT_EQUAL(strcmp(buf, "1"), 0);
-}
-
-CU_TestInfo percent_list[] = {
-	{ (char*)"percent_100", test_percent_100 },
-	{ (char*)"percent_0", test_percent_0 },
-	CU_TEST_INFO_NULL
-};
diff --git a/test/unit/run.c b/test/unit/run.c
deleted file mode 100644
index 82090ba..0000000
--- a/test/unit/run.c
+++ /dev/null
@@ -1,39 +0,0 @@
-#include "units.h"
-#include <CUnit/Basic.h>
-
-#include <stdio.h>
-#include <stdlib.h>
-
-/* Setup SuiteInfo struct in a  compatible way across different CUnit versions */
-/* old version of CUnit has used char* for .pName, so using cast here */
-#define USE(n) { \
-	.pName = (char*) #n, \
-	.pInitFunc = n##_init, \
-	.pCleanupFunc = n##_fini, \
-	.pTests = n##_list }
-
-CU_SuiteInfo suites[] = {
-	USE(bcache),
-	USE(bitset),
-	USE(config),
-	USE(dmlist),
-	USE(dmstatus),
-	USE(regex),
-	USE(percent),
-	USE(string),
-	CU_SUITE_INFO_NULL
-};
-
-int main(int argc, char **argv) {
-	if (CU_initialize_registry() != CUE_SUCCESS) {
-		printf("Initialization of Test Registry failed.\n");
-		return CU_get_error();
-	}
-
-	CU_register_suites(suites);
-	CU_basic_set_mode(CU_BRM_VERBOSE);
-	CU_basic_run_tests();
-	CU_cleanup_registry();
-
-	return (CU_get_number_of_failures() != 0);
-}
diff --git a/test/unit/string_t.c b/test/unit/string_t.c
deleted file mode 100644
index 68e39c6..0000000
--- a/test/unit/string_t.c
+++ /dev/null
@@ -1,78 +0,0 @@
-/*
- * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-
-#include <stdio.h>
-#include <string.h>
-
-static struct dm_pool *mem = NULL;
-
-int string_init(void)
-{
-	mem = dm_pool_create("string test", 1024);
-
-	return (mem == NULL);
-}
-
-int string_fini(void)
-{
-	dm_pool_destroy(mem);
-
-	return 0;
-}
-
-/* TODO: Add more string unit tests here */
-
-static void test_strncpy(void)
-{
-	const char st[] = "1234567890";
-	char buf[sizeof(st)];
-
-	CU_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf)), 1);
-	CU_ASSERT_EQUAL(strcmp(buf, st), 0);
-
-	CU_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf) - 1), 0);
-	CU_ASSERT_EQUAL(strlen(buf) + 1, sizeof(buf) - 1);
-}
-
-static void test_asprint(void)
-{
-	const char st0[] = "";
-	const char st1[] = "12345678901";
-	const char st2[] = "1234567890123456789012345678901234567890123456789012345678901234567";
-	char *buf;
-	int a;
-
-	a = dm_asprintf(&buf, "%s", st0);
-	CU_ASSERT_EQUAL(strcmp(buf, st0), 0);
-	CU_ASSERT_EQUAL(a, sizeof(st0));
-	free(buf);
-
-	a = dm_asprintf(&buf, "%s", st1);
-	CU_ASSERT_EQUAL(strcmp(buf, st1), 0);
-	CU_ASSERT_EQUAL(a, sizeof(st1));
-	free(buf);
-
-	a = dm_asprintf(&buf, "%s", st2);
-	CU_ASSERT_EQUAL(a, sizeof(st2));
-	CU_ASSERT_EQUAL(strcmp(buf, st2), 0);
-	free(buf);
-}
-
-CU_TestInfo string_list[] = {
-	{ (char*)"asprint", test_asprint },
-	{ (char*)"strncpy", test_strncpy },
-	CU_TEST_INFO_NULL
-};
diff --git a/test/unit/units.h b/test/unit/units.h
deleted file mode 100644
index 319e7ce..0000000
--- a/test/unit/units.h
+++ /dev/null
@@ -1,35 +0,0 @@
-/*
- * Copyright (C) 2015-2017 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#ifndef _UNITS_H
-#define _UNITS_H
-
-#include "libdevmapper.h"
-#include <CUnit/CUnit.h>
-
-#define DECL(n) \
-	extern CU_TestInfo n ## _list[];\
-	int n ## _init(void); \
-	int n ## _fini(void);
-
-DECL(bcache);
-DECL(bitset);
-DECL(config);
-DECL(dmlist);
-DECL(dmstatus);
-DECL(regex);
-DECL(percent);
-DECL(string);
-
-#endif
diff --git a/unit-test/Makefile.in b/unit-test/Makefile.in
new file mode 100644
index 0000000..5577706
--- /dev/null
+++ b/unit-test/Makefile.in
@@ -0,0 +1,40 @@
+# Copyright (C) 2011-2018 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+UNIT_SOURCE=\
+	unit-test/bcache_t.c \
+	unit-test/bitset_t.c \
+	unit-test/config_t.c \
+	unit-test/dmlist_t.c \
+	unit-test/dmstatus_t.c \
+	unit-test/matcher_t.c \
+	unit-test/framework.c \
+	unit-test/percent_t.c \
+	unit-test/run.c \
+	unit-test/string_t.c
+
+UNIT_DEPENDS=$(subst .c,.d,$(UNIT_SOURCE))
+UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
+CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
+UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio
+
+unit-test/unit-test: $(UNIT_OBJECTS) libdm/libdevmapper.$(LIB_SUFFIX) lib/liblvm-internal.a
+	@echo "    [LD] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
+	      -o $@ $(UNIT_OBJECTS) $(UNIT_LDLIBS)
+
+.PHONEY: run-unit-test
+run-unit-test: unit-test/unit-test
+	@echo Running unit tests
+	LD_LIBRARY_PATH=libdm unit-test/unit-test run
+
+-include $(UNIT_DEPENDS)
diff --git a/unit-test/bcache_t.c b/unit-test/bcache_t.c
new file mode 100644
index 0000000..4fe913b
--- /dev/null
+++ b/unit-test/bcache_t.c
@@ -0,0 +1,783 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+
+#include "bcache.h"
+#include "framework.h"
+#include "units.h"
+
+#define SHOW_MOCK_CALLS 0
+
+/*----------------------------------------------------------------
+ * Mock engine
+ *--------------------------------------------------------------*/
+struct mock_engine {
+	struct io_engine e;
+	struct dm_list expected_calls;
+	struct dm_list issued_io;
+	unsigned max_io;
+	sector_t block_size;
+};
+
+enum method {
+	E_DESTROY,
+	E_ISSUE,
+	E_WAIT,
+	E_MAX_IO
+};
+
+struct mock_call {
+	struct dm_list list;
+	enum method m;
+
+	bool match_args;
+	enum dir d;
+	int fd;
+	block_address b;
+	bool issue_r;
+	bool wait_r;
+};
+
+struct mock_io {
+	struct dm_list list;
+	int fd;
+	sector_t sb;
+	sector_t se;
+	void *data;
+	void *context;
+	bool r;
+};
+
+static const char *_show_method(enum method m)
+{
+	switch (m) {
+	case E_DESTROY:
+		return "destroy()";
+	case E_ISSUE:
+		return "issue()";
+	case E_WAIT:
+		return "wait()";
+	case E_MAX_IO:
+		return "max_io()";
+	}
+
+	return "<unknown>";
+}
+
+static void _expect(struct mock_engine *e, enum method m)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = m;
+	mc->match_args = false;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_read(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_READ;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = true;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_write(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_WRITE;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = true;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_read_bad_issue(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_READ;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = false;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_write_bad_issue(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_WRITE;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = false;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_read_bad_wait(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_READ;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = true;
+	mc->wait_r = false;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_write_bad_wait(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_WRITE;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = true;
+	mc->wait_r = false;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static struct mock_call *_match_pop(struct mock_engine *e, enum method m)
+{
+
+	struct mock_call *mc;
+
+	if (dm_list_empty(&e->expected_calls))
+		test_fail("unexpected call to method %s\n", _show_method(m));
+
+	mc = dm_list_item(e->expected_calls.n, struct mock_call);
+	dm_list_del(&mc->list);
+
+	if (mc->m != m)
+		test_fail("expected %s, but got %s\n", _show_method(mc->m), _show_method(m));
+#if SHOW_MOCK_CALLS
+	else
+		fprintf(stderr, "%s called (expected)\n", _show_method(m));
+#endif
+
+	return mc;
+}
+
+static void _match(struct mock_engine *e, enum method m)
+{
+	free(_match_pop(e, m));
+}
+
+static void _no_outstanding_expectations(struct mock_engine *e)
+{
+	struct mock_call *mc;
+
+	if (!dm_list_empty(&e->expected_calls)) {
+		fprintf(stderr, "unsatisfied expectations:\n");
+		dm_list_iterate_items (mc, &e->expected_calls)
+			fprintf(stderr, "  %s\n", _show_method(mc->m));
+	}
+	T_ASSERT(dm_list_empty(&e->expected_calls));
+}
+
+static struct mock_engine *_to_mock(struct io_engine *e)
+{
+	return container_of(e, struct mock_engine, e);
+}
+
+static void _mock_destroy(struct io_engine *e)
+{
+	struct mock_engine *me = _to_mock(e);
+
+	_match(me, E_DESTROY);
+	T_ASSERT(dm_list_empty(&me->issued_io));
+	T_ASSERT(dm_list_empty(&me->expected_calls));
+	free(_to_mock(e));
+}
+
+static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
+	      		sector_t sb, sector_t se, void *data, void *context)
+{
+	bool r, wait_r;
+	struct mock_io *io;
+	struct mock_call *mc;
+	struct mock_engine *me = _to_mock(e);
+
+	mc = _match_pop(me, E_ISSUE);
+	if (mc->match_args) {
+		T_ASSERT(d == mc->d);
+		T_ASSERT(fd == mc->fd);
+		T_ASSERT(sb == mc->b * me->block_size);
+		T_ASSERT(se == (mc->b + 1) * me->block_size);
+	}
+	r = mc->issue_r;
+	wait_r = mc->wait_r;
+	free(mc);
+
+	if (r) {
+		io = malloc(sizeof(*io));
+		if (!io)
+			abort();
+
+		io->fd = fd;
+		io->sb = sb;
+		io->se = se;
+		io->data = data;
+		io->context = context;
+		io->r = wait_r;
+
+		dm_list_add(&me->issued_io, &io->list);
+	}
+
+	return r;
+}
+
+static bool _mock_wait(struct io_engine *e, io_complete_fn fn)
+{
+	struct mock_io *io;
+	struct mock_engine *me = _to_mock(e);
+	_match(me, E_WAIT);
+
+	// FIXME: provide a way to control how many are completed and whether
+	// they error.
+	T_ASSERT(!dm_list_empty(&me->issued_io));
+	io = dm_list_item(me->issued_io.n, struct mock_io);
+	dm_list_del(&io->list);
+	fn(io->context, io->r ? 0 : -EIO);
+	free(io);
+
+	return true;
+}
+
+static unsigned _mock_max_io(struct io_engine *e)
+{
+	struct mock_engine *me = _to_mock(e);
+	_match(me, E_MAX_IO);
+	return me->max_io;
+}
+
+static struct mock_engine *_mock_create(unsigned max_io, sector_t block_size)
+{
+	struct mock_engine *m = malloc(sizeof(*m));
+
+	m->e.destroy = _mock_destroy;
+	m->e.issue = _mock_issue;
+	m->e.wait = _mock_wait;
+	m->e.max_io = _mock_max_io;
+
+	m->max_io = max_io;
+	m->block_size = block_size;
+	dm_list_init(&m->expected_calls);
+	dm_list_init(&m->issued_io);
+
+	return m;
+}
+
+/*----------------------------------------------------------------
+ * Fixtures
+ *--------------------------------------------------------------*/
+struct fixture {
+	struct mock_engine *me;
+	struct bcache *cache;
+};
+
+static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_blocks)
+{
+	struct fixture *f = malloc(sizeof(*f));
+
+	f->me = _mock_create(16, block_size);
+	T_ASSERT(f->me);
+
+	_expect(f->me, E_MAX_IO);
+	f->cache = bcache_create(block_size, nr_cache_blocks, &f->me->e);
+	T_ASSERT(f->cache);
+
+	return f;
+}
+
+static void _fixture_exit(struct fixture *f)
+{
+	_expect(f->me, E_DESTROY);
+	bcache_destroy(f->cache);
+
+	free(f);
+}
+
+static void *_small_fixture_init(void)
+{
+	return _fixture_init(128, 16);
+}
+
+static void _small_fixture_exit(void *context)
+{
+	_fixture_exit(context);
+}
+
+static void *_large_fixture_init(void)
+{
+	return _fixture_init(128, 1024);
+}
+
+static void _large_fixture_exit(void *context)
+{
+	_fixture_exit(context);
+}
+
+/*----------------------------------------------------------------
+ * Tests
+ *--------------------------------------------------------------*/
+#define MEG 2048
+#define SECTOR_SHIFT 9
+
+static void good_create(sector_t block_size, unsigned nr_cache_blocks)
+{
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16, 128);
+
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
+
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
+}
+
+static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
+{
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16, 128);
+
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
+	T_ASSERT(!cache);
+
+	_expect(me, E_DESTROY);
+	me->e.destroy(&me->e);
+}
+
+static void test_create(void *fixture)
+{
+	good_create(8, 16);
+}
+
+static void test_nr_cache_blocks_must_be_positive(void *fixture)
+{
+	bad_create(8, 0);
+}
+
+static void test_block_size_must_be_positive(void *fixture)
+{
+	bad_create(0, 16);
+}
+
+static void test_block_size_must_be_multiple_of_page_size(void *fixture)
+{
+	static unsigned _bad_examples[] = {3, 9, 13, 1025};
+
+	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_bad_examples); i++)
+		bad_create(_bad_examples[i], 16);
+
+	for (i = 1; i < 1000; i++)
+		good_create(i * 8, 16);
+}
+
+static void test_get_triggers_read(void *context)
+{
+        int err;
+	struct fixture *f = context;
+
+	int fd = 17;   // arbitrary key
+	struct block *b;
+
+	_expect_read(f->me, fd, 0);
+	_expect(f->me, E_WAIT);
+	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+}
+
+static void test_repeated_reads_are_cached(void *context)
+{
+        int err;
+	struct fixture *f = context;
+
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
+
+	_expect_read(f->me, fd, 0);
+	_expect(f->me, E_WAIT);
+	for (i = 0; i < 100; i++) {
+		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
+		bcache_put(b);
+	}
+}
+
+static void test_block_gets_evicted_with_many_reads(void *context)
+{
+	struct fixture *f = context;
+
+	int err;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	const unsigned nr_cache_blocks = 16;
+
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
+
+	for (i = 0; i < nr_cache_blocks; i++) {
+		_expect_read(me, fd, i);
+		_expect(me, E_WAIT);
+		T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+		bcache_put(b);
+	}
+
+	// Not enough cache blocks to hold this one
+	_expect_read(me, fd, nr_cache_blocks);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b, &err));
+	bcache_put(b);
+
+	// Now if we run through we should find one block has been
+	// evicted.  We go backwards because the oldest is normally
+	// evicted first.
+	_expect(me, E_ISSUE);
+	_expect(me, E_WAIT);
+	for (i = nr_cache_blocks; i; i--) {
+		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b, &err));
+		bcache_put(b);
+	}
+}
+
+static void test_prefetch_issues_a_read(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	const unsigned nr_cache_blocks = 16;
+
+	int err;
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
+
+	for (i = 0; i < nr_cache_blocks; i++) {
+		// prefetch should not wait
+		_expect_read(me, fd, i);
+		bcache_prefetch(cache, fd, i);
+	}
+
+
+	for (i = 0; i < nr_cache_blocks; i++) {
+		_expect(me, E_WAIT);
+		T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+		bcache_put(b);
+	}
+}
+
+static void test_too_many_prefetches_does_not_trigger_a_wait(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	const unsigned nr_cache_blocks = 16;
+	int fd = 17;   // arbitrary key
+	unsigned i;
+
+	for (i = 0; i < 10 * nr_cache_blocks; i++) {
+		// prefetch should not wait
+		if (i < nr_cache_blocks)
+			_expect_read(me, fd, i);
+		bcache_prefetch(cache, fd, i);
+	}
+
+	// Destroy will wait for any in flight IO triggered by prefetches.
+	for (i = 0; i < nr_cache_blocks; i++)
+		_expect(me, E_WAIT);
+}
+
+static void test_dirty_data_gets_written_back(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	int err;
+	int fd = 17;   // arbitrary key
+	struct block *b;
+
+	// Expect the read
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b, &err));
+	bcache_put(b);
+
+	// Expect the write
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+}
+
+static void test_zeroed_data_counts_as_dirty(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	int err;
+	int fd = 17;   // arbitrary key
+	struct block *b;
+
+	// No read
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	bcache_put(b);
+
+	// Expect the write
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+}
+
+static void test_flush_waits_for_all_dirty(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	const unsigned count = 16;
+	int err;
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
+
+	for (i = 0; i < count; i++) {
+		if (i % 2) {
+			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b, &err));
+		} else {
+			_expect_read(me, fd, i);
+			_expect(me, E_WAIT);
+			T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+		}
+		bcache_put(b);
+	}
+
+	for (i = 0; i < count; i++) {
+		if (i % 2)
+			_expect_write(me, fd, i);
+	}
+
+	for (i = 0; i < count; i++) {
+		if (i % 2)
+			_expect(me, E_WAIT);
+	}
+
+	bcache_flush(cache);
+	_no_outstanding_expectations(me);
+}
+
+static void test_multiple_files(void *context)
+{
+	static int _fds[] = {1, 128, 345, 678, 890};
+
+	int err;
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_fds); i++) {
+		_expect_read(me, _fds[i], 0);
+		_expect(me, E_WAIT);
+
+		T_ASSERT(bcache_get(cache, _fds[i], 0, 0, &b, &err));
+		bcache_put(b);
+	}
+}
+
+static void test_read_bad_issue(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int err;
+
+	_expect_read_bad_issue(me, 17, 0);
+	T_ASSERT(!bcache_get(cache, 17, 0, 0, &b, &err));
+}
+
+static void test_read_bad_issue_intermittent(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read_bad_issue(me, fd, 0);
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+}
+
+static void test_read_bad_wait(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read_bad_wait(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+}
+
+static void test_read_bad_wait_intermittent(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read_bad_wait(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+}
+
+static void test_write_bad_issue_stops_flush(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	_expect_write_bad_issue(me, fd, 0);
+	bcache_put(b);
+	T_ASSERT(!bcache_flush(cache));
+
+	// we'll let it succeed the second time
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_flush(cache));
+}
+
+static void test_write_bad_io_stops_flush(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	_expect_write_bad_wait(me, fd, 0);
+	_expect(me, E_WAIT);
+	bcache_put(b);
+	T_ASSERT(!bcache_flush(cache));
+
+	// we'll let it succeed the second time
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_flush(cache));
+}
+
+// Tests to be written
+// show invalidate works
+// show invalidate_fd works
+// show writeback is working
+
+/*----------------------------------------------------------------
+ * Top level
+ *--------------------------------------------------------------*/
+#define T(path, desc, fn) register_test(ts, "/base/device/bcache/" path, desc, fn)
+
+static struct test_suite *_small_tests(void)
+{
+	struct test_suite *ts = test_suite_create(_small_fixture_init, _small_fixture_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("create-destroy", "simple create/destroy", test_create);
+	T("cache-blocks-positive", "nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive);
+	T("block-size-positive", "block size must be positive", test_block_size_must_be_positive);
+	T("block-size-multiple-page", "block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size);
+	T("get-reads", "bcache_get() triggers read", test_get_triggers_read);
+	T("reads-cached", "repeated reads are cached", test_repeated_reads_are_cached);
+	T("blocks-get-evicted", "block get evicted with many reads", test_block_gets_evicted_with_many_reads);
+	T("prefetch-reads", "prefetch issues a read", test_prefetch_issues_a_read);
+	T("prefetch-never-waits", "too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait);
+	T("writeback-occurs", "dirty data gets written back", test_dirty_data_gets_written_back);
+	T("zero-flag-dirties", "zeroed data counts as dirty", test_zeroed_data_counts_as_dirty);
+	T("read-multiple-files", "read from multiple files", test_multiple_files);
+	T("read-bad-issue", "read fails if io engine unable to issue", test_read_bad_issue);
+	T("read-bad-issue-intermittent", "failed issue, followed by succes", test_read_bad_issue_intermittent);
+	T("read-bad-io", "read issued ok, but io fails", test_read_bad_wait);
+	T("read-bad-io-intermittent", "failed io, followed by success", test_read_bad_wait_intermittent);
+	T("write-bad-issue-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_issue_stops_flush);
+	T("write-bad-io-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_io_stops_flush);
+
+	return ts;
+}
+
+static struct test_suite *_large_tests(void)
+{
+	struct test_suite *ts = test_suite_create(_large_fixture_init, _large_fixture_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("flush-waits", "flush waits for all dirty", test_flush_waits_for_all_dirty);
+
+	return ts;
+}
+
+void bcache_tests(struct dm_list *all_tests)
+{
+	dm_list_add(all_tests, &_small_tests()->list);
+	dm_list_add(all_tests, &_large_tests()->list);
+}
diff --git a/unit-test/bitset_t.c b/unit-test/bitset_t.c
new file mode 100644
index 0000000..106f60f
--- /dev/null
+++ b/unit-test/bitset_t.c
@@ -0,0 +1,148 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+enum {
+        NR_BITS = 137
+};
+
+static void *_mem_init(void) {
+	struct dm_pool *mem = dm_pool_create("bitset test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+static void test_get_next(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+
+        int i, j, last = 0, first;
+        dm_bitset_t bs = dm_bitset_create(mem, NR_BITS);
+
+        for (i = 0; i < NR_BITS; i++)
+                T_ASSERT(!dm_bit(bs, i));
+
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++)
+                dm_bit_set(bs, i);
+
+        first = 1;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                if (first) {
+                        last = dm_bit_get_first(bs);
+                        first = 0;
+                } else
+                        last = dm_bit_get_next(bs, last);
+
+                T_ASSERT(last == i);
+        }
+
+        T_ASSERT(dm_bit_get_next(bs, last) == -1);
+}
+
+static void bit_flip(dm_bitset_t bs, int bit)
+{
+        int old = dm_bit(bs, bit);
+        if (old)
+                dm_bit_clear(bs, bit);
+        else
+                dm_bit_set(bs, bit);
+}
+
+static void test_equal(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
+
+        int i, j;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                dm_bit_set(bs1, i);
+                dm_bit_set(bs2, i);
+        }
+
+        T_ASSERT(dm_bitset_equal(bs1, bs2));
+        T_ASSERT(dm_bitset_equal(bs2, bs1));
+
+        for (i = 0; i < NR_BITS; i++) {
+                bit_flip(bs1, i);
+                T_ASSERT(!dm_bitset_equal(bs1, bs2));
+                T_ASSERT(!dm_bitset_equal(bs2, bs1));
+
+                T_ASSERT(dm_bitset_equal(bs1, bs1)); /* comparing with self */
+                bit_flip(bs1, i);
+        }
+}
+
+static void test_and(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs3 = dm_bitset_create(mem, NR_BITS);
+
+        int i, j;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                dm_bit_set(bs1, i);
+                dm_bit_set(bs2, i);
+        }
+
+        dm_bit_and(bs3, bs1, bs2);
+
+        T_ASSERT(dm_bitset_equal(bs1, bs2));
+        T_ASSERT(dm_bitset_equal(bs1, bs3));
+        T_ASSERT(dm_bitset_equal(bs2, bs3));
+
+        dm_bit_clear_all(bs1);
+        dm_bit_clear_all(bs2);
+
+        for (i = 0; i < NR_BITS; i++) {
+                if (i % 2)
+                        dm_bit_set(bs1, i);
+                else
+                        dm_bit_set(bs2, i);
+        }
+
+        dm_bit_and(bs3, bs1, bs2);
+        for (i = 0; i < NR_BITS; i++)
+                T_ASSERT(!dm_bit(bs3, i));
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/data-struct/bitset/" path, desc, fn)
+
+void bitset_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("get_next", "get next set bit", test_get_next);
+	T("equal", "equality", test_equal);
+	T("and", "and all bits", test_and);
+
+	dm_list_add(all_tests, &ts->list);
+}
+
diff --git a/unit-test/config_t.c b/unit-test/config_t.c
new file mode 100644
index 0000000..5331f79
--- /dev/null
+++ b/unit-test/config_t.c
@@ -0,0 +1,167 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+static void *_mem_init(void)
+{
+	struct dm_pool *mem = dm_pool_create("config test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+static const char *conf =
+	"id = \"yada-yada\"\n"
+	"seqno = 15\n"
+	"status = [\"READ\", \"WRITE\"]\n"
+	"flags = []\n"
+	"extent_size = 8192\n"
+	"physical_volumes {\n"
+	"    pv0 {\n"
+	"        id = \"abcd-efgh\"\n"
+	"    }\n"
+	"    pv1 {\n"
+	"        id = \"bbcd-efgh\"\n"
+	"    }\n"
+	"    pv2 {\n"
+	"        id = \"cbcd-efgh\"\n"
+	"    }\n"
+	"}\n";
+
+static const char *overlay =
+	"id = \"yoda-soda\"\n"
+	"flags = [\"FOO\"]\n"
+	"physical_volumes {\n"
+	"    pv1 {\n"
+	"        id = \"hgfe-dcba\"\n"
+	"    }\n"
+	"    pv3 {\n"
+	"        id = \"dbcd-efgh\"\n"
+	"    }\n"
+	"}\n";
+
+static void test_parse(void *fixture)
+{
+	struct dm_config_tree *tree = dm_config_from_string(conf);
+	const struct dm_config_value *value;
+
+	T_ASSERT((long) tree);
+	T_ASSERT(dm_config_has_node(tree->root, "id"));
+	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes"));
+	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0"));
+	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0/id"));
+
+	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "id", "foo"), "yada-yada"));
+	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "idt", "foo"), "foo"));
+
+	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/bb", "foo"), "foo"));
+	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
+
+	T_ASSERT(!dm_config_get_uint32(tree->root, "id", NULL));
+	T_ASSERT(dm_config_get_uint32(tree->root, "extent_size", NULL));
+
+	/* FIXME: Currently everything parses as a list, even if it's not */
+	// T_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
+	// T_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
+
+	T_ASSERT(dm_config_get_list(tree->root, "flags", &value));
+	T_ASSERT(value->next == NULL); /* an empty list */
+	T_ASSERT(dm_config_get_list(tree->root, "status", &value));
+	T_ASSERT(value->next != NULL); /* a non-empty list */
+
+	dm_config_destroy(tree);
+}
+
+static void test_clone(void *fixture)
+{
+	struct dm_config_tree *tree = dm_config_from_string(conf);
+	struct dm_config_node *n = dm_config_clone_node(tree, tree->root, 1);
+	const struct dm_config_value *value;
+
+	/* Check that the nodes are actually distinct. */
+	T_ASSERT(n != tree->root);
+	T_ASSERT(n->sib != tree->root->sib);
+	T_ASSERT(dm_config_find_node(n, "physical_volumes") != NULL);
+	T_ASSERT(dm_config_find_node(tree->root, "physical_volumes") != NULL);
+	T_ASSERT(dm_config_find_node(n, "physical_volumes") != dm_config_find_node(tree->root, "physical_volumes"));
+
+	T_ASSERT(dm_config_has_node(n, "id"));
+	T_ASSERT(dm_config_has_node(n, "physical_volumes"));
+	T_ASSERT(dm_config_has_node(n, "physical_volumes/pv0"));
+	T_ASSERT(dm_config_has_node(n, "physical_volumes/pv0/id"));
+
+	T_ASSERT(!strcmp(dm_config_find_str(n, "id", "foo"), "yada-yada"));
+	T_ASSERT(!strcmp(dm_config_find_str(n, "idt", "foo"), "foo"));
+
+	T_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/bb", "foo"), "foo"));
+	T_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
+
+	T_ASSERT(!dm_config_get_uint32(n, "id", NULL));
+	T_ASSERT(dm_config_get_uint32(n, "extent_size", NULL));
+
+	/* FIXME: Currently everything parses as a list, even if it's not */
+	// T_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
+	// T_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
+
+	T_ASSERT(dm_config_get_list(n, "flags", &value));
+	T_ASSERT(value->next == NULL); /* an empty list */
+	T_ASSERT(dm_config_get_list(n, "status", &value));
+	T_ASSERT(value->next != NULL); /* a non-empty list */
+
+	dm_config_destroy(tree);
+}
+
+static void test_cascade(void *fixture)
+{
+	struct dm_config_tree *t1 = dm_config_from_string(conf),
+		              *t2 = dm_config_from_string(overlay),
+		              *tree = dm_config_insert_cascaded_tree(t2, t1);
+
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "id", "foo"), "yoda-soda"));
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "idt", "foo"), "foo"));
+
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv0/bb", "foo"), "foo"));
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv1/id", "foo"), "hgfe-dcba"));
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv3/id", "foo"), "dbcd-efgh"));
+
+	dm_config_destroy(t1);
+	dm_config_destroy(t2);
+}
+
+#define T(path, desc, fn) register_test(ts, "/metadata/config/" path, desc, fn)
+
+void config_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("parse", "parsing various", test_parse);
+	T("clone", "duplicating a config tree", test_clone);
+	T("cascade", "cascade", test_cascade);
+
+	dm_list_add(all_tests, &ts->list);
+};
diff --git a/unit-test/dmlist_t.c b/unit-test/dmlist_t.c
new file mode 100644
index 0000000..82789ba
--- /dev/null
+++ b/unit-test/dmlist_t.c
@@ -0,0 +1,49 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+static void test_dmlist_splice(void *fixture)
+{
+	unsigned i;
+	struct dm_list a[10];
+	struct dm_list list1;
+	struct dm_list list2;
+
+	dm_list_init(&list1);
+	dm_list_init(&list2);
+
+	for (i = 0; i < DM_ARRAY_SIZE@; i++)
+		dm_list_add(&list1, &a[i]);
+
+	dm_list_splice(&list2, &list1);
+	T_ASSERT(dm_list_size(&list1) == 0);
+	T_ASSERT(dm_list_size(&list2) == 10);
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/data-struct/list/" path, desc, fn)
+
+void dm_list_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(NULL, NULL);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("splice", "joining lists together", test_dmlist_splice);
+
+	dm_list_add(all_tests, &ts->list);
+}
diff --git a/unit-test/dmstatus_t.c b/unit-test/dmstatus_t.c
new file mode 100644
index 0000000..4b57f29
--- /dev/null
+++ b/unit-test/dmstatus_t.c
@@ -0,0 +1,84 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+static void *_mem_init(void)
+{
+	struct dm_pool *mem = dm_pool_create("dmstatus test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+static void _test_mirror_status(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+	struct dm_status_mirror *s = NULL;
+
+	T_ASSERT(dm_get_status_mirror(mem,
+				       "2 253:1 253:2 80/81 1 AD 3 disk 253:0 A",
+				       &s));
+	if (s) {
+		T_ASSERT_EQUAL(s->total_regions, 81);
+		T_ASSERT_EQUAL(s->insync_regions, 80);
+		T_ASSERT_EQUAL(s->dev_count, 2);
+		T_ASSERT_EQUAL(s->devs[0].health, 'A');
+		T_ASSERT_EQUAL(s->devs[0].major, 253);
+		T_ASSERT_EQUAL(s->devs[0].minor, 1);
+		T_ASSERT_EQUAL(s->devs[1].health, 'D');
+		T_ASSERT_EQUAL(s->devs[1].major, 253);
+		T_ASSERT_EQUAL(s->devs[1].minor, 2);
+		T_ASSERT_EQUAL(s->log_count, 1);
+		T_ASSERT_EQUAL(s->logs[0].major, 253);
+		T_ASSERT_EQUAL(s->logs[0].minor, 0);
+		T_ASSERT_EQUAL(s->logs[0].health, 'A');
+		T_ASSERT(!strcmp(s->log_type, "disk"));
+	}
+
+	T_ASSERT(dm_get_status_mirror(mem,
+				       "4 253:1 253:2 253:3 253:4 10/10 1 ADFF 1 core",
+				       &s));
+	if (s) {
+		T_ASSERT_EQUAL(s->total_regions, 10);
+		T_ASSERT_EQUAL(s->insync_regions, 10);
+		T_ASSERT_EQUAL(s->dev_count, 4);
+		T_ASSERT_EQUAL(s->devs[3].minor, 4);
+		T_ASSERT_EQUAL(s->devs[3].health, 'F');
+		T_ASSERT_EQUAL(s->log_count, 0);
+		T_ASSERT(!strcmp(s->log_type, "core"));
+	}
+}
+
+void dm_status_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	register_test(ts, "/dm/target/mirror/status", "parsing mirror status", _test_mirror_status);
+	dm_list_add(all_tests, &ts->list);
+}
+
diff --git a/unit-test/framework.c b/unit-test/framework.c
new file mode 100644
index 0000000..de9a8b1
--- /dev/null
+++ b/unit-test/framework.c
@@ -0,0 +1,66 @@
+#include "framework.h"
+
+/*----------------------------------------------------------------
+ * Assertions
+ *--------------------------------------------------------------*/
+
+jmp_buf test_k;
+#define TEST_FAILED 1
+
+void test_fail(const char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vfprintf(stderr, fmt, ap);
+	va_end(ap);
+	fprintf(stderr, "\n");
+
+	longjmp(test_k, TEST_FAILED);
+}
+
+struct test_suite *test_suite_create(void *(*fixture_init)(void),
+				     void (*fixture_exit)(void *))
+{
+	struct test_suite *ts = malloc(sizeof(*ts));
+	if (ts) {
+		ts->fixture_init = fixture_init;
+		ts->fixture_exit = fixture_exit;
+		dm_list_init(&ts->tests);
+	}
+
+	return ts;
+}
+
+void test_suite_destroy(struct test_suite *ts)
+{
+	struct test_details *td, *tmp;
+
+	dm_list_iterate_items_safe (td, tmp, &ts->tests) {
+		dm_list_del(&td->list);
+		free(td);
+	}
+
+	free(ts);
+}
+
+bool register_test(struct test_suite *ts,
+		   const char *path, const char *desc,
+		   void (*fn)(void *))
+{
+	struct test_details *t = malloc(sizeof(*t));
+	if (!t) {
+		fprintf(stderr, "out of memory\n");
+		return false;
+	}
+
+	t->parent = ts;
+	t->path = path;
+	t->desc = desc;
+	t->fn = fn;
+	dm_list_add(&ts->tests, &t->list);
+
+	return true;
+}
+
+//-----------------------------------------------------------------
diff --git a/unit-test/framework.h b/unit-test/framework.h
new file mode 100644
index 0000000..5a33ca6
--- /dev/null
+++ b/unit-test/framework.h
@@ -0,0 +1,49 @@
+#ifndef TEST_UNIT_FRAMEWORK_H
+#define TEST_UNIT_FRAMEWORK_H
+
+#include "libdevmapper.h"
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <setjmp.h>
+
+//-----------------------------------------------------------------
+
+// A test suite gathers a set of tests with a common fixture together.
+struct test_suite {
+	struct dm_list list;
+
+	void *(*fixture_init)(void);
+	void (*fixture_exit)(void *);
+	struct dm_list tests;
+};
+
+struct test_details {
+	struct test_suite *parent;
+	struct dm_list list;
+
+	const char *path;
+	const char *desc;
+	void (*fn)(void *);
+};
+
+struct test_suite *test_suite_create(void *(*fixture_init)(void),
+				     void (*fixture_exit)(void *));
+void test_suite_destroy(struct test_suite *ts);
+
+bool register_test(struct test_suite *ts,
+		   const char *path, const char *desc, void (*fn)(void *));
+
+void test_fail(const char *fmt, ...)
+	__attribute__((noreturn, format (printf, 1, 2)));
+
+#define T_ASSERT(e) do {if (!(e)) {test_fail("assertion failed: '%s'", # e);} } while(0)
+#define T_ASSERT_EQUAL(x, y) T_ASSERT((x) == (y))
+#define T_ASSERT_NOT_EQUAL(x, y) T_ASSERT((x) != (y))
+
+extern jmp_buf test_k;
+#define TEST_FAILED 1
+
+//-----------------------------------------------------------------
+
+#endif
diff --git a/unit-test/matcher_data.h b/unit-test/matcher_data.h
new file mode 100644
index 0000000..97dbbfe
--- /dev/null
+++ b/unit-test/matcher_data.h
@@ -0,0 +1,1013 @@
+struct check_item {
+	const char *str;
+	int expected;
+};
+
+static const char *dev_patterns[] = {
+	"loop/[0-9]+",
+	"hd[a-d][0-5]+",
+	NULL
+};
+
+static const char *nonprint_patterns[] = {
+	"foo\x80" "bar",
+	"foo\xc2" "b",
+	"\x80",
+	NULL
+};
+
+static const struct check_item nonprint[] = {
+	{ "foo\x2e" "bar", 0 },
+	{ "foo\x80" "bar", 3 },
+	{ "foo\xc2" "b", 2 },
+	{ "\x80", 3 },
+	{ NULL, 0 }
+};
+
+static const char *random_patterns[] = {
+	"(((a?)(([Ub]*)|z))((([qr]|X)+)([Qn]*)))+",
+	"[HZejtuw]*",
+	"((B|s)*)|(((([Fv]l)(N+))(([el]|C)(tJ)))?)",
+	"((([Ma]?)|(t*))*)|((([cm]E)|(M?))|(([BE][EV])|([Qj][Mh])))",
+	"(((([bw]*)|([IO]*))((zK)*))|(((pU)|(i|q))|((z?)|([HL]?))))*",
+	"((([Pt]?)|[Tr])?)((Hq)*)",
+	"[HOXcfgikosvwxz]",
+	"[BCEFGHNPTUWfjlprsy]",
+	"((((aD)*)|([Xo]+))+)(([HKn](([Eq]|[JQ])(I*)))*)",
+	"([LNWYeghv]|e)*",
+	"(((y(L*))*)|((([EP]+)(W+))*))*",
+	"U*",
+	"((((R+)(W|[Qr]))|([py]+))+)([LM]*)",
+	"(([DOjx](D(b?)))|([Ke]*))*",
+	"((([ls](c|[FT]))*)([JS]*))*",
+	"((l?)|(([Gz]+)|(D*)))*",
+	"[ABgjn]",
+	"(((q|[dg])?)|([Uk]*))((([Fl]?)|([Ry]+))|(([IR]|c)|(T?)))",
+	"((([an]|P)|[Jw])((a*)|(m*)))*",
+	"((((R[ht])(h+))?)|(([pz](n?))+))+",
+	"(((([Dc]b)([Sp][Ii]))|((k|F)*))|[Uiovz])*",
+	"[Res]*",
+	"[Zl]|a",
+	"^[ANZdf]$",
+	"[En]|(((Q+)(U+))([pt]*))",
+	"[ADEIMQUWXZhklrsvz]",
+	"(((S(y*))*)|(j*))*",
+	"n*",
+	"[NUau]*",
+	"((((Z*)(D|[Nd]))|(([np]|B)+))|(([Xy][Fi])*))+",
+	"((([EZ]?)|(d[HR]))*)((([Hg]|q)(P+))*)",
+	"q",
+	"((m*)|(p|B))|((((x?)|(t+))(([Sb][PX])(O|[HM])))+)",
+	"((((A*)(z[RS]))*)|(((z+)(Q*))+))*",
+	"(((M*)([Uu]*))+)|[Uk]",
+	"[imv]",
+	"[GLSchtw](([Yw]((F[Dd])|([Tw]+)))?)",
+	"([MOZj]*)(S|[Wknr])",
+	"((G|q)*)[BHKN]",
+	"((((NW)|([Ao]?))|((l|[UV])+))+)|((i|(z*))*)",
+	"((((Z+)|([IR]?))|(L*))|([JKQ]+))+",
+	"([Bdin](S*))+",
+	"[HLNSTp]*",
+	"(((J*)([Bq]|[Yu]))*)|([Kv]*)",
+	"(((([BJ]|[Zy])(wI))*)(y*))+",
+	"(((hF)+)|(H*))*",
+	"((([QU][Pj])([GQ]?))+)|[PWo]",
+	"(((([cq][BX])?)|((f[DI])*))*)(([GM]*)[SVYr])",
+	"(([Zt]*)|((qx)|(([BV]+)(f?))))*",
+	"[ILWYhsx]*",
+	"(([Uy]*)|[sv])|([NSc]*)",
+	"((c*)|([JUfhy]?))+",
+	"(((q*)([So]*))(((g[jq])(j?))+))*",
+	"((b+)|(((T+)([fw]T))?))*",
+	"((([DS]?)|([Th]|u))(Q*))*",
+	"[FKLX]|((([fw](L?))(([gq]*)|(O?)))?)",
+	"((([HZ]+)u)*)|[APWijn]",
+	"(e*)|(((v?)|((J+)(Hb)))?)",
+	"(e|((w+)f))*",
+	"[BEHKPQVdelnqy]",
+	"((((B|N)(s*))|[Rr])(((g?)|([rv]+))+))+",
+	"(((s*)|(K*))([AP]G))*",
+	"[CELTp]",
+	"(([Fq]?)|([Al]+))*",
+	"((((r?)|(y[jx]))|([mp]*))+)|((B(S*))*)",
+	"((([Eq]+)|(Y[ds]))|(x|(i|[Ku])))[IJNrvy]",
+	"((([NO]*)[Ix])+)([Jenq]+)",
+	"(((([HP]*)(j|y))*)[Ylqvy])*",
+	"[PTv]+",
+	"[AINSZhpx]|([EOYZ]*)",
+	"([ABCFQv]*)((([Zx]|h)+)|([ej]*))",
+	"((([pr]*)|(([Dq]|p)|(H?)))?)([NRUXmoq]*)",
+	"(([er]*)|([mx]*))(((nV)([am]?))+)",
+	"[BHPRlpu]",
+	"(((([Ah]|[tx])|(e|[uy]))?)((([fl]+)([Vz]|v))*))*",
+	"[AGdm]",
+	"(((K*)^(O*)$)|(B?))*",
+	"((([Ks]|[Ka])*)|([FSTab]?))?",
+	"(([kw]+)[ei])(([Hy]*)(([Mc]*)|(G|f)))",
+	"((((e*)|(Zf))|(R|[nq]))((([Jz]v)([Rj]+))+))*",
+	"(((a?)|(e?))(([Uc]*)(S+)))*",
+	"((((E+)([MZ]?))+)|(((s|[Az])|z)*))?",
+	"((((i[MO])*)|((LH)*))|(((BA)|([AI]+))|[Ug]))*",
+	"[EGHILcho]*",
+	"(((Z[vw])?)((z|g)+))(((H|U)([iv]Q))|([qw]?))",
+	"(([ehmr]|((L[Uw])*))+)((a+)I)",
+	"[EKNSWYagj](((v|[TX])|([Uk]+))*)",
+	"(((R[Mo])|(O*))|([Fm]|([qw]*)))((m*)|((S|[Ki])?))",
+	"((((kP)|c)?)((([do]+)|([Gi]?))*))*",
+	"((^(B|W)$|([Ww]+))([no]*))|((([iv]?)|(M*))|((x|L)?))",
+	"[AEGPRSbcfhsy]",
+	"[Wbcf]|((([MO]?)|([NT]|m))(([Oo]?)([Wg]*)))",
+	"(((YZ)*)[PQVei])*",
+	"[GJKYt][AEGWdegmnt]",
+	"^[CDEGJKNUVYZagkv]$",
+	"([DPWbx]*)|(((q|B)|(P|u))((M[Bq])*))",
+	"[FHIJRTVYZdiorsuvz]*",
+	"([MWoqvz]*)|^(l*)",
+	"(((I|[Rx])*)((X[Mf])([Xa]L)))([Ha]|([HY]*))",
+	"(((l|[Sd])*)((([Ix]+)|([XY]?))(Z*)))+",
+	NULL
+};
+
+struct check_item devices[] = {
+	{ "/dev", 0 },
+	{ "/dev/.devfsd", 0 },
+	{ "/dev/cpu", 0 },
+	{ "/dev/cpu/mtrr", 0 },
+	{ "/dev/netlink", 0 },
+	{ "/dev/netlink/route", 0 },
+	{ "/dev/netlink/skip", 0 },
+	{ "/dev/netlink/USERSOCK", 0 },
+	{ "/dev/netlink/fwmonitor", 0 },
+	{ "/dev/netlink/ARPD", 0 },
+	{ "/dev/netlink/ROUTE6", 0 },
+	{ "/dev/netlink/IP6_FW", 0 },
+	{ "/dev/netlink/tap0", 0 },
+	{ "/dev/netlink/tap1", 0 },
+	{ "/dev/netlink/tap2", 0 },
+	{ "/dev/netlink/tap3", 0 },
+	{ "/dev/netlink/tap4", 0 },
+	{ "/dev/netlink/tap5", 0 },
+	{ "/dev/netlink/tap6", 0 },
+	{ "/dev/netlink/tap7", 0 },
+	{ "/dev/netlink/tap8", 0 },
+	{ "/dev/netlink/tap9", 0 },
+	{ "/dev/netlink/tap10", 0 },
+	{ "/dev/netlink/tap11", 0 },
+	{ "/dev/netlink/tap12", 0 },
+	{ "/dev/netlink/tap13", 0 },
+	{ "/dev/netlink/tap14", 0 },
+	{ "/dev/netlink/tap15", 0 },
+	{ "/dev/shm", 0 },
+	{ "/dev/mem", 0 },
+	{ "/dev/kmem", 0 },
+	{ "/dev/null", 0 },
+	{ "/dev/port", 0 },
+	{ "/dev/zero", 0 },
+	{ "/dev/full", 0 },
+	{ "/dev/random", 0 },
+	{ "/dev/urandom", 0 },
+	{ "/dev/tty", 0 },
+	{ "/dev/console", 0 },
+	{ "/dev/vc", 0 },
+	{ "/dev/vc/1", 0 },
+	{ "/dev/vc/2", 0 },
+	{ "/dev/vc/3", 0 },
+	{ "/dev/vc/4", 0 },
+	{ "/dev/vc/5", 0 },
+	{ "/dev/vc/6", 0 },
+	{ "/dev/vc/7", 0 },
+	{ "/dev/vc/8", 0 },
+	{ "/dev/vc/9", 0 },
+	{ "/dev/vc/10", 0 },
+	{ "/dev/vc/11", 0 },
+	{ "/dev/vc/12", 0 },
+	{ "/dev/vc/13", 0 },
+	{ "/dev/vc/14", 0 },
+	{ "/dev/vc/15", 0 },
+	{ "/dev/vc/16", 0 },
+	{ "/dev/vc/17", 0 },
+	{ "/dev/vc/18", 0 },
+	{ "/dev/vc/19", 0 },
+	{ "/dev/vc/20", 0 },
+	{ "/dev/vc/21", 0 },
+	{ "/dev/vc/22", 0 },
+	{ "/dev/vc/23", 0 },
+	{ "/dev/vc/24", 0 },
+	{ "/dev/vc/25", 0 },
+	{ "/dev/vc/26", 0 },
+	{ "/dev/vc/27", 0 },
+	{ "/dev/vc/28", 0 },
+	{ "/dev/vc/29", 0 },
+	{ "/dev/vc/30", 0 },
+	{ "/dev/vc/31", 0 },
+	{ "/dev/vc/32", 0 },
+	{ "/dev/vc/33", 0 },
+	{ "/dev/vc/34", 0 },
+	{ "/dev/vc/35", 0 },
+	{ "/dev/vc/36", 0 },
+	{ "/dev/vc/37", 0 },
+	{ "/dev/vc/38", 0 },
+	{ "/dev/vc/39", 0 },
+	{ "/dev/vc/40", 0 },
+	{ "/dev/vc/41", 0 },
+	{ "/dev/vc/42", 0 },
+	{ "/dev/vc/43", 0 },
+	{ "/dev/vc/44", 0 },
+	{ "/dev/vc/45", 0 },
+	{ "/dev/vc/46", 0 },
+	{ "/dev/vc/47", 0 },
+	{ "/dev/vc/48", 0 },
+	{ "/dev/vc/49", 0 },
+	{ "/dev/vc/50", 0 },
+	{ "/dev/vc/51", 0 },
+	{ "/dev/vc/52", 0 },
+	{ "/dev/vc/53", 0 },
+	{ "/dev/vc/54", 0 },
+	{ "/dev/vc/55", 0 },
+	{ "/dev/vc/56", 0 },
+	{ "/dev/vc/57", 0 },
+	{ "/dev/vc/58", 0 },
+	{ "/dev/vc/59", 0 },
+	{ "/dev/vc/60", 0 },
+	{ "/dev/vc/61", 0 },
+	{ "/dev/vc/62", 0 },
+	{ "/dev/vc/63", 0 },
+	{ "/dev/vc/0", 0 },
+	{ "/dev/ptmx", 0 },
+	{ "/dev/misc", 0 },
+	{ "/dev/misc/psaux", 0 },
+	{ "/dev/pty", 0 },
+	{ "/dev/pty/m0", 0 },
+	{ "/dev/pty/m1", 0 },
+	{ "/dev/pty/m2", 0 },
+	{ "/dev/pty/m3", 0 },
+	{ "/dev/pty/m4", 0 },
+	{ "/dev/pty/m5", 0 },
+	{ "/dev/pty/m6", 0 },
+	{ "/dev/pty/m7", 0 },
+	{ "/dev/pty/m8", 0 },
+	{ "/dev/pty/m9", 0 },
+	{ "/dev/pty/m10", 0 },
+	{ "/dev/pty/m11", 0 },
+	{ "/dev/pty/m12", 0 },
+	{ "/dev/pty/m13", 0 },
+	{ "/dev/pty/m14", 0 },
+	{ "/dev/pty/m15", 0 },
+	{ "/dev/pty/m16", 0 },
+	{ "/dev/pty/m17", 0 },
+	{ "/dev/pty/m18", 0 },
+	{ "/dev/pty/m19", 0 },
+	{ "/dev/pty/m20", 0 },
+	{ "/dev/pty/m21", 0 },
+	{ "/dev/pty/m22", 0 },
+	{ "/dev/pty/m23", 0 },
+	{ "/dev/pty/m24", 0 },
+	{ "/dev/pty/m25", 0 },
+	{ "/dev/pty/m26", 0 },
+	{ "/dev/pty/m27", 0 },
+	{ "/dev/pty/m28", 0 },
+	{ "/dev/pty/m29", 0 },
+	{ "/dev/pty/m30", 0 },
+	{ "/dev/pty/m31", 0 },
+	{ "/dev/pty/m32", 0 },
+	{ "/dev/pty/m33", 0 },
+	{ "/dev/pty/m34", 0 },
+	{ "/dev/pty/m35", 0 },
+	{ "/dev/pty/m36", 0 },
+	{ "/dev/pty/m37", 0 },
+	{ "/dev/pty/m38", 0 },
+	{ "/dev/pty/m39", 0 },
+	{ "/dev/pty/m40", 0 },
+	{ "/dev/pty/m41", 0 },
+	{ "/dev/pty/m42", 0 },
+	{ "/dev/pty/m43", 0 },
+	{ "/dev/pty/m44", 0 },
+	{ "/dev/pty/m45", 0 },
+	{ "/dev/pty/m46", 0 },
+	{ "/dev/pty/m47", 0 },
+	{ "/dev/pty/m48", 0 },
+	{ "/dev/pty/m49", 0 },
+	{ "/dev/pty/m50", 0 },
+	{ "/dev/pty/m51", 0 },
+	{ "/dev/pty/m52", 0 },
+	{ "/dev/pty/m53", 0 },
+	{ "/dev/pty/m54", 0 },
+	{ "/dev/pty/m55", 0 },
+	{ "/dev/pty/m56", 0 },
+	{ "/dev/pty/m57", 0 },
+	{ "/dev/pty/m58", 0 },
+	{ "/dev/pty/m59", 0 },
+	{ "/dev/pty/m60", 0 },
+	{ "/dev/pty/m61", 0 },
+	{ "/dev/pty/m62", 0 },
+	{ "/dev/pty/m63", 0 },
+	{ "/dev/pty/m64", 0 },
+	{ "/dev/pty/m65", 0 },
+	{ "/dev/pty/m66", 0 },
+	{ "/dev/pty/m67", 0 },
+	{ "/dev/pty/m68", 0 },
+	{ "/dev/pty/m69", 0 },
+	{ "/dev/pty/m70", 0 },
+	{ "/dev/pty/m71", 0 },
+	{ "/dev/pty/m72", 0 },
+	{ "/dev/pty/m73", 0 },
+	{ "/dev/pty/m74", 0 },
+	{ "/dev/pty/m75", 0 },
+	{ "/dev/pty/m76", 0 },
+	{ "/dev/pty/m77", 0 },
+	{ "/dev/pty/m78", 0 },
+	{ "/dev/pty/m79", 0 },
+	{ "/dev/pty/m80", 0 },
+	{ "/dev/pty/m81", 0 },
+	{ "/dev/pty/m82", 0 },
+	{ "/dev/pty/m83", 0 },
+	{ "/dev/pty/m84", 0 },
+	{ "/dev/pty/m85", 0 },
+	{ "/dev/pty/m86", 0 },
+	{ "/dev/pty/m87", 0 },
+	{ "/dev/pty/m88", 0 },
+	{ "/dev/pty/m89", 0 },
+	{ "/dev/pty/m90", 0 },
+	{ "/dev/pty/m91", 0 },
+	{ "/dev/pty/m92", 0 },
+	{ "/dev/pty/m93", 0 },
+	{ "/dev/pty/m94", 0 },
+	{ "/dev/pty/m95", 0 },
+	{ "/dev/pty/m96", 0 },
+	{ "/dev/pty/m97", 0 },
+	{ "/dev/pty/m98", 0 },
+	{ "/dev/pty/m99", 0 },
+	{ "/dev/pty/m100", 0 },
+	{ "/dev/pty/m101", 0 },
+	{ "/dev/pty/m102", 0 },
+	{ "/dev/pty/m103", 0 },
+	{ "/dev/pty/m104", 0 },
+	{ "/dev/pty/m105", 0 },
+	{ "/dev/pty/m106", 0 },
+	{ "/dev/pty/m107", 0 },
+	{ "/dev/pty/m108", 0 },
+	{ "/dev/pty/m109", 0 },
+	{ "/dev/pty/m110", 0 },
+	{ "/dev/pty/m111", 0 },
+	{ "/dev/pty/m112", 0 },
+	{ "/dev/pty/m113", 0 },
+	{ "/dev/pty/m114", 0 },
+	{ "/dev/pty/m115", 0 },
+	{ "/dev/pty/m116", 0 },
+	{ "/dev/pty/m117", 0 },
+	{ "/dev/pty/m118", 0 },
+	{ "/dev/pty/m119", 0 },
+	{ "/dev/pty/m120", 0 },
+	{ "/dev/pty/m121", 0 },
+	{ "/dev/pty/m122", 0 },
+	{ "/dev/pty/m123", 0 },
+	{ "/dev/pty/m124", 0 },
+	{ "/dev/pty/m125", 0 },
+	{ "/dev/pty/m126", 0 },
+	{ "/dev/pty/m127", 0 },
+	{ "/dev/pty/m128", 0 },
+	{ "/dev/pty/m129", 0 },
+	{ "/dev/pty/m130", 0 },
+	{ "/dev/pty/m131", 0 },
+	{ "/dev/pty/m132", 0 },
+	{ "/dev/pty/m133", 0 },
+	{ "/dev/pty/m134", 0 },
+	{ "/dev/pty/m135", 0 },
+	{ "/dev/pty/m136", 0 },
+	{ "/dev/pty/m137", 0 },
+	{ "/dev/pty/m138", 0 },
+	{ "/dev/pty/m139", 0 },
+	{ "/dev/pty/m140", 0 },
+	{ "/dev/pty/m141", 0 },
+	{ "/dev/pty/m142", 0 },
+	{ "/dev/pty/m143", 0 },
+	{ "/dev/pty/m144", 0 },
+	{ "/dev/pty/m145", 0 },
+	{ "/dev/pty/m146", 0 },
+	{ "/dev/pty/m147", 0 },
+	{ "/dev/pty/m148", 0 },
+	{ "/dev/pty/m149", 0 },
+	{ "/dev/pty/m150", 0 },
+	{ "/dev/pty/m151", 0 },
+	{ "/dev/pty/m152", 0 },
+	{ "/dev/pty/m153", 0 },
+	{ "/dev/pty/m154", 0 },
+	{ "/dev/pty/m155", 0 },
+	{ "/dev/pty/m156", 0 },
+	{ "/dev/pty/m157", 0 },
+	{ "/dev/pty/m158", 0 },
+	{ "/dev/pty/m159", 0 },
+	{ "/dev/pty/m160", 0 },
+	{ "/dev/pty/m161", 0 },
+	{ "/dev/pty/m162", 0 },
+	{ "/dev/pty/m163", 0 },
+	{ "/dev/pty/m164", 0 },
+	{ "/dev/pty/m165", 0 },
+	{ "/dev/pty/m166", 0 },
+	{ "/dev/pty/m167", 0 },
+	{ "/dev/pty/m168", 0 },
+	{ "/dev/pty/m169", 0 },
+	{ "/dev/pty/m170", 0 },
+	{ "/dev/pty/m171", 0 },
+	{ "/dev/pty/m172", 0 },
+	{ "/dev/pty/m173", 0 },
+	{ "/dev/pty/m174", 0 },
+	{ "/dev/pty/m175", 0 },
+	{ "/dev/pty/m176", 0 },
+	{ "/dev/pty/m177", 0 },
+	{ "/dev/pty/m178", 0 },
+	{ "/dev/pty/m179", 0 },
+	{ "/dev/pty/m180", 0 },
+	{ "/dev/pty/m181", 0 },
+	{ "/dev/pty/m182", 0 },
+	{ "/dev/pty/m183", 0 },
+	{ "/dev/pty/m184", 0 },
+	{ "/dev/pty/m185", 0 },
+	{ "/dev/pty/m186", 0 },
+	{ "/dev/pty/m187", 0 },
+	{ "/dev/pty/m188", 0 },
+	{ "/dev/pty/m189", 0 },
+	{ "/dev/pty/m190", 0 },
+	{ "/dev/pty/m191", 0 },
+	{ "/dev/pty/m192", 0 },
+	{ "/dev/pty/m193", 0 },
+	{ "/dev/pty/m194", 0 },
+	{ "/dev/pty/m195", 0 },
+	{ "/dev/pty/m196", 0 },
+	{ "/dev/pty/m197", 0 },
+	{ "/dev/pty/m198", 0 },
+	{ "/dev/pty/m199", 0 },
+	{ "/dev/pty/m200", 0 },
+	{ "/dev/pty/m201", 0 },
+	{ "/dev/pty/m202", 0 },
+	{ "/dev/pty/m203", 0 },
+	{ "/dev/pty/m204", 0 },
+	{ "/dev/pty/m205", 0 },
+	{ "/dev/pty/m206", 0 },
+	{ "/dev/pty/m207", 0 },
+	{ "/dev/pty/m208", 0 },
+	{ "/dev/pty/m209", 0 },
+	{ "/dev/pty/m210", 0 },
+	{ "/dev/pty/m211", 0 },
+	{ "/dev/pty/m212", 0 },
+	{ "/dev/pty/m213", 0 },
+	{ "/dev/pty/m214", 0 },
+	{ "/dev/pty/m215", 0 },
+	{ "/dev/pty/m216", 0 },
+	{ "/dev/pty/m217", 0 },
+	{ "/dev/pty/m218", 0 },
+	{ "/dev/pty/m219", 0 },
+	{ "/dev/pty/m220", 0 },
+	{ "/dev/pty/m221", 0 },
+	{ "/dev/pty/m222", 0 },
+	{ "/dev/pty/m223", 0 },
+	{ "/dev/pty/m224", 0 },
+	{ "/dev/pty/m225", 0 },
+	{ "/dev/pty/m226", 0 },
+	{ "/dev/pty/m227", 0 },
+	{ "/dev/pty/m228", 0 },
+	{ "/dev/pty/m229", 0 },
+	{ "/dev/pty/m230", 0 },
+	{ "/dev/pty/m231", 0 },
+	{ "/dev/pty/m232", 0 },
+	{ "/dev/pty/m233", 0 },
+	{ "/dev/pty/m234", 0 },
+	{ "/dev/pty/m235", 0 },
+	{ "/dev/pty/m236", 0 },
+	{ "/dev/pty/m237", 0 },
+	{ "/dev/pty/m238", 0 },
+	{ "/dev/pty/m239", 0 },
+	{ "/dev/pty/m240", 0 },
+	{ "/dev/pty/m241", 0 },
+	{ "/dev/pty/m242", 0 },
+	{ "/dev/pty/m243", 0 },
+	{ "/dev/pty/m244", 0 },
+	{ "/dev/pty/m245", 0 },
+	{ "/dev/pty/m246", 0 },
+	{ "/dev/pty/m247", 0 },
+	{ "/dev/pty/m248", 0 },
+	{ "/dev/pty/m249", 0 },
+	{ "/dev/pty/m250", 0 },
+	{ "/dev/pty/m251", 0 },
+	{ "/dev/pty/m252", 0 },
+	{ "/dev/pty/m253", 0 },
+	{ "/dev/pty/m254", 0 },
+	{ "/dev/pty/m255", 0 },
+	{ "/dev/pts", 0 },
+	{ "/dev/pts/0", 0 },
+	{ "/dev/pts/1", 0 },
+	{ "/dev/pts/2", 0 },
+	{ "/dev/pts/3", 0 },
+	{ "/dev/pts/4", 0 },
+	{ "/dev/pts/5", 0 },
+	{ "/dev/pts/6", 0 },
+	{ "/dev/pts/7", 0 },
+	{ "/dev/vcc", 0 },
+	{ "/dev/vcc/0", 0 },
+	{ "/dev/vcc/a", 0 },
+	{ "/dev/vcc/1", 0 },
+	{ "/dev/vcc/a1", 0 },
+	{ "/dev/vcc/2", 0 },
+	{ "/dev/vcc/a2", 0 },
+	{ "/dev/vcc/3", 0 },
+	{ "/dev/vcc/a3", 0 },
+	{ "/dev/vcc/5", 0 },
+	{ "/dev/vcc/a5", 0 },
+	{ "/dev/vcc/4", 0 },
+	{ "/dev/vcc/a4", 0 },
+	{ "/dev/vcc/6", 0 },
+	{ "/dev/vcc/a6", 0 },
+	{ "/dev/vcc/7", 0 },
+	{ "/dev/vcc/a7", 0 },
+	{ "/dev/tts", 0 },
+	{ "/dev/tts/0", 0 },
+	{ "/dev/cua", 0 },
+	{ "/dev/cua/0", 0 },
+	{ "/dev/ide", 0 },
+	{ "/dev/ide/host0", 0 },
+	{ "/dev/ide/host0/bus0", 0 },
+	{ "/dev/ide/host0/bus0/target0", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/disc", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part1", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part2", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part3", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part4", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part5", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part6", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part7", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part8", 0 },
+	{ "/dev/ide/host0/bus0/target1", 0 },
+	{ "/dev/ide/host0/bus0/target1/lun0", 0 },
+	{ "/dev/ide/host0/bus0/target1/lun0/disc", 0 },
+	{ "/dev/ide/host0/bus0/target1/lun0/part1", 0 },
+	{ "/dev/ide/host0/bus1", 0 },
+	{ "/dev/ide/host0/bus1/target0", 0 },
+	{ "/dev/ide/host0/bus1/target0/lun0", 0 },
+	{ "/dev/ide/host0/bus1/target0/lun0/disc", 0 },
+	{ "/dev/ide/host0/bus1/target0/lun0/part1", 0 },
+	{ "/dev/ide/host0/bus1/target1", 0 },
+	{ "/dev/ide/host0/bus1/target1/lun0", 0 },
+	{ "/dev/discs", 0 },
+	{ "/dev/discs/disc0", 0 },
+	{ "/dev/discs/disc1", 0 },
+	{ "/dev/discs/disc2", 0 },
+	{ "/dev/floppy", 0 },
+	{ "/dev/floppy/0u1440", 0 },
+	{ "/dev/floppy/0u1680", 0 },
+	{ "/dev/floppy/0u1722", 0 },
+	{ "/dev/floppy/0u1743", 0 },
+	{ "/dev/floppy/0u1760", 0 },
+	{ "/dev/floppy/0u1920", 0 },
+	{ "/dev/floppy/0u1840", 0 },
+	{ "/dev/floppy/0u1600", 0 },
+	{ "/dev/floppy/0u360", 0 },
+	{ "/dev/floppy/0u720", 0 },
+	{ "/dev/floppy/0u820", 0 },
+	{ "/dev/floppy/0u830", 0 },
+	{ "/dev/floppy/0u1040", 0 },
+	{ "/dev/floppy/0u1120", 0 },
+	{ "/dev/floppy/0u800", 0 },
+	{ "/dev/floppy/0", 0 },
+	{ "/dev/loop", 0 },
+	{ "/dev/loop/0", 1 },
+	{ "/dev/loop/1", 1 },
+	{ "/dev/loop/2", 1 },
+	{ "/dev/loop/3", 1 },
+	{ "/dev/loop/4", 1 },
+	{ "/dev/loop/5", 1 },
+	{ "/dev/loop/6", 1 },
+	{ "/dev/loop/7", 1 },
+	{ "/dev/cdroms", 0 },
+	{ "/dev/sound", 0 },
+	{ "/dev/sound/dsp", 0 },
+	{ "/dev/sound/dsp1", 0 },
+	{ "/dev/sound/mixer", 0 },
+	{ "/dev/sound/midi", 0 },
+	{ "/dev/usb", 0 },
+	{ "/dev/root", 0 },
+	{ "/dev/initctl", 0 },
+	{ "/dev/xconsole", 0 },
+	{ "/dev/fd", 0 },
+	{ "/dev/stdin", 0 },
+	{ "/dev/stdout", 0 },
+	{ "/dev/stderr", 0 },
+	{ "/dev/route", 0 },
+	{ "/dev/skip", 0 },
+	{ "/dev/USERSOCK", 0 },
+	{ "/dev/fwmonitor", 0 },
+	{ "/dev/ARPD", 0 },
+	{ "/dev/ROUTE6", 0 },
+	{ "/dev/IP6_FW", 0 },
+	{ "/dev/tap0", 0 },
+	{ "/dev/tap1", 0 },
+	{ "/dev/tap2", 0 },
+	{ "/dev/tap3", 0 },
+	{ "/dev/tap4", 0 },
+	{ "/dev/tap5", 0 },
+	{ "/dev/tap6", 0 },
+	{ "/dev/tap7", 0 },
+	{ "/dev/tap8", 0 },
+	{ "/dev/tap9", 0 },
+	{ "/dev/tap10", 0 },
+	{ "/dev/tap11", 0 },
+	{ "/dev/tap12", 0 },
+	{ "/dev/tap13", 0 },
+	{ "/dev/tap14", 0 },
+	{ "/dev/tap15", 0 },
+	{ "/dev/tty1", 0 },
+	{ "/dev/tty2", 0 },
+	{ "/dev/tty3", 0 },
+	{ "/dev/tty4", 0 },
+	{ "/dev/tty5", 0 },
+	{ "/dev/tty6", 0 },
+	{ "/dev/tty7", 0 },
+	{ "/dev/tty8", 0 },
+	{ "/dev/tty9", 0 },
+	{ "/dev/tty10", 0 },
+	{ "/dev/tty11", 0 },
+	{ "/dev/tty12", 0 },
+	{ "/dev/tty13", 0 },
+	{ "/dev/tty14", 0 },
+	{ "/dev/tty15", 0 },
+	{ "/dev/tty16", 0 },
+	{ "/dev/tty17", 0 },
+	{ "/dev/tty18", 0 },
+	{ "/dev/tty19", 0 },
+	{ "/dev/tty20", 0 },
+	{ "/dev/tty21", 0 },
+	{ "/dev/tty22", 0 },
+	{ "/dev/tty23", 0 },
+	{ "/dev/tty24", 0 },
+	{ "/dev/tty25", 0 },
+	{ "/dev/tty26", 0 },
+	{ "/dev/tty27", 0 },
+	{ "/dev/tty28", 0 },
+	{ "/dev/tty29", 0 },
+	{ "/dev/tty30", 0 },
+	{ "/dev/tty31", 0 },
+	{ "/dev/tty32", 0 },
+	{ "/dev/tty33", 0 },
+	{ "/dev/tty34", 0 },
+	{ "/dev/tty35", 0 },
+	{ "/dev/tty36", 0 },
+	{ "/dev/tty37", 0 },
+	{ "/dev/tty38", 0 },
+	{ "/dev/tty39", 0 },
+	{ "/dev/tty40", 0 },
+	{ "/dev/tty41", 0 },
+	{ "/dev/tty42", 0 },
+	{ "/dev/tty43", 0 },
+	{ "/dev/tty44", 0 },
+	{ "/dev/tty45", 0 },
+	{ "/dev/tty46", 0 },
+	{ "/dev/tty47", 0 },
+	{ "/dev/tty48", 0 },
+	{ "/dev/tty49", 0 },
+	{ "/dev/tty50", 0 },
+	{ "/dev/tty51", 0 },
+	{ "/dev/tty52", 0 },
+	{ "/dev/tty53", 0 },
+	{ "/dev/tty54", 0 },
+	{ "/dev/tty55", 0 },
+	{ "/dev/tty56", 0 },
+	{ "/dev/tty57", 0 },
+	{ "/dev/tty58", 0 },
+	{ "/dev/tty59", 0 },
+	{ "/dev/tty60", 0 },
+	{ "/dev/tty61", 0 },
+	{ "/dev/tty62", 0 },
+	{ "/dev/tty63", 0 },
+	{ "/dev/tty0", 0 },
+	{ "/dev/psaux", 0 },
+	{ "/dev/ptyp0", 0 },
+	{ "/dev/ptyp1", 0 },
+	{ "/dev/ptyp2", 0 },
+	{ "/dev/ptyp3", 0 },
+	{ "/dev/ptyp4", 0 },
+	{ "/dev/ptyp5", 0 },
+	{ "/dev/ptyp6", 0 },
+	{ "/dev/ptyp7", 0 },
+	{ "/dev/ptyp8", 0 },
+	{ "/dev/ptyp9", 0 },
+	{ "/dev/ptypa", 0 },
+	{ "/dev/ptypb", 0 },
+	{ "/dev/ptypc", 0 },
+	{ "/dev/ptypd", 0 },
+	{ "/dev/ptype", 0 },
+	{ "/dev/ptypf", 0 },
+	{ "/dev/ptyq0", 0 },
+	{ "/dev/ptyq1", 0 },
+	{ "/dev/ptyq2", 0 },
+	{ "/dev/ptyq3", 0 },
+	{ "/dev/ptyq4", 0 },
+	{ "/dev/ptyq5", 0 },
+	{ "/dev/ptyq6", 0 },
+	{ "/dev/ptyq7", 0 },
+	{ "/dev/ptyq8", 0 },
+	{ "/dev/ptyq9", 0 },
+	{ "/dev/ptyqa", 0 },
+	{ "/dev/ptyqb", 0 },
+	{ "/dev/ptyqc", 0 },
+	{ "/dev/ptyqd", 0 },
+	{ "/dev/ptyqe", 0 },
+	{ "/dev/ptyqf", 0 },
+	{ "/dev/ptyr0", 0 },
+	{ "/dev/ptyr1", 0 },
+	{ "/dev/ptyr2", 0 },
+	{ "/dev/ptyr3", 0 },
+	{ "/dev/ptyr4", 0 },
+	{ "/dev/ptyr5", 0 },
+	{ "/dev/ptyr6", 0 },
+	{ "/dev/ptyr7", 0 },
+	{ "/dev/ptyr8", 0 },
+	{ "/dev/ptyr9", 0 },
+	{ "/dev/ptyra", 0 },
+	{ "/dev/ptyrb", 0 },
+	{ "/dev/ptyrc", 0 },
+	{ "/dev/ptyrd", 0 },
+	{ "/dev/ptyre", 0 },
+	{ "/dev/ptyrf", 0 },
+	{ "/dev/ptys0", 0 },
+	{ "/dev/ptys1", 0 },
+	{ "/dev/ptys2", 0 },
+	{ "/dev/ptys3", 0 },
+	{ "/dev/ptys4", 0 },
+	{ "/dev/ptys5", 0 },
+	{ "/dev/ptys6", 0 },
+	{ "/dev/ptys7", 0 },
+	{ "/dev/ptys8", 0 },
+	{ "/dev/ptys9", 0 },
+	{ "/dev/ptysa", 0 },
+	{ "/dev/ptysb", 0 },
+	{ "/dev/ptysc", 0 },
+	{ "/dev/ptysd", 0 },
+	{ "/dev/ptyse", 0 },
+	{ "/dev/ptysf", 0 },
+	{ "/dev/ptyt0", 0 },
+	{ "/dev/ptyt1", 0 },
+	{ "/dev/ptyt2", 0 },
+	{ "/dev/ptyt3", 0 },
+	{ "/dev/ptyt4", 0 },
+	{ "/dev/ptyt5", 0 },
+	{ "/dev/ptyt6", 0 },
+	{ "/dev/ptyt7", 0 },
+	{ "/dev/ptyt8", 0 },
+	{ "/dev/ptyt9", 0 },
+	{ "/dev/ptyta", 0 },
+	{ "/dev/ptytb", 0 },
+	{ "/dev/ptytc", 0 },
+	{ "/dev/ptytd", 0 },
+	{ "/dev/ptyte", 0 },
+	{ "/dev/ptytf", 0 },
+	{ "/dev/ptyu0", 0 },
+	{ "/dev/ptyu1", 0 },
+	{ "/dev/ptyu2", 0 },
+	{ "/dev/ptyu3", 0 },
+	{ "/dev/ptyu4", 0 },
+	{ "/dev/ptyu5", 0 },
+	{ "/dev/ptyu6", 0 },
+	{ "/dev/ptyu7", 0 },
+	{ "/dev/ptyu8", 0 },
+	{ "/dev/ptyu9", 0 },
+	{ "/dev/ptyua", 0 },
+	{ "/dev/ptyub", 0 },
+	{ "/dev/ptyuc", 0 },
+	{ "/dev/ptyud", 0 },
+	{ "/dev/ptyue", 0 },
+	{ "/dev/ptyuf", 0 },
+	{ "/dev/ptyv0", 0 },
+	{ "/dev/ptyv1", 0 },
+	{ "/dev/ptyv2", 0 },
+	{ "/dev/ptyv3", 0 },
+	{ "/dev/ptyv4", 0 },
+	{ "/dev/ptyv5", 0 },
+	{ "/dev/ptyv6", 0 },
+	{ "/dev/ptyv7", 0 },
+	{ "/dev/ptyv8", 0 },
+	{ "/dev/ptyv9", 0 },
+	{ "/dev/ptyva", 0 },
+	{ "/dev/ptyvb", 0 },
+	{ "/dev/ptyvc", 0 },
+	{ "/dev/ptyvd", 0 },
+	{ "/dev/ptyve", 0 },
+	{ "/dev/ptyvf", 0 },
+	{ "/dev/ptyw0", 0 },
+	{ "/dev/ptyw1", 0 },
+	{ "/dev/ptyw2", 0 },
+	{ "/dev/ptyw3", 0 },
+	{ "/dev/ptyw4", 0 },
+	{ "/dev/ptyw5", 0 },
+	{ "/dev/ptyw6", 0 },
+	{ "/dev/ptyw7", 0 },
+	{ "/dev/ptyw8", 0 },
+	{ "/dev/ptyw9", 0 },
+	{ "/dev/ptywa", 0 },
+	{ "/dev/ptywb", 0 },
+	{ "/dev/ptywc", 0 },
+	{ "/dev/ptywd", 0 },
+	{ "/dev/ptywe", 0 },
+	{ "/dev/ptywf", 0 },
+	{ "/dev/ptyx0", 0 },
+	{ "/dev/ptyx1", 0 },
+	{ "/dev/ptyx2", 0 },
+	{ "/dev/ptyx3", 0 },
+	{ "/dev/ptyx4", 0 },
+	{ "/dev/ptyx5", 0 },
+	{ "/dev/ptyx6", 0 },
+	{ "/dev/ptyx7", 0 },
+	{ "/dev/ptyx8", 0 },
+	{ "/dev/ptyx9", 0 },
+	{ "/dev/ptyxa", 0 },
+	{ "/dev/ptyxb", 0 },
+	{ "/dev/ptyxc", 0 },
+	{ "/dev/ptyxd", 0 },
+	{ "/dev/ptyxe", 0 },
+	{ "/dev/ptyxf", 0 },
+	{ "/dev/ptyy0", 0 },
+	{ "/dev/ptyy1", 0 },
+	{ "/dev/ptyy2", 0 },
+	{ "/dev/ptyy3", 0 },
+	{ "/dev/ptyy4", 0 },
+	{ "/dev/ptyy5", 0 },
+	{ "/dev/ptyy6", 0 },
+	{ "/dev/ptyy7", 0 },
+	{ "/dev/ptyy8", 0 },
+	{ "/dev/ptyy9", 0 },
+	{ "/dev/ptyya", 0 },
+	{ "/dev/ptyyb", 0 },
+	{ "/dev/ptyyc", 0 },
+	{ "/dev/ptyyd", 0 },
+	{ "/dev/ptyye", 0 },
+	{ "/dev/ptyyf", 0 },
+	{ "/dev/ptyz0", 0 },
+	{ "/dev/ptyz1", 0 },
+	{ "/dev/ptyz2", 0 },
+	{ "/dev/ptyz3", 0 },
+	{ "/dev/ptyz4", 0 },
+	{ "/dev/ptyz5", 0 },
+	{ "/dev/ptyz6", 0 },
+	{ "/dev/ptyz7", 0 },
+	{ "/dev/ptyz8", 0 },
+	{ "/dev/ptyz9", 0 },
+	{ "/dev/ptyza", 0 },
+	{ "/dev/ptyzb", 0 },
+	{ "/dev/ptyzc", 0 },
+	{ "/dev/ptyzd", 0 },
+	{ "/dev/ptyze", 0 },
+	{ "/dev/ptyzf", 0 },
+	{ "/dev/ptya0", 0 },
+	{ "/dev/ptya1", 0 },
+	{ "/dev/ptya2", 0 },
+	{ "/dev/ptya3", 0 },
+	{ "/dev/ptya4", 0 },
+	{ "/dev/ptya5", 0 },
+	{ "/dev/ptya6", 0 },
+	{ "/dev/ptya7", 0 },
+	{ "/dev/ptya8", 0 },
+	{ "/dev/ptya9", 0 },
+	{ "/dev/ptyaa", 0 },
+	{ "/dev/ptyab", 0 },
+	{ "/dev/ptyac", 0 },
+	{ "/dev/ptyad", 0 },
+	{ "/dev/ptyae", 0 },
+	{ "/dev/ptyaf", 0 },
+	{ "/dev/ptyb0", 0 },
+	{ "/dev/ptyb1", 0 },
+	{ "/dev/ptyb2", 0 },
+	{ "/dev/ptyb3", 0 },
+	{ "/dev/ptyb4", 0 },
+	{ "/dev/ptyb5", 0 },
+	{ "/dev/ptyb6", 0 },
+	{ "/dev/ptyb7", 0 },
+	{ "/dev/ptyb8", 0 },
+	{ "/dev/ptyb9", 0 },
+	{ "/dev/ptyba", 0 },
+	{ "/dev/ptybb", 0 },
+	{ "/dev/ptybc", 0 },
+	{ "/dev/ptybd", 0 },
+	{ "/dev/ptybe", 0 },
+	{ "/dev/ptybf", 0 },
+	{ "/dev/ptyc0", 0 },
+	{ "/dev/ptyc1", 0 },
+	{ "/dev/ptyc2", 0 },
+	{ "/dev/ptyc3", 0 },
+	{ "/dev/ptyc4", 0 },
+	{ "/dev/ptyc5", 0 },
+	{ "/dev/ptyc6", 0 },
+	{ "/dev/ptyc7", 0 },
+	{ "/dev/ptyc8", 0 },
+	{ "/dev/ptyc9", 0 },
+	{ "/dev/ptyca", 0 },
+	{ "/dev/ptycb", 0 },
+	{ "/dev/ptycc", 0 },
+	{ "/dev/ptycd", 0 },
+	{ "/dev/ptyce", 0 },
+	{ "/dev/ptycf", 0 },
+	{ "/dev/ptyd0", 0 },
+	{ "/dev/ptyd1", 0 },
+	{ "/dev/ptyd2", 0 },
+	{ "/dev/ptyd3", 0 },
+	{ "/dev/ptyd4", 0 },
+	{ "/dev/ptyd5", 0 },
+	{ "/dev/ptyd6", 0 },
+	{ "/dev/ptyd7", 0 },
+	{ "/dev/ptyd8", 0 },
+	{ "/dev/ptyd9", 0 },
+	{ "/dev/ptyda", 0 },
+	{ "/dev/ptydb", 0 },
+	{ "/dev/ptydc", 0 },
+	{ "/dev/ptydd", 0 },
+	{ "/dev/ptyde", 0 },
+	{ "/dev/ptydf", 0 },
+	{ "/dev/ptye0", 0 },
+	{ "/dev/ptye1", 0 },
+	{ "/dev/ptye2", 0 },
+	{ "/dev/ptye3", 0 },
+	{ "/dev/ptye4", 0 },
+	{ "/dev/ptye5", 0 },
+	{ "/dev/ptye6", 0 },
+	{ "/dev/ptye7", 0 },
+	{ "/dev/ptye8", 0 },
+	{ "/dev/ptye9", 0 },
+	{ "/dev/ptyea", 0 },
+	{ "/dev/ptyeb", 0 },
+	{ "/dev/ptyec", 0 },
+	{ "/dev/ptyed", 0 },
+	{ "/dev/ptyee", 0 },
+	{ "/dev/ptyef", 0 },
+	{ "/dev/vcs", 0 },
+	{ "/dev/vcsa", 0 },
+	{ "/dev/vcs1", 0 },
+	{ "/dev/vcsa1", 0 },
+	{ "/dev/ttyS0", 0 },
+	{ "/dev/cua0", 0 },
+	{ "/dev/hda", 0 },
+	{ "/dev/hda1", 2 },
+	{ "/dev/hda2", 2 },
+	{ "/dev/hda3", 2 },
+	{ "/dev/hda4", 2 },
+	{ "/dev/hda5", 2 },
+	{ "/dev/hda6", 0 },
+	{ "/dev/hda7", 0 },
+	{ "/dev/hda8", 0 },
+	{ "/dev/hdb", 0 },
+	{ "/dev/hdb1", 2 },
+	{ "/dev/hdc", 0 },
+	{ "/dev/hdc1", 2 },
+	{ "/dev/fd0u1440", 0 },
+	{ "/dev/fd0u1680", 0 },
+	{ "/dev/fd0u1722", 0 },
+	{ "/dev/fd0u1743", 0 },
+	{ "/dev/fd0u1760", 0 },
+	{ "/dev/fd0u1920", 0 },
+	{ "/dev/fd0u1840", 0 },
+	{ "/dev/fd0u1600", 0 },
+	{ "/dev/fd0u360", 0 },
+	{ "/dev/fd0u720", 0 },
+	{ "/dev/fd0u820", 0 },
+	{ "/dev/fd0u830", 0 },
+	{ "/dev/fd0u1040", 0 },
+	{ "/dev/fd0u1120", 0 },
+	{ "/dev/fd0u800", 0 },
+	{ "/dev/fd0", 0 },
+	{ "/dev/loop0", 0 },
+	{ "/dev/loop1", 0 },
+	{ "/dev/loop2", 0 },
+	{ "/dev/loop3", 0 },
+	{ "/dev/loop4", 0 },
+	{ "/dev/loop5", 0 },
+	{ "/dev/loop6", 0 },
+	{ "/dev/loop7", 0 },
+	{ "/dev/dsp", 0 },
+	{ "/dev/dsp1", 0 },
+	{ "/dev/mixer", 0 },
+	{ "/dev/midi", 0 },
+	{ "/dev/lvm", 0 },
+	{ "/dev/vg0", 0 },
+	{ "/dev/vg0/group", 0 },
+	{ "/dev/vg0/packages", 0 },
+	{ "/dev/vg0/photos", 0 },
+	{ "/dev/vg0/music", 0 },
+	{ "/dev/log", 0 },
+	{ "/dev/MAKEDEV", 0 },
+	{ "/dev/printer", 0 },
+	{ "/dev/vcs2", 0 },
+	{ "/dev/vcsa2", 0 },
+	{ "/dev/vcs3", 0 },
+	{ "/dev/vcsa3", 0 },
+	{ "/dev/vcs5", 0 },
+	{ "/dev/vcsa5", 0 },
+	{ "/dev/vcs4", 0 },
+	{ "/dev/vcsa4", 0 },
+	{ "/dev/vcs6", 0 },
+	{ "/dev/vcsa6", 0 },
+	{ "/dev/nvidia0", 0 },
+	{ "/dev/nvidia1", 0 },
+	{ "/dev/nvidia2", 0 },
+	{ "/dev/nvidia3", 0 },
+	{ "/dev/nvidiactl", 0 },
+	{ "/dev/vcs7", 0 },
+	{ "/dev/vcsa7", 0 },
+	{ NULL, 0 }
+};
diff --git a/unit-test/matcher_t.c b/unit-test/matcher_t.c
new file mode 100644
index 0000000..a5eb5f9
--- /dev/null
+++ b/unit-test/matcher_t.c
@@ -0,0 +1,89 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+#include "matcher_data.h"
+
+static void *_mem_init(void)
+{
+	struct dm_pool *mem = dm_pool_create("bitset test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+static struct dm_regex *make_scanner(struct dm_pool *mem, const char **rx)
+{
+	struct dm_regex *scanner;
+	int nrx = 0;
+	for (; rx[nrx]; ++nrx);
+
+	scanner = dm_regex_create(mem, rx, nrx);
+	T_ASSERT(scanner != NULL);
+	return scanner;
+}
+
+static void test_fingerprints(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+	struct dm_regex *scanner;
+
+	scanner = make_scanner(mem, dev_patterns);
+	T_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x7f556c09);
+
+	scanner = make_scanner(mem, random_patterns);
+	T_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x9f11076c);
+}
+
+static void test_matching(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+	struct dm_regex *scanner;
+	int i;
+
+	scanner = make_scanner(mem, dev_patterns);
+	for (i = 0; devices[i].str; ++i)
+		T_ASSERT_EQUAL(dm_regex_match(scanner, devices[i].str), devices[i].expected - 1);
+
+	scanner = make_scanner(mem, nonprint_patterns);
+	for (i = 0; nonprint[i].str; ++i)
+		T_ASSERT_EQUAL(dm_regex_match(scanner, nonprint[i].str), nonprint[i].expected - 1);
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/regex/" path, desc, fn)
+
+void regex_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("fingerprints", "not sure", test_fingerprints);
+	T("matching", "test the matcher with a variety of regexes", test_matching);
+
+	dm_list_add(all_tests, &ts->list);
+}
diff --git a/unit-test/percent_t.c b/unit-test/percent_t.c
new file mode 100644
index 0000000..84dd3bd
--- /dev/null
+++ b/unit-test/percent_t.c
@@ -0,0 +1,102 @@
+/*
+ * Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+#include <stdio.h>
+#include <string.h>
+
+static void test_percent_100(void *fixture)
+{
+	char buf[32];
+
+        /* Check 100% is shown only for DM_PERCENT_100*/
+	dm_percent_t p_100 = dm_make_percent(100, 100);
+        dm_percent_t p1_100 = dm_make_percent(100000, 100000);
+        dm_percent_t n_100 = dm_make_percent(999999, 1000000);
+
+	T_ASSERT_EQUAL(p_100, DM_PERCENT_100);
+	T_ASSERT_EQUAL(p1_100, DM_PERCENT_100);
+	T_ASSERT_NOT_EQUAL(n_100, DM_PERCENT_100);
+
+        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_100));
+	T_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_100));
+	T_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_100));
+	T_ASSERT_NOT_EQUAL(strcmp(buf, "99.99"), 0); /* Would like to gett */
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_100, 2));
+	T_ASSERT_EQUAL(strcmp(buf, "99.99"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_100, 3));
+	T_ASSERT_EQUAL(strcmp(buf, "99.999"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.4f", dm_percent_to_round_float(n_100, 4));
+	T_ASSERT_EQUAL(strcmp(buf, "99.9999"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_100, 0));
+	T_ASSERT_EQUAL(strcmp(buf, "99"), 0);
+}
+
+static void test_percent_0(void *fixture)
+{
+	char buf[32];
+
+	/* Check 0% is shown only for DM_PERCENT_0 */
+	dm_percent_t p_0 = dm_make_percent(0, 100);
+        dm_percent_t p1_0 = dm_make_percent(0, 100000);
+        dm_percent_t n_0 = dm_make_percent(1, 1000000);
+
+	T_ASSERT_EQUAL(p_0, DM_PERCENT_0);
+	T_ASSERT_EQUAL(p1_0, DM_PERCENT_0);
+	T_ASSERT_NOT_EQUAL(n_0, DM_PERCENT_0);
+
+        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_0));
+	T_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_0));
+	T_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_0));
+	T_ASSERT_NOT_EQUAL(strcmp(buf, "0.01"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_0, 2));
+	T_ASSERT_EQUAL(strcmp(buf, "0.01"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_0, 3));
+	T_ASSERT_EQUAL(strcmp(buf, "0.001"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_0, 0));
+	T_ASSERT_EQUAL(strcmp(buf, "1"), 0);
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/formatting/percent/" path, desc, fn)
+
+void percent_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(NULL, NULL);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("100", "Pretty printing of percentages near 100%", test_percent_100);
+	T("0", "Pretty printing of percentages near 0%", test_percent_0);
+
+	dm_list_add(all_tests, &ts->list);
+}
diff --git a/unit-test/run.c b/unit-test/run.c
new file mode 100644
index 0000000..9cbb605
--- /dev/null
+++ b/unit-test/run.c
@@ -0,0 +1,309 @@
+#include "units.h"
+
+#include <getopt.h>
+#include <regex.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <setjmp.h>
+#include <unistd.h>
+
+//-----------------------------------------------------------------
+
+#define MAX_COMPONENTS 16
+
+struct token {
+	const char *b, *e;
+};
+
+static bool _pop_component(const char *path, struct token *result)
+{
+	const char *b, *e;
+
+	while (*path && *path == '/')
+		path++;
+
+	b = path;
+	while (*path && (*path != '/'))
+		path++;
+	e = path;
+
+	if (b == e)
+		return false;
+
+	result->b = b;
+	result->e = e;
+	return true;
+}
+
+static unsigned _split_components(const char *path, struct token *toks, unsigned len)
+{
+	unsigned count = 0;
+	struct token tok;
+	tok.e = path;
+
+	while (len && _pop_component(tok.e, &tok)) {
+		*toks = tok;
+		toks++;
+		count++;
+		len--;
+	}
+
+	return count;
+}
+
+static void _indent(FILE *stream, unsigned count)
+{
+	unsigned i;
+
+	for (i = 0; i < count; i++)
+		fprintf(stream, "  ");
+}
+
+static void _print_token(FILE *stream, struct token *t)
+{
+	const char *ptr;
+
+	for (ptr = t->b; ptr != t->e; ptr++)
+		fprintf(stream, "%c", *ptr);
+}
+
+static int _char_cmp(char l, char r)
+{
+	if (l < r)
+		return -1;
+
+	else if (r < l)
+		return 1;
+
+	else
+		return 0;
+}
+
+static int _tok_cmp(struct token *lhs, struct token *rhs)
+{
+	const char *l = lhs->b, *le = lhs->e;
+	const char *r = rhs->b, *re = rhs->e;
+
+	while ((l != le) && (r != re) && (*l == *r)) {
+		l++;
+		r++;
+	}
+
+	if ((l != le) && (r != re))
+		return _char_cmp(*l, *r);
+
+	else if (r != re)
+		return -1;
+
+	else if (l != le)
+		return 1;
+
+	else
+		return 0;
+}
+
+static void _print_path_delta(FILE *stream,
+			      struct token *old, unsigned old_len,
+			      struct token *new, unsigned new_len,
+			      const char *desc)
+{
+	unsigned i, common_prefix = 0, len, d;
+	unsigned max_prefix = old_len < new_len ? old_len : new_len;
+
+	for (i = 0; i < max_prefix; i++) {
+		if (_tok_cmp(old + i, new + i))
+			break;
+		else
+			common_prefix++;
+	}
+
+	for (; i < new_len; i++) {
+		_indent(stream, common_prefix);
+		_print_token(stream, new + i);
+		common_prefix++;
+		if (i < new_len - 1)
+			fprintf(stream, "\n");
+	}
+
+	len = common_prefix * 2 + (new[new_len - 1].e - new[new_len - 1].b);
+	fprintf(stream, "  ");
+	for (d = len; d < 60; d++)
+		fprintf(stream, ".");
+	fprintf(stream, "  ");
+	fprintf(stream, "%s", desc);
+	fprintf(stream, "\n");
+}
+
+typedef struct token comp_t[MAX_COMPONENTS];
+
+static void _list_tests(struct test_details **tests, unsigned nr)
+{
+	unsigned i, current = 0, current_len, last_len = 0;
+
+	comp_t components[2];
+
+	for (i = 0; i < nr; i++) {
+		struct test_details *t = tests[i];
+		current_len = _split_components(t->path, components[current], MAX_COMPONENTS);
+		_print_path_delta(stderr, components[!current], last_len,
+				  components[current], current_len, t->desc);
+
+		last_len = current_len;
+		current = !current;
+	}
+}
+
+static void _destroy_tests(struct dm_list *suites)
+{
+	struct test_suite *ts, *tmp;
+
+	dm_list_iterate_items_safe (ts, tmp, suites)
+		test_suite_destroy(ts);
+}
+
+static const char *red(bool c)
+{
+	return c ? "\x1B[31m" : "";
+}
+
+static const char *green(bool c)
+{
+	return c ? "\x1B[32m" : "";
+}
+
+static const char *normal(bool c)
+{
+	return c ? "\x1B[0m" : "";
+}
+
+static void _run_test(struct test_details *t, bool use_colour, unsigned *passed, unsigned *total)
+{
+	void *fixture;
+	struct test_suite *ts = t->parent;
+	fprintf(stderr, "[RUN    ] %s\n", t->path);
+
+	(*total)++;
+	if (setjmp(test_k))
+		fprintf(stderr, "%s[   FAIL]%s %s\n", red(use_colour), normal(use_colour), t->path);
+	else {
+		if (ts->fixture_init)
+			fixture = ts->fixture_init();
+		else
+			fixture = NULL;
+
+		t->fn(fixture);
+
+		if (ts->fixture_exit)
+			ts->fixture_exit(fixture);
+
+		(*passed)++;
+		fprintf(stderr, "%s[     OK]%s\n", green(use_colour), normal(use_colour));
+	}
+}
+
+static bool _run_tests(struct test_details **tests, unsigned nr)
+{
+	bool use_colour = isatty(fileno(stderr));
+	unsigned i, passed = 0, total = 0;
+
+	for (i = 0; i < nr; i++)
+		_run_test(tests[i], use_colour, &passed, &total);
+
+	fprintf(stderr, "\n%u/%u tests passed\n", passed, total);
+
+	return passed == total;
+}
+
+static void _usage(void)
+{
+	fprintf(stderr, "Usage: unit-test <list|run> [pattern]\n");
+}
+
+static int _cmp_paths(const void *lhs, const void *rhs)
+{
+	struct test_details *l = *((struct test_details **) lhs);
+	struct test_details *r = *((struct test_details **) rhs);
+
+	return strcmp(l->path, r->path);
+}
+
+static unsigned _filter(const char *pattern, struct test_details **tests, unsigned nr)
+{
+	unsigned i, found = 0;
+	regex_t rx;
+
+	if (regcomp(&rx, pattern, 0)) {
+		fprintf(stderr, "couldn't compile regex '%s'\n", pattern);
+		exit(1);
+	}
+
+	for (i = 0; i < nr; i++)
+		if (!regexec(&rx, tests[i]->path, 0, NULL, 0))
+			tests[found++] = tests[i];
+
+	regfree(&rx);
+
+	return found;
+}
+
+int main(int argc, char **argv)
+{
+	int r;
+	unsigned i, nr_tests;
+	struct test_suite *ts;
+	struct test_details *t, **t_array;
+	struct dm_list suites;
+
+	dm_list_init(&suites);
+	register_all_tests(&suites);
+
+	// count all tests
+	nr_tests = 0;
+	dm_list_iterate_items (ts, &suites)
+		dm_list_iterate_items (t, &ts->tests)
+			nr_tests++;
+
+	// stick them in an array
+	t_array = malloc(sizeof(*t_array) * nr_tests);
+	if (!t_array) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	i = 0;
+	dm_list_iterate_items (ts, &suites)
+		dm_list_iterate_items (t, &ts->tests)
+			t_array[i++] = t;
+
+	// filter
+	if (argc == 3)
+		nr_tests = _filter(argv[2], t_array, nr_tests);
+
+	// sort
+	qsort(t_array, nr_tests, sizeof(*t_array), _cmp_paths);
+
+	// run or list them
+	if (argc == 1)
+		r = !_run_tests(t_array, nr_tests);
+	else {
+		const char *cmd = argv[1];
+		if (!strcmp(cmd, "run"))
+			r = !_run_tests(t_array, nr_tests);
+
+		else if (!strcmp(cmd, "list")) {
+			_list_tests(t_array, nr_tests);
+			r = 0;
+
+		} else {
+			_usage();
+			r = 1;
+		}
+	}
+
+	free(t_array);
+	_destroy_tests(&suites);
+
+	return r;
+}
+
+//-----------------------------------------------------------------
diff --git a/unit-test/string_t.c b/unit-test/string_t.c
new file mode 100644
index 0000000..2af0f37
--- /dev/null
+++ b/unit-test/string_t.c
@@ -0,0 +1,91 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+#include <stdio.h>
+#include <string.h>
+
+#if 0
+static int _mem_init(void)
+{
+	struct dm_pool *mem = dm_pool_create("string test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+/* TODO: Add more string unit tests here */
+#endif
+
+static void test_strncpy(void *fixture)
+{
+	const char st[] = "1234567890";
+	char buf[sizeof(st)];
+
+	T_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf)), 1);
+	T_ASSERT_EQUAL(strcmp(buf, st), 0);
+
+	T_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf) - 1), 0);
+	T_ASSERT_EQUAL(strlen(buf) + 1, sizeof(buf) - 1);
+}
+
+static void test_asprint(void *fixture)
+{
+	const char st0[] = "";
+	const char st1[] = "12345678901";
+	const char st2[] = "1234567890123456789012345678901234567890123456789012345678901234567";
+	char *buf;
+	int a;
+
+	a = dm_asprintf(&buf, "%s", st0);
+	T_ASSERT_EQUAL(strcmp(buf, st0), 0);
+	T_ASSERT_EQUAL(a, sizeof(st0));
+	free(buf);
+
+	a = dm_asprintf(&buf, "%s", st1);
+	T_ASSERT_EQUAL(strcmp(buf, st1), 0);
+	T_ASSERT_EQUAL(a, sizeof(st1));
+	free(buf);
+
+	a = dm_asprintf(&buf, "%s", st2);
+	T_ASSERT_EQUAL(a, sizeof(st2));
+	T_ASSERT_EQUAL(strcmp(buf, st2), 0);
+	free(buf);
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/data-struct/string/" path, desc, fn)
+
+void string_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(NULL, NULL);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("asprint", "tests asprint", test_asprint);
+	T("strncpy", "tests string copying", test_strncpy);
+
+	dm_list_add(all_tests, &ts->list);
+}
diff --git a/unit-test/units.h b/unit-test/units.h
new file mode 100644
index 0000000..47f04c2
--- /dev/null
+++ b/unit-test/units.h
@@ -0,0 +1,46 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef TEST_UNIT_UNITS_H
+#define TEST_UNIT_UNITS_H
+
+#include "framework.h"
+
+//-----------------------------------------------------------------
+
+// Declare the function that adds tests suites here ...
+void bcache_tests(struct dm_list *suites);
+void bitset_tests(struct dm_list *suites);
+void config_tests(struct dm_list *suites);
+void dm_list_tests(struct dm_list *suites);
+void dm_status_tests(struct dm_list *suites);
+void regex_tests(struct dm_list *suites);
+void percent_tests(struct dm_list *suites);
+void string_tests(struct dm_list *suites);
+
+// ... and call it in here.
+static inline void register_all_tests(struct dm_list *suites)
+{
+	bcache_tests(suites);
+	bitset_tests(suites);
+	config_tests(suites);
+	dm_list_tests(suites);
+	dm_status_tests(suites);
+	regex_tests(suites);
+	percent_tests(suites);
+	string_tests(suites);
+}
+
+//-----------------------------------------------------------------
+#endif


