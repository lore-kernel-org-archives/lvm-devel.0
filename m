From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 8 Feb 2018 20:32:23 -0500
Subject: master - device: Basic config and setup to support async I/O.
Message-ID: <201802090132.w191WNJ2027477@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c7bbcfb0f6771a10acd238057fdb7931c3fbb12
Commit:        8c7bbcfb0f6771a10acd238057fdb7931c3fbb12
Parent:        7a9af3cd0e609e10840202ae1754ab76b6add511
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 22 17:45:12 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 8 20:15:14 2018 +0000

device: Basic config and setup to support async I/O.

---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |    5 +
 configure                    |   69 ++++++++++++++
 configure.in                 |   22 +++++
 doc/aio_design.txt           |  215 ++++++++++++++++++++++++++++++++++++++++++
 include/configure.h.in       |    3 +
 lib/commands/toolcontext.c   |   10 ++
 lib/commands/toolcontext.h   |    1 +
 lib/config/config_settings.h |    3 +
 lib/config/defaults.h        |    1 +
 lib/device/dev-cache.c       |    2 +
 lib/device/dev-io.c          |   79 +++++++++++++++
 lib/device/device.h          |    5 +
 make.tmpl.in                 |    3 +-
 tools/toollib.c              |    1 +
 15 files changed, 419 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 87d7de8..5aa4ed8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Detect asynchronous I/O capability in configure or accept --disable-aio.
   Add AIO_SUPPORTED_CODE_PATH to indicate whether AIO may be used.
   Configure ensures /usr/bin dir is checked for dmpd tools.
   Restore pvmove support for wide-clustered active volumes (2.02.177).
diff --git a/conf/example.conf.in b/conf/example.conf.in
index aab274d..6a491fb 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -59,6 +59,11 @@ devices {
 	# This configuration option is advanced.
 	scan = [ "/dev" ]
 
+	# Configuration option devices/use_aio.
+	# Use linux asynchronous I/O for parallel device access where possible.
+	# This configuration option has an automatic default value.
+	# use_aio = 1
+
 	# Configuration option devices/obtain_device_list_from_udev.
 	# Obtain the list of available devices from udev.
 	# This avoids opening or using any inapplicable non-block devices or
diff --git a/configure b/configure
index 0a5d225..5409f68 100755
--- a/configure
+++ b/configure
@@ -707,7 +707,9 @@ FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
 DMEVENTD_PATH
+AIO_LIBS
 DL_LIBS
+AIO
 DEVMAPPER
 DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_LVMPOLLD
@@ -954,6 +956,7 @@ enable_profiling
 enable_testing
 enable_valgrind_pool
 enable_devmapper
+enable_aio
 enable_lvmetad
 enable_lvmpolld
 enable_lvmlockd_sanlock
@@ -1692,6 +1695,7 @@ Optional Features:
   --enable-testing        enable testing targets in the makefile
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
+  --disable-aio           disable asynchronous I/O
   --enable-lvmetad        enable the LVM Metadata Daemon
   --enable-lvmpolld       enable the LVM Polling Daemon
   --enable-lvmlockd-sanlock
@@ -3179,6 +3183,7 @@ case "$host_os" in
 		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
+		AIO=yes
 		BUILD_LVMETAD=no
 		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
@@ -3198,6 +3203,7 @@ case "$host_os" in
 		CLDNOWHOLEARCHIVE=
 		LIB_SUFFIX=dylib
 		DEVMAPPER=yes
+		AIO=no
 		ODIRECT=no
 		DM_IOCTLS=no
 		SELINUX=no
@@ -11827,6 +11833,67 @@ $as_echo "#define DEVMAPPER_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use asynchronous I/O" >&5
+$as_echo_n "checking whether to asynchronous I/O... " >&6; }
+# Check whether --enable-aio was given.
+if test "${enable_aio+set}" = set; then :
+  enableval=$enable_aio; AIO=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $AIO" >&5
+$as_echo "$AIO" >&6; }
+
+if test "$AIO" = yes; then
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for io_setup in -laio" >&5
+$as_echo_n "checking for io_setup in -laio... " >&6; }
+if ${ac_cv_lib_aio_io_setup+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-laio  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char io_setup ();
+int
+main ()
+{
+return io_setup ();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ac_cv_lib_aio_io_setup=yes
+else
+  ac_cv_lib_aio_io_setup=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_aio_io_setup" >&5
+$as_echo "$ac_cv_lib_aio_io_setup" >&6; }
+if test "x$ac_cv_lib_aio_io_setup" = xyes; then :
+
+$as_echo "#define AIO_SUPPORT 1" >>confdefs.h
+
+		AIO_LIBS="-laio"
+		AIO_SUPPORT=yes
+else
+  AIO_LIBS=
+		AIO_SUPPORT=no
+fi
+
+fi
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build LVMetaD" >&5
 $as_echo_n "checking whether to build LVMetaD... " >&6; }
 # Check whether --enable-lvmetad was given.
