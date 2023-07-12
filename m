From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Wed, 12 Jul 2023 13:19:13 +0000
Subject: [Git][lvmteam/lvm2][main] 11 commits: lvconvert: correction for thin conversion
Message-ID: <64aea8515907b_28a2ff8506da@gitlab-sidekiq-low-urgency-cpu-bound-v2-6f5f855ff8-8kl5b.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
857f5d6e by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
lvconvert: correction for thin conversion

Updates for 39457234db1d92f89d4234e2f2f5b703206281ae.
Off-by-one for option array - need 20 fields.
Missed to clear lock_args for cachepool.

- - - - -
4c78bdcf by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
autoconf: update py-compile

Use newer version of this script from:
https://raw.githubusercontent.com/autotools-mirror/automake/4bd4640e03670e267d9763d377f107c09b4f2202/lib/py-compile

Reported-by: Adam Willamson

- - - - -
491ee5d1 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
cov: hide some messages

Living with these...

- - - - -
7ec97ed5 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
cov: fix memleak in vgchange

Release allocated  vgname from get_single_vgname_cmd_arg()
when it is not returned via *vgname_ret.

- - - - -
c38b668f by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
debug: fix parsing of /proc/self/stat

The code in init_log_file relies on the process name (COMM) to not
contain whitespaces. This change fixes it by looking up the right-most
parenthesis to safely jump past COMM.

For more context see:
https://www.openwall.com/lists/oss-security/2022/12/21/6

Code is only used with testing, so it should have no impact on regular
users.

Reported-by: Hugues Evrard &lt;hevrard at google.com&gt;

mm

- - - - -
4d70e7bf by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
debug: use display_lvname

- - - - -
a51c68aa by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
tests: makefile build proper tools list

Add compiled components to the list.

- - - - -
80bad4a3 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
tests: check for writecache presence

Test is using writecache.

- - - - -
85fb46d8 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
tests: reduce paths added to LD_LIBRARY_PATH

Add only stricly needed paths to compiled .so objects.

- - - - -
33f02261 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
tests: some fixes for lvmlockd testing

- - - - -
6f1318c4 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
WHATS_NEW: update

- - - - -


13 changed files:

- WHATS_NEW
- autoconf/py-compile
- daemons/cmirrord/cluster.c
- lib/log/log.c
- lib/metadata/metadata.c
- lib/metadata/thin_manip.c
- test/Makefile.in
- test/lib/aux.sh
- test/lib/flavour-udev-lvmlockd-dlm.sh
- test/lib/utils.sh
- test/shell/lvconvert-thin-from-thick.sh
- tools/lvconvert.c
- tools/vgchange.c


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,5 +1,7 @@
 version 2.03.22 - 
 =================================
+  Fix memleak in vgchange autoactivation setup.
+  Update py-compile building script.
   Support conversion from thick to fully provisioned thin LV.
   Cache/Thin-pool can use error and zero volumes for testing.
   Individual thin volume can be cached, but cannot take snapshot.


=====================================
autoconf/py-compile
=====================================
@@ -1,9 +1,9 @@
 #!/bin/sh
 # py-compile - Compile a Python program
 
-scriptversion=2011-06-08.12; # UTC
+scriptversion=2023-03-30.00; # UTC
 
-# Copyright (C) 2000-2014 Free Software Foundation, Inc.
+# Copyright (C) 2000-2023 Free Software Foundation, Inc.
 
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
@@ -16,7 +16,7 @@ scriptversion=2011-06-08.12; # UTC
 # GNU General Public License for more details.
 
 # You should have received a copy of the GNU General Public License
-# along with this program.  If not, see <http://www.gnu.org/licenses/>.
+# along with this program.  If not, see <https://www.gnu.org/licenses/>.
 
 # As a special exception to the GNU General Public License, if you
 # distribute this file as part of a program that contains a
@@ -27,7 +27,7 @@ scriptversion=2011-06-08.12; # UTC
 # bugs to <bug-automake@gnu.org> or send patches to
 # <automake-patches@gnu.org>.
 
-if [ -z "$PYTHON" ]; then
+if test -z "$PYTHON"; then
   PYTHON=python
 fi
 
