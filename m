From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 May 2014 21:32:29 +0000 (UTC)
Subject: master - tests: support thin_restore configurable
Message-ID: <20140526213229.217AF60DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3539907f582a924df1c056829a231d1d39e4cec
Commit:        b3539907f582a924df1c056829a231d1d39e4cec
Parent:        b0ff3359f268913dbe01179600aa69c008cbb1ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 26 23:28:03 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 26 23:30:09 2014 +0200

tests: support thin_restore configurable

Currently this tool is used only in tests.
---
 configure                                     |  126 +++++++++++++++++++++++++
 configure.in                                  |   17 ++++
 lib/misc/configure.h.in                       |    3 +
 test/Makefile.in                              |   10 +-
 test/shell/lvextend-thin-metadata-dmeventd.sh |    7 +-
 5 files changed, 156 insertions(+), 7 deletions(-)

diff --git a/configure b/configure
index 49a89c2..7738c8f 100755
--- a/configure
+++ b/configure
@@ -767,6 +767,7 @@ PKGCONFIGINIT_CFLAGS
 PKG_CONFIG_LIBDIR
 PKG_CONFIG_PATH
 PKG_CONFIG
+THIN_RESTORE_CMD
 THIN_REPAIR_CMD
 THIN_DUMP_CMD
 THIN_CHECK_CMD
@@ -869,6 +870,7 @@ with_thin
 with_thin_check
 with_thin_dump
 with_thin_repair
+with_thin_restore
 enable_thin_check_needs_check
 with_cache
 enable_readline
@@ -1655,6 +1657,8 @@ Optional Packages:
   --with-thin-check=PATH  thin_check tool: [[autodetect]]
   --with-thin-dump=PATH   thin_dump tool: [[autodetect]]
   --with-thin-repair=PATH thin_repair tool: [[autodetect]]
+  --with-thin-restore=PATH
+                          thin_restore tool: [[autodetect]]
   --with-cache=TYPE       cache support: internal/shared/none [[TYPE=none]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
@@ -7197,6 +7201,14 @@ else
 fi
 
 
+# Check whether --with-thin-restore was given.
+if test "${with_thin_restore+set}" = set; then :
+  withval=$with_thin_restore; THIN_RESTORE_CMD=$withval
+else
+  THIN_RESTORE_CMD="autodetect"
+fi
+
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN" >&5
 $as_echo "$THIN" >&6; }
 
@@ -7558,6 +7570,113 @@ $as_echo "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
+	# Empty means a config way to ignore thin checking
+	if test "$THIN_RESTORE_CMD" = "autodetect"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}thin_restore", so it can be a program name with args.
+set dummy ${ac_tool_prefix}thin_restore; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_THIN_RESTORE_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $THIN_RESTORE_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_THIN_RESTORE_CMD="$THIN_RESTORE_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_THIN_RESTORE_CMD="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+THIN_RESTORE_CMD=$ac_cv_path_THIN_RESTORE_CMD
+if test -n "$THIN_RESTORE_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_RESTORE_CMD" >&5
+$as_echo "$THIN_RESTORE_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_THIN_RESTORE_CMD"; then
+  ac_pt_THIN_RESTORE_CMD=$THIN_RESTORE_CMD
+  # Extract the first word of "thin_restore", so it can be a program name with args.
+set dummy thin_restore; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_THIN_RESTORE_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_THIN_RESTORE_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_THIN_RESTORE_CMD="$ac_pt_THIN_RESTORE_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_THIN_RESTORE_CMD="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+ac_pt_THIN_RESTORE_CMD=$ac_cv_path_ac_pt_THIN_RESTORE_CMD
+if test -n "$ac_pt_THIN_RESTORE_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_RESTORE_CMD" >&5
+$as_echo "$ac_pt_THIN_RESTORE_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_THIN_RESTORE_CMD" = x; then
+    THIN_RESTORE_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    THIN_RESTORE_CMD=$ac_pt_THIN_RESTORE_CMD
+  fi
+else
+  THIN_RESTORE_CMD="$ac_cv_path_THIN_RESTORE_CMD"
+fi
+
+		test -z "$THIN_RESTORE_CMD" && {
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_restore not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: thin_restore not found in path $PATH" >&2;}
+			THIN_RESTORE_CMD=/usr/sbin/thin_restore
+			THIN_CONFIGURE_WARN=y
+		}
+	fi
 	;;
 esac
 
@@ -7589,6 +7708,12 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+
+cat >>confdefs.h <<_ACEOF
+#define THIN_RESTORE_CMD "$THIN_RESTORE_CMD"
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include cache" >&5
 $as_echo_n "checking whether to include cache... " >&6; }
@@ -11529,6 +11654,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile
  python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 6fbba27..16e63c0 100644
--- a/configure.in
+++ b/configure.in
@@ -422,6 +422,10 @@ AC_ARG_WITH(thin-repair,
 	    AC_HELP_STRING([--with-thin-repair=PATH],
 			   [thin_repair tool: [[autodetect]]]),
 			   THIN_REPAIR_CMD=$withval, THIN_REPAIR_CMD="autodetect")
+AC_ARG_WITH(thin-restore,
+	    AC_HELP_STRING([--with-thin-restore=PATH],
+			   [thin_restore tool: [[autodetect]]]),
+			   THIN_RESTORE_CMD=$withval, THIN_RESTORE_CMD="autodetect")
 
 AC_MSG_RESULT($THIN)
 