@@ -15778,6 +15845,8 @@ _ACEOF
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/
 Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_h
 at.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index b8e1623..605b6b2 100644
--- a/configure.in
+++ b/configure.in
@@ -39,6 +39,7 @@ case "$host_os" in
 		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
+		AIO=yes
 		BUILD_LVMETAD=no
 		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
@@ -58,6 +59,7 @@ case "$host_os" in
 		CLDNOWHOLEARCHIVE=
 		LIB_SUFFIX=dylib
 		DEVMAPPER=yes
+		AIO=no
 		ODIRECT=no
 		DM_IOCTLS=no
 		SELINUX=no
@@ -1123,6 +1125,24 @@ if test "$DEVMAPPER" = yes; then
 fi
 
 ################################################################################
+dnl -- Disable aio
+AC_MSG_CHECKING(whether to use asynchronous I/O)
+AC_ARG_ENABLE(aio,
+	      AC_HELP_STRING([--disable-aio],
+			     [disable asynchronous I/O]),
+	      AIO=$enableval)
+AC_MSG_RESULT($AIO)
+
+if test "$AIO" = yes; then
+	AC_CHECK_LIB(aio, io_setup,
+		[AC_DEFINE([AIO_SUPPORT], 1, [Define to 1 if aio is available.])
+		AIO_LIBS="-laio"
+		AIO_SUPPORT=yes],
+		[AIO_LIBS=
+		AIO_SUPPORT=no ])
+fi
+
+################################################################################
 dnl -- Build lvmetad
 AC_MSG_CHECKING(whether to build LVMetaD)
 AC_ARG_ENABLE(lvmetad,
@@ -2061,9 +2081,11 @@ AC_SUBST(DEFAULT_USE_LVMETAD)
 AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEFAULT_USE_LVMLOCKD)
 AC_SUBST(DEVMAPPER)
+AC_SUBST(AIO)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
 AC_SUBST(DL_LIBS)
+AC_SUBST(AIO_LIBS)
 AC_SUBST(DMEVENTD_PATH)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