@@ -62,13 +62,19 @@ while test $# -ne 0; do
       ;;
     -h|--help)
       cat <<\EOF
-Usage: py-compile [--help] [--version] [--basedir DIR] [--destdir DIR] FILES..."
+Usage: py-compile [options] FILES...
 
 Byte compile some python scripts FILES.  Use --destdir to specify any
 leading directory path to the FILES that you don't want to include in the
 byte compiled file.  Specify --basedir for any additional path information you
 do want to be shown in the byte compiled file.
 
+Options:
+  --basedir DIR   Prefix all FILES with DIR, and include in error messages.
+  --destdir DIR   Prefix all FILES with DIR before compiling.
+  -v, --version   Display version information.
+  -h, --help      This help screen.
+
 Example:
   py-compile --destdir /tmp/pkg-root --basedir /usr/share/test test.py test2.py
 
@@ -94,77 +100,143 @@ EOF
   shift
 done
 
-files=$*
-if test -z "$files"; then
-    usage_error "no files given"
+if test $# -eq 0; then
+  usage_error "no files given"
 fi
 
 # if basedir was given, then it should be prepended to filenames before
 # byte compilation.
-if [ -z "$basedir" ]; then
-    pathtrans="path = file"
+if test -z "$basedir"; then
+  pathtrans="path = file"
 else
-    pathtrans="path = os.path.join('$basedir', file)"
+  pathtrans="path = os.path.join('$basedir', file)"
 fi
 
 # if destdir was given, then it needs to be prepended to the filename to
 # byte compile but not go into the compiled file.
-if [ -z "$destdir" ]; then
-    filetrans="filepath = path"
+if test -z "$destdir"; then
+  filetrans="filepath = path"
 else
-    filetrans="filepath = os.path.normpath('$destdir' + os.sep + path)"
+  filetrans="filepath = os.path.normpath('$destdir' + os.sep + path)"
 fi
 
-$PYTHON -c "
-import sys, os, py_compile, imp
+python_major=`$PYTHON -c 'import sys; print(sys.version_info[0])'`
+if test -z "$python_major"; then
+  usage_error "could not determine $PYTHON major version"
+fi
 
-files = '''$files'''
+case $python_major in
+[01])
+  usage_error "python version 0.x and 1.x not supported"
+  ;;
+esac
+
+python_minor=`$PYTHON -c 'import sys; print(sys.version_info[1])'`
+
+# NB: When adding support for newer versions, prefer copying & adding new cases
+# rather than try to keep things merged with shell variables.
+
+# First byte compile (no optimization) all the modules.
+# This works for all currently known Python versions.
+$PYTHON -c "
+import sys, os, py_compile
+
+try:
+    import importlib
+except ImportError:
+    importlib = None
+
+# importlib.util.cache_from_source was added in 3.4
+if (
+        hasattr(importlib, 'util')
+        and hasattr(importlib.util, 'cache_from_source')
+):
+    destpath = importlib.util.cache_from_source
+else:
+    destpath = lambda filepath: filepath + 'c'
 
 sys.stdout.write('Byte-compiling python modules...\n')
-for file in files.split():
+for file in sys.argv[1:]:
     $pathtrans
     $filetrans
-    if not os.path.exists(filepath) or not (len(filepath) >= 3
-                                            and filepath[-3:] == '.py'):
-	    continue
-    sys.stdout.write(file)
+    if (
+            not os.path.exists(filepath)
+            or not (len(filepath) >= 3 and filepath[-3:] == '.py')
+     ):
+        continue
+    sys.stdout.write(file + ' ')
     sys.stdout.flush()
-    if hasattr(imp, 'get_tag'):
-        py_compile.compile(filepath, imp.cache_from_source(filepath), path)
-    else:
-        py_compile.compile(filepath, filepath + 'c', path)
-sys.stdout.write('\n')" || exit $?
+    py_compile.compile(filepath, destpath(filepath), path)
+sys.stdout.write('\n')" "$@" || exit $?
 
-# this will fail for python < 1.5, but that doesn't matter ...
+# Then byte compile w/optimization all the modules.
 $PYTHON -O -c "