@@ -484,6 +488,15 @@ case "$THIN" in
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
+	# Empty means a config way to ignore thin checking
+	if test "$THIN_RESTORE_CMD" = "autodetect"; then
+		AC_PATH_TOOL(THIN_RESTORE_CMD, thin_restore)
+		test -z "$THIN_RESTORE_CMD" && {
+			AC_MSG_WARN(thin_restore not found in path $PATH)
+			THIN_RESTORE_CMD=/usr/sbin/thin_restore
+			THIN_CONFIGURE_WARN=y
+		}
+	fi
 	;;
 esac
 
@@ -502,6 +515,9 @@ AC_DEFINE_UNQUOTED([THIN_DUMP_CMD], ["$THIN_DUMP_CMD"],
 AC_DEFINE_UNQUOTED([THIN_REPAIR_CMD], ["$THIN_REPAIR_CMD"],
 		   [The path to 'thin_repair', if available.])
 
+AC_DEFINE_UNQUOTED([THIN_RESTORE_CMD], ["$THIN_RESTORE_CMD"],
+		   [The path to 'thin_restore', if available.])
+
 ################################################################################
 dnl -- cache inclusion type
 AC_MSG_CHECKING(whether to include cache)
@@ -1739,6 +1755,7 @@ AC_SUBST(THIN)
 AC_SUBST(THIN_CHECK_CMD)
 AC_SUBST(THIN_DUMP_CMD)
 AC_SUBST(THIN_REPAIR_CMD)
+AC_SUBST(THIN_RESTORE_CMD)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index ead131c..c618ff4 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -562,6 +562,9 @@
 /* The path to 'thin_repair', if available. */
 #undef THIN_REPAIR_CMD
 
+/* The path to 'thin_restore', if available. */
+#undef THIN_RESTORE_CMD
+
 /* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
 #undef TIME_WITH_SYS_TIME
 
diff --git a/test/Makefile.in b/test/Makefile.in
index 1538fa3..370d9bd 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -28,6 +28,7 @@ LVM_TEST_RESULTS ?= results
 export LVM_TEST_THIN_CHECK_CMD?=@THIN_CHECK_CMD@
 export LVM_TEST_THIN_DUMP_CMD?=@THIN_DUMP_CMD@
 export LVM_TEST_THIN_REPAIR_CMD?=@THIN_REPAIR_CMD@
+export LVM_TEST_THIN_RESTORE_CMD?=@THIN_RESTORE_CMD@
 
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
@@ -68,15 +69,16 @@ help:
 	@echo -e "\nSupported variables:"
 	@echo "  LVM_TEST_CAN_CLOBBER_DMESG Allow to clobber dmesg buffer without /dev/kmsg. (1)"
 	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."
-	@echo "  LVM_TEST_DIR		Where to create test files [$(LVM_TEST_DIR)]."
+	@echo "  LVM_TEST_DIR		Where to create test files  [$(LVM_TEST_DIR)]."
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
 	@echo "  LVM_TEST_LVMETAD	Start lvmetad (1)."
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
 	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
 	@echo "  LVM_TEST_RESULTS	Where to create result files [results]."
-	@echo "  LVM_TEST_THIN_CHECK_CMD  Command for thin_check  [$(LVM_TEST_THIN_CHECK_CMD)]."
-	@echo "  LVM_TEST_THIN_DUMP_CMD   Command for thin_dump   [$(LVM_TEST_THIN_DUMP_CMD)]."
-	@echo "  LVM_TEST_THIN_REPAIR_CMD Command for thin_repair [$(LVM_TEST_THIN_REPAIR_CMD)]."
+	@echo "  LVM_TEST_THIN_CHECK_CMD   Command for thin_check   [$(LVM_TEST_THIN_CHECK_CMD)]."
+	@echo "  LVM_TEST_THIN_DUMP_CMD    Command for thin_dump    [$(LVM_TEST_THIN_DUMP_CMD)]."
+	@echo "  LVM_TEST_THIN_REPAIR_CMD  Command for thin_repair  [$(LVM_TEST_THIN_REPAIR_CMD)]."
+	@echo "  LVM_TEST_THIN_RESTORE_CMD Command for thin_restore [$(LVM_TEST_THIN_RESTORE_CMD)]."
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
 	@echo "  LVM_VALGRIND		Enable valgrind testing (1,2,3) execs $$"VALGRIND
 	@echo "  LVM_VALGRIND_CLVMD	Enable valgrind testing of clvmd (1)."
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index cb5261c..6e03d9d 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -42,6 +42,7 @@ fake_metadata_() {
 	echo "</superblock>"
 }
 
+test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_restore) || skip
 aux have_thin 1 10 0 || skip
 
 aux prepare_dmeventd
@@ -61,7 +62,7 @@ lvchange -an $vg/thin $vg/pool
 # Prepare some fake metadata with unmatching id
 # Transaction_id is lower by 1 and there are no message -> ERROR
 fake_metadata_ 10 0 >data
-thin_restore -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+$LVM_TEST_THIN_RESTORE_CMD -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
 grep expected out
@@ -70,7 +71,7 @@ check inactive $vg pool_tmeta
 
 # Transaction_id is higher by 1
 fake_metadata_ 10 2 >data
-thin_restore -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+$LVM_TEST_THIN_RESTORE_CMD -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
 grep expected out
@@ -79,7 +80,7 @@ check inactive $vg pool_tmeta
 
 # Prepare some fake metadata prefilled to ~81% (>70%)
 fake_metadata_ 400 1 >data
-thin_restore -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+$LVM_TEST_THIN_RESTORE_CMD -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1