diff --git a/doc/aio_design.txt b/doc/aio_design.txt
new file mode 100644
index 0000000..c6eb443
--- /dev/null
+++ b/doc/aio_design.txt
@@ -0,0 +1,215 @@
+Introducing asynchronous I/O to LVM
+===================================
+
+Issuing I/O asynchronously means instructing the kernel to perform specific
+I/O and return immediately without waiting for it to complete.  The data
+is collected from the kernel later.
+
+Advantages
+----------
+
+A1. While waiting for the I/O to happen, the program could perform other
+operations.
+
+A2. When LVM is searching for its Physical Volumes, it issues a small amount of
+I/O to a large number of disks.  If this was issued in parallel the overall
+runtime might be shorter while there should be little effect on the cpu time.
+
+A3. If more than one timeout occurs when accessing any devices, these can be
+taken in parallel, again reducing the runtime.  This applies globally,
+not just while the code is searching for Physical Volumes, so reading,
+writing and committing the metadata may occasionally benefit too to some
+extent and there are probably maintenance advantages in using the same
+method of I/O throughout the main body of the code.
+
+A4. By introducing a simple callback function mechanism, the conversion can be
+performed largely incrementally by first refactoring and continuing to
+use synchronous I/O with the callbacks performed immediately.  This allows the
+callbacks to be introduced without changing the running sequence of the code
+initially.  Future projects could refactor some of the calling sites to
+simplify the code structure and even eliminate some of the nesting.
+This allows each part of what might ultimately amount to a large change to be
+introduced and tested independently.
+
+
+Disadvantages
+-------------
+
+D1. The resulting code may be more complex with more failure modes to
+handle.  Mitigate by thorough auditing and testing, rolling out
+gradually, and offering a simple switch to revert to the old behaviour.
+
+D2. The linux asynchronous I/O implementation is less mature than
+its synchronous I/O implementation and might show up problems that
+depend on the version of the kernel or library used.  Fixes or
+workarounds for some of these might require kernel changes.  For
+example, there are suggestions that despite being supposedly async,
+there are still cases where system calls can block.  There might be
+resource dependencies on other processes running on the system that make
+it unsuitable for use while any devices are suspended.  Mitigation
+as for D1.
+
+D3. The error handling within callbacks becomes more complicated.
+However we know that existing call paths can already sometimes discard
+errors, sometimes deliberately, sometimes not, so this aspect is in need
+of a complete review anyway and the new approach will make the error
+handling more transparent.  Aim initially for overall behaviour that is
+no worse than that of the existing code, then work on improving it
+later.
+
+D4. The work will take a few weeks to code and test.  This leads to a
+significant opportunity cost when compared against other enhancements
+that could be achieved in that time.  However, the proof-of-concept work
+performed while writing this design has satisfied me that the work could
+proceed and be committed incrementally as a background task.
+
+
+Observations regarding LVM's I/O Architecture 
+---------------------------------------------
+
+H1. All device, metadata and config file I/O is constrained to pass through a
+single route in lib/device.
+
+H2. The first step of the analysis was to instrument this code path with
+log_debug messages.  I/O is split into the following categories:
+
+        "dev signatures",
+        "PV labels",
+        "VG metadata header",
+        "VG metadata content",
+        "extra VG metadata header",
+        "extra VG metadata content",
+        "LVM1 metadata",
+        "pool metadata",
+        "LV content",
+        "logging",
+
+H3. A bounce buffer is used for most I/O.
+
+H4. Most callers finish using the supplied data before any further I/O is
+issued.  The few that don't could be converted trivially to do so.
+
+H5. There is one stream of I/O per metadata area on each device.
+
+H6. Some reads fall at offsets close to immediately preceding reads, so it's
+possible to avoid these by caching one "block" per metadata area I/O stream.
+
+H7. Simple analysis suggests a minimum aligned read size of 8k would deliver
+immediate gains from this caching.  A larger size might perform worse because
+almost all the time the extra data read would not be used, but this can be
+re-examined and tuned after the code is in place.
+
+
+Proposal
+--------
+
+P1. Retain the "single I/O path" but offer an asynchronous option.
+
+P2. Eliminate the bounce buffer in most cases by improving alignment.
+
+P3. Reduce the number of reads by always reading a minimum of an aligned
+8k block.  
+
+P4. Eliminate repeated reads by caching the last block read and changing
+the lib/device interface to return a pointer to read-only data within
+this block.
+
+P5. Only perform these interface changes for code on the critical path
+for now by converting other code sites to use wrappers around the new
+interface.
+
+P6. Treat asynchronous I/O as the interface of choice and optimise only
+for this case.
+
+P7. Convert the callers on the critical path to pass callback functions
+to the device layer.  These functions will be called later with the
+read-only data, a context pointer and a success/failure indicator.
+Where an existing function performs a sequence of I/O, this has the
+advantage of breaking up the large function into smaller ones and
+wrapping the parameters used into structures.  While this might look
+rather messy and ad-hoc in the short-term, it's a first step towards
+breaking up confusingly long functions into component parts and wrapping
+the existing long parameter lists into more appropriate structures and
+refactoring these parts of the code.
+
+P8. Limit the resources used by the asynchronous I/O by using two
+tunable parameters, one limiting the number of outstanding I/Os issued
+and another limiting the total amount of memory used.
+
+P9. Provide a fallback option if asynchronous I/O is unavailable by
+sharing the code paths but issuing the I/O synchronously and calling the
+callback immediately.
+
+P10. Only allocate the buffer for the I/O at the point where the I/O is
+about to be issued.
+
+P11. If the thresholds are exceeded, add the request to a simple queue,
+and process it later after some I/O has completed.
+
+
+Future work
+-----------
+F1. Perform a complete review of the error tracking so that device
+failures are handled and reported more cleanly, extending the existing
+basic error counting mechanism.
+
+F2. Consider whether some of the nested callbacks can be eliminated,
+which would allow for additional simplifications.
+
+F3. Adjust the contents of the adhoc context structs into more logical
+arrangements and use them more widely.
+
+F4. Perform wider refactoring of these areas of code.
+
+
+Testing considerations
+----------------------
+T1. The changes touch code on the device path, so a thorough re-test of
+the device layer is required.  The new code needs a full audit down
+through the library layer into the kernel to check that all the error
+conditions that are currently implemented (such as EAGAIN) are handled
+sensibly. (LVM's I/O layer needs to remain as solid as we can make it.)
+
+T2. The current test suite provides a reasonably broad range of coverage
+of this area but is far from comprehensive.
+
+
+Acceptance criteria
+-------------------
+A1. The current test suite should pass to the same extent as before the
+changes.
+
+A2. When all debugging and logging is disabled, strace -c must show
+improvements e.g. the expected fewer number of reads.
+
+A3. Running a range of commands under valgrind must not reveal any
+new leaks due to the changes.
+
+A4. All new coverity reports from the change must be addressed.
+
+A5. CPU time should be similar to that before, as the same work
+is being done overall, just in a different order.
+
+A6. Tests need to show improved behaviour in targetted areas.  For example,
+if several devices are slow and time out, the delays should occur
+in parallel and the elapsed time should be less than before.
+
+
+Release considerations
+----------------------
+R1. Async I/O should be widely available and largely reliable on linux
+nowadays (even though parts of its interface and implementation remain a
+matter of controversy) so we should try to make its use the default
+whereever it is supported.  If certain types of systems have problems we
+should try to detect those cases and disable it automatically there.
+
+R2. Because the implications of an unexpected problem in the new code
+could be severe for the people affected, the roll out needs to be gentle
+without a deadline to allow us plenty of time to gain confidence in the
+new code.  Our own testing will only be able to cover a tiny fraction of
+the different setups our users have, so we need to look out for problems
+caused by this proactively and encourage people to test it on their own
+systems and report back.  It must go into the tree near the start of a
+release cycle rather than at the end to provide time for our confidence
+in it to grow.
+
diff --git a/include/configure.h.in b/include/configure.h.in
index be2f660..a491807 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -1,5 +1,8 @@
 /* include/configure.h.in.  Generated from configure.in by autoheader.  */
 
+/* Define to 1 if aio is available. */
+#undef AIO_SUPPORT
+
 /* Define to 1 to use libblkid detection of signatures when wiping. */
 #undef BLKID_WIPING_SUPPORT
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 364587c..0080a68 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -635,6 +635,16 @@ static int _process_config(struct cmd_context *cmd)
 	 */
 	cmd->default_settings.udev_fallback = udev_disabled ? 1 : -1;
 
+#ifdef AIO_SUPPORT
+	cmd->use_aio = find_config_tree_bool(cmd, devices_use_aio_CFG, NULL);
+#else
+	cmd->use_aio = 0;
+#endif
+	if (cmd->use_aio && !dev_async_setup(cmd))
+		cmd->use_aio = 0;
+
+	log_debug_io("%ssing asynchronous I/O.", cmd->use_aio ? "U" : "Not u");
+
 	init_retry_deactivation(find_config_tree_bool(cmd, activation_retry_deactivation_CFG, NULL));
 
 	init_activation_checks(find_config_tree_bool(cmd, activation_checks_CFG, NULL));
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index bf2b251..4419daa 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -164,6 +164,7 @@ struct cmd_context {
 	unsigned vg_notify:1;
 	unsigned lv_notify:1;
 	unsigned pv_notify:1;
+	unsigned use_aio:1;
 
 	/*
 	 * Filtering.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 077fb15..523e6fe 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -226,6 +226,9 @@ cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING,
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
+cfg(devices_use_aio_CFG, "use_aio", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_AIO, vsn(2, 2, 178), NULL, 0, NULL,
+	"Use linux asynchronous I/O for parallel device access where possible.\n")
+
 cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
 
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index d9e19d9..5efab11 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -32,6 +32,7 @@
 #define DEFAULT_SYSTEM_ID_SOURCE "none"
 #define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
+#define DEFAULT_USE_AIO 1
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_FW_RAID_COMPONENT_DETECTION 0
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 3d57735..2f74c81 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1250,6 +1250,8 @@ int dev_cache_exit(void)
 	struct btree_iter *b;
 	int num_open = 0;
 
+	dev_async_exit();
+
 	if (_cache.names)
 		if ((num_open = _check_for_open_devices(1)) > 0)
 			log_error(INTERNAL_ERROR "%d device(s) were left open and have been closed.", num_open);
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index d23f61e..48f5b8d 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -98,6 +98,85 @@ void devbufs_release(struct device *dev)
 	_release_devbuf(&dev->last_extra_devbuf);
 }
 
+#ifdef AIO_SUPPORT
+
+#  include <libaio.h>
+
+static io_context_t _aio_ctx = 0;
+static int _aio_max = 128;
+
+int dev_async_setup(struct cmd_context *cmd)
+{
+	int r;
+
+	/* Already set up? */
+	if (_aio_ctx)
+		return 1;
+
+	log_debug_io("Setting up aio context for up to %d events.", _aio_max);
+
+	if ((r = io_setup(_aio_max, &_aio_ctx)) < 0) {
+		/*
+		 * Possible errors:
+		 *   ENOSYS - aio not available in current kernel
+		 *   EAGAIN - _aio_max is too big
+		 *   EFAULT - invalid pointer
+		 *   EINVAL - _aio_ctx != 0 or kernel aio limits exceeded
+		 *   ENOMEM
+		 */
+		log_warn("WARNING: Asynchronous I/O setup for %d events failed: %s", _aio_max, strerror(-r));
+		log_warn("WARNING: Using only synchronous I/O.");
+		_aio_ctx = 0;
+		return 0;
+	}
+
+	return 1;
+}
+
+/* Reset aio context after fork */
+int dev_async_reset(struct cmd_context *cmd)
+{
+	log_debug_io("Resetting asynchronous I/O context.");
+	_aio_ctx = 0;
+
+	return dev_async_setup(cmd);
+}
+
+void dev_async_exit(void)
+{
+	int r;
+
+	if (!_aio_ctx)
+		return;
+
+	log_debug_io("Destroying aio context.");
+	if ((r = io_destroy(_aio_ctx)) < 0)
+		/* Returns -ENOSYS if aio not in kernel or -EINVAL if _aio_ctx invalid */
+		log_error("Failed to destroy asynchronous I/O context: %s", strerror(-r));
+
+	_aio_ctx = 0;
+}
+
+#else
+
+static int _aio_ctx = 0;
+
+int dev_async_setup(struct cmd_context *cmd)
+{
+	return 1;
+}
+
+int dev_async_reset(struct cmd_context *cmd)
+{
+	return 1;
+}
+
+void dev_async_exit(void)
+{
+}
+
+#endif /* AIO_SUPPORT */
+
 /*-----------------------------------------------------------------
  * The standard io loop that keeps submitting an io until it's
  * all gone.
diff --git a/lib/device/device.h b/lib/device/device.h
index 2dea689..37d2fd2 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -202,4 +202,9 @@ void devbufs_release(struct device *dev);
 /* Return a valid device name from the alias list; NULL otherwise */
 const char *dev_name_confirmed(struct device *dev, int quiet);
 
+struct cmd_context;
+int dev_async_setup(struct cmd_context *cmd);
+void dev_async_exit(void);
+int dev_async_reset(struct cmd_context *cmd);
+
 #endif
diff --git a/make.tmpl.in b/make.tmpl.in
index bdf2349..414b1dd 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -62,7 +62,8 @@ CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS) $(AIO_LIBS)
+AIO_LIBS = @AIO_LIBS@
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
diff --git a/tools/toollib.c b/tools/toollib.c
index 0509b5e..0958f2f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -116,6 +116,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 			/* FIXME Clean up properly here */
 			_exit(ECMD_FAILED);
 	}
+	dev_async_reset(cmd);
 	dev_close_all();
 
 	return 1;