-import sys, os, py_compile, imp
-
-# pypy does not use .pyo optimization
-if hasattr(sys, 'pypy_translation_info'):
+import sys, os, py_compile
+
+try:
+    import importlib
+except ImportError:
+    importlib = None
+
+# importlib.util.cache_from_source was added in 3.4
+if (
+        hasattr(importlib, 'util')
+        and hasattr(importlib.util, 'cache_from_source')
+):
+    destpath = importlib.util.cache_from_source
+else:
+    destpath = lambda filepath: filepath + 'o'
+
+# pypy2 does not use .pyo optimization
+if sys.version_info.major <= 2 and hasattr(sys, 'pypy_translation_info'):
     sys.exit(0)
 
-files = '''$files'''
 sys.stdout.write('Byte-compiling python modules (optimized versions) ...\n')
-for file in files.split():
+for file in sys.argv[1:]:
+    $pathtrans
+    $filetrans
+    if (
+            not os.path.exists(filepath)
+            or not (len(filepath) >= 3 and filepath[-3:] == '.py')
+    ):
+        continue
+    sys.stdout.write(file + ' ')
+    sys.stdout.flush()
+    py_compile.compile(filepath, destpath(filepath), path)
+sys.stdout.write('\n')" "$@" 2>/dev/null || exit $?
+
+# Then byte compile w/more optimization.
+# Only do this for Python 3.5+, see https://bugs.gnu.org/38043 for background.
+case $python_major.$python_minor in
+2.*|3.[0-4])
+  ;;
+*)
+  $PYTHON -OO -c "
+import sys, os, py_compile, importlib
+
+sys.stdout.write('Byte-compiling python modules (more optimized versions)'
+                 ' ...\n')
+for file in sys.argv[1:]:
     $pathtrans
     $filetrans
-    if not os.path.exists(filepath) or not (len(filepath) >= 3
-                                            and filepath[-3:] == '.py'):
-	    continue
-    sys.stdout.write(file)
+    if (
+            not os.path.exists(filepath)
+            or not (len(filepath) >= 3 and filepath[-3:] == '.py')
+    ):
+        continue
+    sys.stdout.write(file + ' ')
     sys.stdout.flush()
-    if hasattr(imp, 'get_tag'):
-        py_compile.compile(filepath, imp.cache_from_source(filepath, False), path)
-    else:
-        py_compile.compile(filepath, filepath + 'o', path)
-sys.stdout.write('\n')" 2>/dev/null || :
+    py_compile.compile(filepath, importlib.util.cache_from_source(filepath), path)
+sys.stdout.write('\n')" "$@" 2>/dev/null || exit $?
+  ;;
+esac
 
 # Local Variables:
 # mode: shell-script
 # sh-indentation: 2
-# eval: (add-hook 'write-file-hooks 'time-stamp)
+# eval: (add-hook 'before-save-hook 'time-stamp)
 # time-stamp-start: "scriptversion="
 # time-stamp-format: "%:y-%02m-%02d.%02H"
-# time-stamp-time-zone: "UTC"
+# time-stamp-time-zone: "UTC0"
 # time-stamp-end: "; # UTC"
 # End:


=====================================
daemons/cmirrord/cluster.c
=====================================
@@ -1091,6 +1091,7 @@ static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gna
 	    (rq->u_rq.request_type != DM_ULOG_RESUME) &&
 	    (rq->u_rq.request_type != DM_ULOG_CLEAR_REGION) &&
 	    (rq->u_rq.request_type != DM_ULOG_CHECKPOINT_READY)) {
+		/* coverity[suspicious_sizeof] allocation is using varargs data @end */
 		tmp_rq = malloc(DM_ULOG_REQUEST_SIZE);
 		if (!tmp_rq) {
 			/*
@@ -1340,6 +1341,7 @@ static void cpg_join_callback(struct clog_cpg *match,
 		goto out;
 	}
 
+	/* coverity[suspicious_sizeof] allocation is using varargs data @end */
 	rq = malloc(DM_ULOG_REQUEST_SIZE);
 	if (!rq) {
 		LOG_ERROR("cpg_config_callback: "


=====================================
lib/log/log.c
=====================================
@@ -217,6 +217,45 @@ void init_log_fn(lvm2_log_fn_t log_fn)
 	_lvm2_log_fn = log_fn;
 }
 
+/* Read /proc/self/stat to extract pid and starttime */
+static int _get_pid_starttime(int *pid, unsigned long long *starttime)
+{
+	static const char statfile[] = "/proc/self/stat";
+	char buf[1024];
+	char *p;
+	int fd;
+	int e;
+
+	if ((fd = open(statfile, O_RDONLY)) == -1) {
+		log_sys_debug("open", statfile);
+		return 0;
+	}
+
+	if ((e = read(fd, buf, sizeof(buf) - 1)) <= 0)
+		log_sys_debug("read", statfile);
+
+	if (!close(fd))
+		log_sys_debug("close", statfile);
+
+	if (e <= 0)
+		return 0;
+
+	buf[e] = '\0';
+	if ((sscanf(buf, "%d ", pid) == 1) &&
+	    /* Jump past COMM, don't use scanf with '%s' since COMM may contain a space. */
+	    (p = strrchr(buf, ')')) &&
+	    (scanf(++p, " %*c %*d %*d %*d %*d " /* tty_nr */
+		   "%*d %*u %*u %*u %*u " /* mjflt */
+		   "%*u %*u %*u %*d %*d " /* cstim */
+		   "%*d %*d %*d %*d " /* itrealvalue */
+		   "%llu", &starttime) == 1))
+		return 1;
+
+	log_debug("Cannot parse content of %s.", statfile);
+
+	return 0;
+}
+
 /*
  * Support envvar LVM_LOG_FILE_EPOCH and allow to attach
  * extra keyword (consist of upto 32 alpha chars) to
@@ -228,11 +267,9 @@ void init_log_fn(lvm2_log_fn_t log_fn)
  */
 void init_log_file(const char *log_file, int append)
 {
-	static const char statfile[] = "/proc/self/stat";
 	const char *env;
-	int pid;
-	unsigned long long starttime;
-	FILE *st;
+	int pid = 0;
+	unsigned long long starttime = 0;
 	int i = 0;
 
 	_log_file_path[0] = '\0';
@@ -245,28 +282,18 @@ void init_log_file(const char *log_file, int append)
 			goto no_epoch;
 		}
 
-		if (!(st = fopen(statfile, "r")))
-			log_sys_error("fopen", statfile);
-		else if (fscanf(st, "%d %*s %*c %*d %*d %*d %*d " /* tty_nr */
-			   "%*d %*u %*u %*u %*u " /* mjflt */
-			   "%*u %*u %*u %*d %*d " /* cstim */
-			   "%*d %*d %*d %*d " /* itrealvalue */
-			   "%llu", &pid, &starttime) != 2) {
-			log_warn("WARNING: Cannot parse content of %s.", statfile);
+		if (!_get_pid_starttime(&pid, &starttime))
+			log_debug("Failed to obtain pid and starttime.");
+
+		if (dm_snprintf(_log_file_path, sizeof(_log_file_path),
+				"%s_%s_%d_%llu", log_file, env, pid, starttime) < 0) {
+			log_warn("WARNING: Debug log file path is too long for epoch.");
+			_log_file_path[0] = '\0';
 		} else {
-			if (dm_snprintf(_log_file_path, sizeof(_log_file_path),
-					"%s_%s_%d_%llu", log_file, env, pid, starttime) < 0) {
-				log_warn("WARNING: Debug log file path is too long for epoch.");
-				_log_file_path[0] = '\0';
-			} else {
-				log_file = _log_file_path;
-				append = 1; /* force */
-			}
+			log_file = _log_file_path;
+			append = 1; /* force */
 		}
 
-		if (st && fclose(st))
-			log_sys_debug("fclose", statfile);
-
 		if ((env = getenv("LVM_LOG_FILE_MAX_LINES"))) {
 			if (sscanf(env, FMTu64, &_log_file_max_lines) != 1) {
 				log_warn("WARNING: Ignoring invalid LVM_LOG_MAX_LINES envvar \"%s\".", env);
@@ -896,4 +923,3 @@ uint32_t log_journal_str_to_val(const char *str)
 	log_warn("Ignoring unrecognized journal value.");
 	return 0;
 }
-


=====================================
lib/metadata/metadata.c
=====================================
@@ -2642,8 +2642,8 @@ int vg_validate(struct volume_group *vg)
 
 				if (!strcmp(vg->lock_type, "sanlock")) {
 					if (dm_hash_lookup(vhash.lv_lock_args, lvl->lv->lock_args)) {
-						log_error(INTERNAL_ERROR "LV %s/%s has duplicate lock_args %s.",
-							  vg->name, lvl->lv->name, lvl->lv->lock_args);
+						log_error(INTERNAL_ERROR "LV %s has duplicate lock_args %s.",
+							  display_lvname(lvl->lv), lvl->lv->lock_args);
 						r = 0;
 					}
 
@@ -2657,15 +2657,15 @@ int vg_validate(struct volume_group *vg)
 				if (lv_is_cache_vol(lvl->lv)) {
 					log_debug("lock_args will be ignored on cache vol");
 				} else if (lvl->lv->lock_args) {
-					log_error(INTERNAL_ERROR "LV %s/%s shouldn't have lock_args",
-						  vg->name, lvl->lv->name);
+					log_error(INTERNAL_ERROR "LV %s shouldn't have lock_args %s.",
+						  display_lvname(lvl->lv), lvl->lv->lock_args);
 					r = 0;
 				}
 			}
 		} else {
 			if (lvl->lv->lock_args) {
-				log_error(INTERNAL_ERROR "LV %s/%s with no lock_type has lock_args %s",
-					  vg->name, lvl->lv->name, lvl->lv->lock_args);
+				log_error(INTERNAL_ERROR "LV %s with no lock_type has lock_args %s.",
+					  display_lvname(lvl->lv), lvl->lv->lock_args);
 				r = 0;
 			}
 		}


=====================================
lib/metadata/thin_manip.c
=====================================
@@ -462,7 +462,7 @@ int thin_pool_prepare_metadata(struct logical_volume *metadata_lv,
 	char lv_path[PATH_MAX], md_path[64], buffer[512];
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
-	const char *argv[19] = { /* Max supported 15 option args */
+	const char *argv[20] = { /* Max supported 15 option args */
 		find_config_tree_str_allow_empty(cmd, global_thin_restore_executable_CFG, NULL)
 	};
 	int args = 0;
@@ -497,6 +497,7 @@ int thin_pool_prepare_metadata(struct logical_volume *metadata_lv,
 		return 0;
 	}
 
+	/* coverity[secure_temp] until better solution */
 	if (!(f = tmpfile())) {
 		log_error("Cannot create temporary file to prepare metadata.");
 		return 0;


=====================================
test/Makefile.in
=====================================
@@ -53,15 +53,25 @@ comma = ,
 RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh -or -path \*/unit/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | $(SORT))
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
+ifeq ("@BUILD_DMEVENTD@", "yes")
+DMEVENTD_TOOLS :=\
+ daemons/dmeventd/dmeventd
+endif
+
 ifeq ("@BUILD_LVMPOLLD@", "yes")
 LVMPOLLD_RUN_BASE = $(RUN_BASE)
 LVMPOLLD_NDEV_FLAVOUR = ,ndev-lvmpolld
 LVMPOLLD_UDEV_FLAVOUR = ,udev-lvmpolld
+LVMPOLLD_TOOLS :=\
+ daemons/lvmpolld/lvmpolld
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 LVMLOCKD_RUN_BASE = $(RUN_BASE)
 LVMLOCKD_UDEV_FLAVOUR = ,udev-lvmlockd-test
+LVMLOCKD_TOOLS :=\
+ daemons/lvmlockd/lvmlockd\
+ daemons/lvmlockd/lvmlockctl
 endif
 
 # Shell quote;
@@ -204,9 +214,10 @@ LIB_LVMLOCKD_CONF :=\
 
 LIB_MKE2FS_CONF := mke2fs.conf
 
-LVM_TOOLS :=\
- daemons/dmeventd/dmeventd\
- daemons/lvmpolld/lvmpolld\
+LVM_TOOLS := \
+ $(LVMPOLLD_TOOLS)\
+ $(LVMLOCKD_TOOLS)\
+ $(DMEVENTD_TOOLS)\
  libdm/dm-tools/dmsetup
 
 LVM_PROFILES := $(addsuffix .profile,\


=====================================
test/lib/aux.sh
=====================================
@@ -56,7 +56,7 @@ create_dlm_conf() {
 			mv "$DLM_CONF" "$DLM_CONF.prelvmtest"
 		fi
 	fi
-
+	mkdir -p "$(dirname "$DLM_CONF")"
 	cp lib/test-dlm-conf "$DLM_CONF"
 	echo "created new $DLM_CONF"
 }


=====================================
test/lib/flavour-udev-lvmlockd-dlm.sh
=====================================
@@ -1,5 +1,6 @@
 export LVM_TEST_LOCKING=1
 export LVM_TEST_LVMPOLLD=1
 export LVM_TEST_LVMLOCKD=1
+export LVM_TEST_LVMLOCKD_TEST=1
 export LVM_TEST_LOCK_TYPE_DLM=1
 export LVM_TEST_DEVDIR=/dev


=====================================
test/lib/utils.sh
=====================================
@@ -302,9 +302,7 @@ if test -z "${installed_testsuite+varset}"; then
     *)
 	PATH="$abs_top_builddir/test/lib:$abs_top_builddir/test/api:$PATH"
 	LVM_BINARY=$(which lvm)
-	LD_LIBRARY_PATH=$(find -L "$abs_top_builddir/libdm/" "$abs_top_builddir/tools/"\
-		"$abs_top_builddir/daemons/" \
-		-name "*.so" -printf "%h:")"$LD_LIBRARY_PATH"
+	LD_LIBRARY_PATH="$abs_top_builddir/daemons/dmeventd:$abs_top_builddir/tools:$abs_top_builddir/libdm:$LD_LIBRARY_PATH"
 	export PATH LD_LIBRARY_PATH LVM_BINARY ;;
     esac
 fi


=====================================
test/shell/lvconvert-thin-from-thick.sh
=====================================
@@ -68,7 +68,7 @@ if aux have_cache 1 3 0 ; then
 fi
 
 # writecache -> thin
-if aux have_cache 1 3 0 ; then
+if aux have_writecache 1 0 0 ; then
 	lvcreate -L10 -n $lv1 $vg
 	lvcreate -an -L10 -n $lv2 $vg
 	lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1


=====================================
tools/lvconvert.c
=====================================
@@ -3398,13 +3398,11 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 * data and meta LVs (they are unlocked and deleted below.)
 	 */
 	if (vg_is_shared(vg)) {
-		if (to_cachepool) {
-			data_lv->lock_args = NULL;
-			metadata_lv->lock_args = NULL;
-		} else {
-			data_lv->lock_args = NULL;
-			metadata_lv->lock_args = NULL;
+		pool_lv->lock_args = NULL;
+		data_lv->lock_args = NULL;
+		metadata_lv->lock_args = NULL;
 
+		if (!to_cachepool) {
 			if (!strcmp(vg->lock_type, "sanlock"))
 				pool_lv->lock_args = "pending";
 			else if (!strcmp(vg->lock_type, "dlm"))


=====================================
tools/vgchange.c
=====================================
@@ -863,6 +863,9 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 		*flags &= ~READ_WITHOUT_LOCK;
 		cmd->can_use_one_scan = 0;
 	}
+
+	free(vgname);
+
 	return 1;
 
 }



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/b3b6c6b576bfac44da671869bebf0de3d4f9aa84...6f1318c474c09ff2e0c6433fffdd7df3b55a5de4

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/b3b6c6b576bfac44da671869bebf0de3d4f9aa84...6f1318c474c09ff2e0c6433fffdd7df3b55a5de4
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230712/b6b0cc9c/attachment-0001.htm>
