From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:15 +0000 (UTC)
Subject: master - configure: relocate generated headers
Message-ID: <20150907154515.9664A60F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9403edbb93a2c337df790408e9ff3d26566b7443
Commit:        9403edbb93a2c337df790408e9ff3d26566b7443
Parent:        ab1b54c3e3244c481a1f8bf5e7c8b48870846bd8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 7 13:49:17 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:40:58 2015 +0200

configure: relocate generated headers

Relocate generated configure.h and lvm-version.h outside
of compilable .c source tree.

The reason is behind - when compiling in builddir != srcdir
the generated file in lib/misc/configure.h was used for all compiled
source file except ones located in lib/misc dir - those would have used
configure.h file located in this dir - if there have existed one (i.e.
from some other build)

This problem was only visible, when srcdir == buildir was used before
trying to use  srcdri != builddir  (as configure.h appeared then in
srcdir).
---
 WHATS_NEW                 |    1 +
 conf/.gitignore           |    2 +
 conf/Makefile.in          |    3 +-
 conf/configure.h.in       |  811 +++++++++++++++++++++++++++++++++++++++++++++
 conf/lvm-version.h.in     |   30 ++
 configure.in              |    4 +-
 include/.symlinks.in      |    4 +-
 lib/Makefile.in           |    2 -
 lib/misc/.gitignore       |    2 -
 lib/misc/configure.h.in   |  811 ---------------------------------------------
 lib/misc/lvm-version.h.in |   30 --
 11 files changed, 850 insertions(+), 850 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3dc7384..5f8846b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Fix usage of configure.h when building in srcdir != builddir.
 
 Version 2.02.130 - 5th September 2015
 =====================================
diff --git a/conf/.gitignore b/conf/.gitignore
index f505a49..4bfc4d3 100644
--- a/conf/.gitignore
+++ b/conf/.gitignore
@@ -2,3 +2,5 @@ command_profile_template.profile
 example.conf
 lvmlocal.conf
 metadata_profile_template.profile
+configure.h
+lvm-version.h
diff --git a/conf/Makefile.in b/conf/Makefile.in
index 128395e..b3ea85b 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -54,4 +54,5 @@ install_lvm2: install_conf install_localconf install_profiles
 
 install: install_lvm2
 
-DISTCLEAN_TARGETS += $(CONFSRC) $(CONFLOCAL) $(PROFILE_TEMPLATES)
+DISTCLEAN_TARGETS += $(CONFSRC) $(CONFLOCAL) $(PROFILE_TEMPLATES) \
+	configure.h lvm-version.h
diff --git a/conf/configure.h.in b/conf/configure.h.in
new file mode 100644
index 0000000..7d157a9
--- /dev/null
+++ b/conf/configure.h.in
@@ -0,0 +1,811 @@
+/* conf/configure.h.in.  Generated from configure.in by autoheader.  */
+
+/* Define to 1 to use libblkid detection of signatures when wiping. */
+#undef BLKID_WIPING_SUPPORT
+
+/* The path to 'cache_check', if available. */
+#undef CACHE_CHECK_CMD
+
+/* Define to 1 if the external 'cache_check' tool requires the
+   --clear-needs-check-flag option */
+#undef CACHE_CHECK_NEEDS_CHECK
+
+/* The path to 'cache_dump', if available. */
+#undef CACHE_DUMP_CMD
+
+/* Define to 1 to include built-in support for cache. */
+#undef CACHE_INTERNAL
+
+/* The path to 'cache_repair', if available. */
+#undef CACHE_REPAIR_CMD
+
+/* The path to 'cache_restore', if available. */
+#undef CACHE_RESTORE_CMD
+
+/* Define to 1 if the `closedir' function returns void instead of `int'. */
+#undef CLOSEDIR_VOID
+
+/* Define to 1 to include built-in support for clustered LVM locking. */
+#undef CLUSTER_LOCKING_INTERNAL
+
+/* Path to clvmd binary. */
+#undef CLVMD_PATH
+
+/* Path to clvmd pidfile. */
+#undef CLVMD_PIDFILE
+
+/* Path to cmirrord pidfile. */
+#undef CMIRRORD_PIDFILE
+
+/* Define to 0 to exclude libSaCkpt. */
+#undef CMIRROR_HAS_CHECKPOINT
+
+/* Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP
+   systems. This function is required for `alloca.c' support on those systems.
+   */
+#undef CRAY_STACKSEG_END
+
+/* Define to 1 if using `alloca.c'. */
+#undef C_ALLOCA
+
+/* Name of default metadata archive subdirectory. */
+#undef DEFAULT_ARCHIVE_SUBDIR
+
+/* Name of default metadata backup subdirectory. */
+#undef DEFAULT_BACKUP_SUBDIR
+
+/* Name of default metadata cache subdirectory. */
+#undef DEFAULT_CACHE_SUBDIR
+
+/* Default data alignment. */
+#undef DEFAULT_DATA_ALIGNMENT
+
+/* Define default node creation behavior with dmsetup create */
+#undef DEFAULT_DM_ADD_NODE
+
+/* Define default name mangling behaviour */
+#undef DEFAULT_DM_NAME_MANGLING
+
+/* Default DM run directory. */
+#undef DEFAULT_DM_RUN_DIR
+
+/* Default system configuration directory. */
+#undef DEFAULT_ETC_DIR
+
+/* Fall back to LVM1 by default if device-mapper is missing from the kernel.
+   */
+#undef DEFAULT_FALLBACK_TO_LVM1
+
+/* Name of default locking directory. */
+#undef DEFAULT_LOCK_DIR
+
+/* Default segtype used for mirror volumes. */
+#undef DEFAULT_MIRROR_SEGTYPE
+
+/* Default directory to keep PID files in. */
+#undef DEFAULT_PID_DIR
+
+/* Name of default configuration profile subdirectory. */
+#undef DEFAULT_PROFILE_SUBDIR
+
+/* Default segtype used for raid10 volumes. */
+#undef DEFAULT_RAID10_SEGTYPE
+
+/* Default LVM run directory. */
+#undef DEFAULT_RUN_DIR
+
+/* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
+#undef DEFAULT_SI_UNIT_CONSISTENCY
+
+/* Default segtype used for sparse volumes. */
+#undef DEFAULT_SPARSE_SEGTYPE
+
+/* Path to LVM system directory. */
+#undef DEFAULT_SYS_DIR
+
+/* Use blkid wiping by default. */
+#undef DEFAULT_USE_BLKID_WIPING
+
+/* Use lvmetad by default. */
+#undef DEFAULT_USE_LVMETAD
+
+/* Use lvmlockd by default. */
+#undef DEFAULT_USE_LVMLOCKD
+
+/* Use lvmpolld by default. */
+#undef DEFAULT_USE_LVMPOLLD
+
+/* Define to 1 to enable LVM2 device-mapper interaction. */
+#undef DEVMAPPER_SUPPORT
+
+/* Define to 1 to enable the device-mapper event daemon. */
+#undef DMEVENTD
+
+/* Path to dmeventd binary. */
+#undef DMEVENTD_PATH
+
+/* Path to dmeventd pidfile. */
+#undef DMEVENTD_PIDFILE
+
+/* Define to enable compat protocol */
+#undef DM_COMPAT
+
+/* Define default group for device node */
+#undef DM_DEVICE_GID
+
+/* Define default mode for device node */
+#undef DM_DEVICE_MODE
+
+/* Define default owner for device node */
+#undef DM_DEVICE_UID
+
+/* Define to enable ioctls calls to kernel */
+#undef DM_IOCTLS
+
+/* Library version */
+#undef DM_LIB_VERSION
+
+/* Define to 1 if you have the `alarm' function. */
+#undef HAVE_ALARM
+
+/* Define to 1 if you have `alloca', as a function or macro. */
+#undef HAVE_ALLOCA
+
+/* Define to 1 if you have <alloca.h> and it should be used (not on Ultrix).
+   */
+#undef HAVE_ALLOCA_H
+
+/* Define to 1 if you have the <arpa/inet.h> header file. */
+#undef HAVE_ARPA_INET_H
+
+/* Define to 1 if you have the <asm/byteorder.h> header file. */
+#undef HAVE_ASM_BYTEORDER_H
+
+/* Define to 1 if you have the <assert.h> header file. */
+#undef HAVE_ASSERT_H
+
+/* Define to 1 if you have the `atexit' function. */
+#undef HAVE_ATEXIT
+
+/* Define to 1 if canonicalize_file_name is available. */
+#undef HAVE_CANONICALIZE_FILE_NAME
+
+/* Define to 1 if your system has a working `chown' function. */
+#undef HAVE_CHOWN
+
+/* Define to 1 if you have the `clock_gettime' function. */
+#undef HAVE_CLOCK_GETTIME
+
+/* Define to 1 if you have the <corosync/cmap.h> header file. */
+#undef HAVE_COROSYNC_CMAP_H
+
+/* Define to 1 if you have the <corosync/confdb.h> header file. */
+#undef HAVE_COROSYNC_CONFDB_H
+
+/* Define to 1 if you have the <ctype.h> header file. */
+#undef HAVE_CTYPE_H
+
+/* Define to 1 if you have the declaration of `strerror_r', and to 0 if you
+   don't. */
+#undef HAVE_DECL_STRERROR_R
+
+/* Define to 1 if you have the <dirent.h> header file. */
+#undef HAVE_DIRENT_H
+
+/* Define to 1 if you have the <dlfcn.h> header file. */
+#undef HAVE_DLFCN_H
+
+/* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
+#undef HAVE_DOPRNT
+
+/* Define to 1 if you have the `dup2' function. */
+#undef HAVE_DUP2
+
+/* Define to 1 if you have the <errno.h> header file. */
+#undef HAVE_ERRNO_H
+
+/* Define to 1 if you have the <fcntl.h> header file. */
+#undef HAVE_FCNTL_H
+
+/* Define to 1 if you have the <float.h> header file. */
+#undef HAVE_FLOAT_H
+
+/* Define to 1 if you have the `fork' function. */
+#undef HAVE_FORK
+
+/* Define to 1 if you have the `ftruncate' function. */
+#undef HAVE_FTRUNCATE
+
+/* Define to 1 if you have the `gethostname' function. */
+#undef HAVE_GETHOSTNAME
+
+/* Define to 1 if getline is available. */
+#undef HAVE_GETLINE
+
+/* Define to 1 if you have the `getmntent' function. */
+#undef HAVE_GETMNTENT
+
+/* Define to 1 if getopt_long is available. */
+#undef HAVE_GETOPTLONG
+
+/* Define to 1 if you have the <getopt.h> header file. */
+#undef HAVE_GETOPT_H
+
+/* Define to 1 if you have the `getpagesize' function. */
+#undef HAVE_GETPAGESIZE
+
+/* Define to 1 if you have the `gettimeofday' function. */
+#undef HAVE_GETTIMEOFDAY
+
+/* Define to 1 if you have the <inttypes.h> header file. */
+#undef HAVE_INTTYPES_H
+
+/* Define to 1 if you have the <langinfo.h> header file. */
+#undef HAVE_LANGINFO_H
+
+/* Define to 1 if you have the <libcman.h> header file. */
+#undef HAVE_LIBCMAN_H
+
+/* Define to 1 if dynamic libraries are available. */
+#undef HAVE_LIBDL
+
+/* Define to 1 if you have the <libdlm.h> header file. */
+#undef HAVE_LIBDLM_H
+
+/* Define to 1 if you have the <libgen.h> header file. */
+#undef HAVE_LIBGEN_H
+
+/* Define to 1 if you have the <libintl.h> header file. */
+#undef HAVE_LIBINTL_H
+
+/* Define to 1 if you have the <limits.h> header file. */
+#undef HAVE_LIMITS_H
+
+/* Define to 1 if you have the <linux/fs.h> header file. */
+#undef HAVE_LINUX_FS_H
+
+/* Define to 1 if you have the <locale.h> header file. */
+#undef HAVE_LOCALE_H
+
+/* Define to 1 if you have the `localtime_r' function. */
+#undef HAVE_LOCALTIME_R
+
+/* Define to 1 if `lstat' has the bug that it succeeds when given the
+   zero-length file name argument. */
+#undef HAVE_LSTAT_EMPTY_STRING_BUG
+
+/* Define to 1 if you have the <machine/endian.h> header file. */
+#undef HAVE_MACHINE_ENDIAN_H
+
+/* Define to 1 if your system has a GNU libc compatible `malloc' function, and
+   to 0 otherwise. */
+#undef HAVE_MALLOC
+
+/* Define to 1 if you have the <malloc.h> header file. */
+#undef HAVE_MALLOC_H
+
+/* Define to 1 if you have the `memchr' function. */
+#undef HAVE_MEMCHR
+
+/* Define to 1 if you have the `memmove' function. */
+#undef HAVE_MEMMOVE
+
+/* Define to 1 if you have the <memory.h> header file. */
+#undef HAVE_MEMORY_H
+
+/* Define to 1 if you have the `memset' function. */
+#undef HAVE_MEMSET
+
+/* Define to 1 if you have the `mkdir' function. */
+#undef HAVE_MKDIR
+
+/* Define to 1 if you have the `mkfifo' function. */
+#undef HAVE_MKFIFO
+
+/* Define to 1 if you have a working `mmap' system call. */
+#undef HAVE_MMAP
+
+/* Define to 1 if you have the <mntent.h> header file. */
+#undef HAVE_MNTENT_H
+
+/* Define to 1 if you have the `munmap' function. */
+#undef HAVE_MUNMAP
+
+/* Define to 1 if you have the <ndir.h> header file, and it defines `DIR'. */
+#undef HAVE_NDIR_H
+
+/* Define to 1 if you have the <netdb.h> header file. */
+#undef HAVE_NETDB_H
+
+/* Define to 1 if you have the <netinet/in.h> header file. */
+#undef HAVE_NETINET_IN_H
+
+/* Define to 1 if you have the `nl_langinfo' function. */
+#undef HAVE_NL_LANGINFO
+
+/* Define to 1 if you have the <paths.h> header file. */
+#undef HAVE_PATHS_H
+
+/* Define to 1 if you have the <pthread.h> header file. */
+#undef HAVE_PTHREAD_H
+
+/* Define to 1 if the system has the type `ptrdiff_t'. */
+#undef HAVE_PTRDIFF_T
+
+/* Define to 1 if you have the <readline/history.h> header file. */
+#undef HAVE_READLINE_HISTORY_H
+
+/* Define to 1 if you have the <readline/readline.h> header file. */
+#undef HAVE_READLINE_READLINE_H
+
+/* Define to 1 if your system has a GNU libc compatible `realloc' function,
+   and to 0 otherwise. */
+#undef HAVE_REALLOC
+
+/* Define to 1 if you have the `realpath' function. */
+#undef HAVE_REALPATH
+
+/* Define to 1 to include support for realtime clock. */
+#undef HAVE_REALTIME
+
+/* Define to 1 if you have the `rl_completion_matches' function. */
+#undef HAVE_RL_COMPLETION_MATCHES
+
+/* Define to 1 if you have the `rmdir' function. */
+#undef HAVE_RMDIR
+
+/* Define to 1 if you have the <search.h> header file. */
+#undef HAVE_SEARCH_H
+
+/* Define to 1 if you have the `select' function. */
+#undef HAVE_SELECT
+
+/* Define to 1 to include support for selinux. */
+#undef HAVE_SELINUX
+
+/* Define to 1 if you have the <selinux/label.h> header file. */
+#undef HAVE_SELINUX_LABEL_H
+
+/* Define to 1 if you have the <selinux/selinux.h> header file. */
+#undef HAVE_SELINUX_SELINUX_H
+
+/* Define to 1 if sepol_check_context is available. */
+#undef HAVE_SEPOL
+
+/* Define to 1 if you have the `setenv' function. */
+#undef HAVE_SETENV
+
+/* Define to 1 if you have the `setlocale' function. */
+#undef HAVE_SETLOCALE
+
+/* Define to 1 if you have the <signal.h> header file. */
+#undef HAVE_SIGNAL_H
+
+/* Define to 1 if you have the `socket' function. */
+#undef HAVE_SOCKET
+
+/* Define to 1 if `stat' has the bug that it succeeds when given the
+   zero-length file name argument. */
+#undef HAVE_STAT_EMPTY_STRING_BUG
+
+/* Define if struct stat has a field st_ctim with timespec for ctime */
+#undef HAVE_STAT_ST_CTIM
+
+/* Define to 1 if you have the <stdarg.h> header file. */
+#undef HAVE_STDARG_H
+
+/* Define to 1 if stdbool.h conforms to C99. */
+#undef HAVE_STDBOOL_H
+
+/* Define to 1 if you have the <stddef.h> header file. */
+#undef HAVE_STDDEF_H
+
+/* Define to 1 if you have the <stdint.h> header file. */
+#undef HAVE_STDINT_H
+
+/* Define to 1 if you have the <stdio.h> header file. */
+#undef HAVE_STDIO_H
+
+/* Define to 1 if you have the <stdlib.h> header file. */
+#undef HAVE_STDLIB_H
+
+/* Define to 1 if you have the `strcasecmp' function. */
+#undef HAVE_STRCASECMP
+
+/* Define to 1 if you have the `strchr' function. */
+#undef HAVE_STRCHR
+
+/* Define to 1 if you have the `strcspn' function. */
+#undef HAVE_STRCSPN
+
+/* Define to 1 if you have the `strdup' function. */
+#undef HAVE_STRDUP
+
+/* Define to 1 if you have the `strerror' function. */
+#undef HAVE_STRERROR
+
+/* Define to 1 if you have the `strerror_r' function. */
+#undef HAVE_STRERROR_R
+
+/* Define to 1 if you have the <strings.h> header file. */
+#undef HAVE_STRINGS_H
+
+/* Define to 1 if you have the <string.h> header file. */
+#undef HAVE_STRING_H
+
+/* Define to 1 if you have the `strncasecmp' function. */
+#undef HAVE_STRNCASECMP
+
+/* Define to 1 if you have the `strndup' function. */
+#undef HAVE_STRNDUP
+
+/* Define to 1 if you have the `strpbrk' function. */
+#undef HAVE_STRPBRK
+
+/* Define to 1 if you have the `strrchr' function. */
+#undef HAVE_STRRCHR
+
+/* Define to 1 if you have the `strspn' function. */
+#undef HAVE_STRSPN
+
+/* Define to 1 if you have the `strstr' function. */
+#undef HAVE_STRSTR
+
+/* Define to 1 if you have the `strtol' function. */
+#undef HAVE_STRTOL
+
+/* Define to 1 if you have the `strtoul' function. */
+#undef HAVE_STRTOUL
+
+/* Define to 1 if you have the `strtoull' function. */
+#undef HAVE_STRTOULL
+
+/* Define to 1 if `st_rdev' is a member of `struct stat'. */
+#undef HAVE_STRUCT_STAT_ST_RDEV
+
+/* Define to 1 if you have the <syslog.h> header file. */
+#undef HAVE_SYSLOG_H
+
+/* Define to 1 if you have the <sys/dir.h> header file, and it defines `DIR'.
+   */
+#undef HAVE_SYS_DIR_H
+
+/* Define to 1 if you have the <sys/disk.h> header file. */
+#undef HAVE_SYS_DISK_H
+
+/* Define to 1 if you have the <sys/file.h> header file. */
+#undef HAVE_SYS_FILE_H
+
+/* Define to 1 if you have the <sys/ioctl.h> header file. */
+#undef HAVE_SYS_IOCTL_H
+
+/* Define to 1 if you have the <sys/ipc.h> header file. */
+#undef HAVE_SYS_IPC_H
+
+/* Define to 1 if you have the <sys/mman.h> header file. */
+#undef HAVE_SYS_MMAN_H
+
+/* Define to 1 if you have the <sys/mount.h> header file. */
+#undef HAVE_SYS_MOUNT_H
+
+/* Define to 1 if you have the <sys/ndir.h> header file, and it defines `DIR'.
+   */
+#undef HAVE_SYS_NDIR_H
+
+/* Define to 1 if you have the <sys/param.h> header file. */
+#undef HAVE_SYS_PARAM_H
+
+/* Define to 1 if you have the <sys/resource.h> header file. */
+#undef HAVE_SYS_RESOURCE_H
+
+/* Define to 1 if you have the <sys/select.h> header file. */
+#undef HAVE_SYS_SELECT_H
+
+/* Define to 1 if you have the <sys/sem.h> header file. */
+#undef HAVE_SYS_SEM_H
+
+/* Define to 1 if you have the <sys/socket.h> header file. */
+#undef HAVE_SYS_SOCKET_H
+
+/* Define to 1 if you have the <sys/statvfs.h> header file. */
+#undef HAVE_SYS_STATVFS_H
+
+/* Define to 1 if you have the <sys/stat.h> header file. */
+#undef HAVE_SYS_STAT_H
+
+/* Define to 1 if you have the <sys/timerfd.h> header file. */
+#undef HAVE_SYS_TIMERFD_H
+
+/* Define to 1 if you have the <sys/time.h> header file. */
+#undef HAVE_SYS_TIME_H
+
+/* Define to 1 if you have the <sys/types.h> header file. */
+#undef HAVE_SYS_TYPES_H
+
+/* Define to 1 if you have the <sys/uio.h> header file. */
+#undef HAVE_SYS_UIO_H
+
+/* Define to 1 if you have the <sys/un.h> header file. */
+#undef HAVE_SYS_UN_H
+
+/* Define to 1 if you have the <sys/utsname.h> header file. */
+#undef HAVE_SYS_UTSNAME_H
+
+/* Define to 1 if you have the <sys/wait.h> header file. */
+#undef HAVE_SYS_WAIT_H
+
+/* Define to 1 if you have the <termios.h> header file. */
+#undef HAVE_TERMIOS_H
+
+/* Define to 1 if you have the <time.h> header file. */
+#undef HAVE_TIME_H
+
+/* Define to 1 if you have the `uname' function. */
+#undef HAVE_UNAME
+
+/* Define to 1 if you have the <unistd.h> header file. */
+#undef HAVE_UNISTD_H
+
+/* Define to 1 if you have the <utmpx.h> header file. */
+#undef HAVE_UTMPX_H
+
+/* valgrind.h found */
+#undef HAVE_VALGRIND
+
+/* Define to 1 if you have the `vfork' function. */
+#undef HAVE_VFORK
+
+/* Define to 1 if you have the <vfork.h> header file. */
+#undef HAVE_VFORK_H
+
+/* Define to 1 if you have the `vprintf' function. */
+#undef HAVE_VPRINTF
+
+/* Define to 1 if `fork' works. */
+#undef HAVE_WORKING_FORK
+
+/* Define to 1 if `vfork' works. */
+#undef HAVE_WORKING_VFORK
+
+/* Define to 1 if the system has the type `_Bool'. */
+#undef HAVE__BOOL
+
+/* Internalization package */
+#undef INTL_PACKAGE
+
+/* Locale-dependent data */
+#undef LOCALEDIR
+
+/* Define to 1 to include code that uses lvmlockd dlm option. */
+#undef LOCKDDLM_SUPPORT
+
+/* Define to 1 to include code that uses lvmlockd sanlock option. */
+#undef LOCKDSANLOCK_SUPPORT
+
+/* Define to 1 if `lstat' dereferences a symlink specified with a trailing
+   slash. */
+#undef LSTAT_FOLLOWS_SLASHED_SYMLINK
+
+/* Define to 1 if 'lvm' should fall back to using LVM1 binaries if
+   device-mapper is missing from the kernel */
+#undef LVM1_FALLBACK
+
+/* Define to 1 to include built-in support for LVM1 metadata. */
+#undef LVM1_INTERNAL
+
+/* Path to lvmetad pidfile. */
+#undef LVMETAD_PIDFILE
+
+/* Define to 1 to include code that uses lvmetad. */
+#undef LVMETAD_SUPPORT
+
+/* Path to lvmlockd pidfile. */
+#undef LVMLOCKD_PIDFILE
+
+/* Define to 1 to include code that uses lvmlockd. */
+#undef LVMLOCKD_SUPPORT
+
+/* Path to lvmpolld pidfile. */
+#undef LVMPOLLD_PIDFILE
+
+/* Define to 1 to include code that uses lvmpolld. */
+#undef LVMPOLLD_SUPPORT
+
+/* Path to lvm binary. */
+#undef LVM_PATH
+
+/* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
+   */
+#undef MAJOR_IN_MKDEV
+
+/* Define to 1 if `major', `minor', and `makedev' are declared in
+   <sysmacros.h>. */
+#undef MAJOR_IN_SYSMACROS
+
+/* Define to 1 to include built-in support for mirrors. */
+#undef MIRRORED_INTERNAL
+
+/* The path to 'modprobe', if available. */
+#undef MODPROBE_CMD
+
+/* Define to 1 to enable O_DIRECT support. */
+#undef O_DIRECT_SUPPORT
+
+/* Define to the address where bug reports for this package should be sent. */
+#undef PACKAGE_BUGREPORT
+
+/* Define to the full name of this package. */
+#undef PACKAGE_NAME
+
+/* Define to the full name and version of this package. */
+#undef PACKAGE_STRING
+
+/* Define to the one symbol short name of this package. */
+#undef PACKAGE_TARNAME
+
+/* Define to the home page for this package. */
+#undef PACKAGE_URL
+
+/* Define to the version of this package. */
+#undef PACKAGE_VERSION
+
+/* Define to 1 to include built-in support for GFS pool metadata. */
+#undef POOL_INTERNAL
+
+/* Define to 1 to include built-in support for raid. */
+#undef RAID_INTERNAL
+
+/* Define to 1 to include the LVM readline shell. */
+#undef READLINE_SUPPORT
+
+/* Define to 1 to include built-in support for replicators. */
+#undef REPLICATOR_INTERNAL
+
+/* Define as the return type of signal handlers (`int' or `void'). */
+#undef RETSIGTYPE
+
+/* Define to the type of arg 1 for `select'. */
+#undef SELECT_TYPE_ARG1
+
+/* Define to the type of args 2, 3 and 4 for `select'. */
+#undef SELECT_TYPE_ARG234
+
+/* Define to the type of arg 5 for `select'. */
+#undef SELECT_TYPE_ARG5
+
+/* Define to 1 to include built-in support for snapshots. */
+#undef SNAPSHOT_INTERNAL
+
+/* If using the C implementation of alloca, define if you know the
+   direction of stack growth for your system; otherwise it will be
+   automatically deduced at runtime.
+	STACK_DIRECTION > 0 => grows toward higher addresses
+	STACK_DIRECTION < 0 => grows toward lower addresses
+	STACK_DIRECTION = 0 => direction of growth unknown */
+#undef STACK_DIRECTION
+
+/* Define to 1 if you have the ANSI C header files. */
+#undef STDC_HEADERS
+
+/* Define to 1 if strerror_r returns char *. */
+#undef STRERROR_R_CHAR_P
+
+/* Path to testsuite data */
+#undef TESTSUITE_DATA
+
+/* The path to 'thin_check', if available. */
+#undef THIN_CHECK_CMD
+
+/* Define to 1 if the external 'thin_check' tool requires the
+   --clear-needs-check-flag option */
+#undef THIN_CHECK_NEEDS_CHECK
+
+/* The path to 'thin_dump', if available. */
+#undef THIN_DUMP_CMD
+
+/* Define to 1 to include built-in support for thin provisioning. */
+#undef THIN_INTERNAL
+
+/* The path to 'thin_repair', if available. */
+#undef THIN_REPAIR_CMD
+
+/* The path to 'thin_restore', if available. */
+#undef THIN_RESTORE_CMD
+
+/* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
+#undef TIME_WITH_SYS_TIME
+
+/* Define to 1 if your <sys/time.h> declares `struct tm'. */
+#undef TM_IN_SYS_TIME
+
+/* Define to 1 to enable synchronisation with udev processing. */
+#undef UDEV_SYNC_SUPPORT
+
+/* Enable a valgrind aware build of pool */
+#undef VALGRIND_POOL
+
+/* Define for Solaris 2.5.1 so the uint32_t typedef from <sys/synch.h>,
+   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
+   #define below would cause a syntax error. */
+#undef _UINT32_T
+
+/* Define for Solaris 2.5.1 so the uint64_t typedef from <sys/synch.h>,
+   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
+   #define below would cause a syntax error. */
+#undef _UINT64_T
+
+/* Define for Solaris 2.5.1 so the uint8_t typedef from <sys/synch.h>,
+   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
+   #define below would cause a syntax error. */
+#undef _UINT8_T
+
+/* Define to empty if `const' does not conform to ANSI C. */
+#undef const
+
+/* Define to `int' if <sys/types.h> doesn't define. */
+#undef gid_t
+
+/* Define to `__inline__' or `__inline' if that's what the C compiler
+   calls it, or to nothing if 'inline' is not supported under any name.  */
+#ifndef __cplusplus
+#undef inline
+#endif
+
+/* Define to the type of a signed integer type of width exactly 16 bits if
+   such a type exists and the standard includes do not define it. */
+#undef int16_t
+
+/* Define to the type of a signed integer type of width exactly 32 bits if
+   such a type exists and the standard includes do not define it. */
+#undef int32_t
+
+/* Define to the type of a signed integer type of width exactly 64 bits if
+   such a type exists and the standard includes do not define it. */
+#undef int64_t
+
+/* Define to the type of a signed integer type of width exactly 8 bits if such
+   a type exists and the standard includes do not define it. */
+#undef int8_t
+
+/* Define to rpl_malloc if the replacement function should be used. */
+#undef malloc
+
+/* Define to `int' if <sys/types.h> does not define. */
+#undef mode_t
+
+/* Define to `long int' if <sys/types.h> does not define. */
+#undef off_t
+
+/* Define to `int' if <sys/types.h> does not define. */
+#undef pid_t
+
+/* Define to rpl_realloc if the replacement function should be used. */
+#undef realloc
+
+/* Define to `unsigned int' if <sys/types.h> does not define. */
+#undef size_t
+
+/* Define to `int' if <sys/types.h> does not define. */
+#undef ssize_t
+
+/* Define to `int' if <sys/types.h> doesn't define. */
+#undef uid_t
+
+/* Define to the type of an unsigned integer type of width exactly 16 bits if
+   such a type exists and the standard includes do not define it. */
+#undef uint16_t
+
+/* Define to the type of an unsigned integer type of width exactly 32 bits if
+   such a type exists and the standard includes do not define it. */
+#undef uint32_t
+
+/* Define to the type of an unsigned integer type of width exactly 64 bits if
+   such a type exists and the standard includes do not define it. */
+#undef uint64_t
+
+/* Define to the type of an unsigned integer type of width exactly 8 bits if
+   such a type exists and the standard includes do not define it. */
+#undef uint8_t
+
+/* Define as `fork' if `vfork' does not work. */
+#undef vfork
diff --git a/conf/lvm-version.h.in b/conf/lvm-version.h.in
new file mode 100644
index 0000000..2574890
--- /dev/null
+++ b/conf/lvm-version.h.in
@@ -0,0 +1,30 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_VERSION_H
+/**
+ * The LVM version number
+ *
+ * LVM_MAJOR.LVM_MINOR.LVM_PATCHLEVEL(LVM_LIBAPI)[-LVM_RELEASE]
+ */
+
+#define LVM_VERSION @LVM_VERSION@
+#define LVM_MAJOR @LVM_MAJOR@
+#define LVM_MINOR @LVM_MINOR@
+#define LVM_PATCHLEVEL @LVM_PATCHLEVEL@
+#define LVM_LIBAPI @LVM_LIBAPI@
+#define LVM_RELEASE @LVM_RELEASE@
+#define LVM_RELEASE_DATE @LVM_RELEASE_DATE@
+#endif
diff --git a/configure.in b/configure.in
index 868b373..3b58527 100644
--- a/configure.in
+++ b/configure.in
@@ -16,7 +16,7 @@ AC_PREREQ(2.61)
 dnl -- Process this file with autoconf to produce a configure script.
 AC_INIT
 AC_CONFIG_SRCDIR([lib/device/dev-cache.h])
-AC_CONFIG_HEADERS([lib/misc/configure.h])
+AC_CONFIG_HEADERS([conf/configure.h])
 
 ################################################################################
 dnl -- Setup the directory where autoconf has auxilary files
@@ -2077,7 +2077,7 @@ lib/format_pool/Makefile
 lib/locking/Makefile
 lib/mirror/Makefile
 lib/replicator/Makefile
-lib/misc/lvm-version.h
+conf/lvm-version.h
 lib/raid/Makefile
 lib/snapshot/Makefile
 lib/thin/Makefile
diff --git a/include/.symlinks.in b/include/.symlinks.in
index e78072a..77f23bc 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -1,3 +1,5 @@
+ at top_builddir@/conf/configure.h
+ at top_builddir@/conf/lvm-version.h
 @top_srcdir@/daemons/clvmd/clvm.h
 @top_srcdir@/daemons/dmeventd/libdevmapper-event.h
 @top_srcdir@/daemons/lvmetad/lvmetad-client.h
@@ -45,7 +47,6 @@
 @top_srcdir@/lib/metadata/vg.h
 @top_srcdir@/lib/mm/memlock.h
 @top_srcdir@/lib/mm/xlate.h
- at top_builddir@/lib/misc/configure.h
 @top_srcdir@/lib/misc/crc.h
 @top_srcdir@/lib/misc/intl.h
 @top_srcdir@/lib/misc/last-path-component.h
@@ -56,7 +57,6 @@
 @top_srcdir@/lib/misc/lvm-globals.h
 @top_srcdir@/lib/misc/lvm-signal.h
 @top_srcdir@/lib/misc/lvm-string.h
- at top_builddir@/lib/misc/lvm-version.h
 @top_srcdir@/lib/misc/lvm-percent.h
 @top_srcdir@/lib/misc/lvm-wrappers.h
 @top_srcdir@/lib/misc/sharedlib.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index e29ff29..ec80c7c 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -229,5 +229,3 @@ include $(top_builddir)/make.tmpl
 CFLAGS += $(BLKID_CFLAGS) $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
 
 $(SUBDIRS): $(LIB_STATIC)
-
-DISTCLEAN_TARGETS += misc/configure.h misc/lvm-version.h
diff --git a/lib/misc/.gitignore b/lib/misc/.gitignore
deleted file mode 100644
index 396884b..0000000
--- a/lib/misc/.gitignore
+++ /dev/null
@@ -1,2 +0,0 @@
-configure.h
-lvm-version.h
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
deleted file mode 100644
index a21d807..0000000
--- a/lib/misc/configure.h.in
+++ /dev/null
@@ -1,811 +0,0 @@
-/* lib/misc/configure.h.in.  Generated from configure.in by autoheader.  */
-
-/* Define to 1 to use libblkid detection of signatures when wiping. */
-#undef BLKID_WIPING_SUPPORT
-
-/* The path to 'cache_check', if available. */
-#undef CACHE_CHECK_CMD
-
-/* Define to 1 if the external 'cache_check' tool requires the
-   --clear-needs-check-flag option */
-#undef CACHE_CHECK_NEEDS_CHECK
-
-/* The path to 'cache_dump', if available. */
-#undef CACHE_DUMP_CMD
-
-/* Define to 1 to include built-in support for cache. */
-#undef CACHE_INTERNAL
-
-/* The path to 'cache_repair', if available. */
-#undef CACHE_REPAIR_CMD
-
-/* The path to 'cache_restore', if available. */
-#undef CACHE_RESTORE_CMD
-
-/* Define to 1 if the `closedir' function returns void instead of `int'. */
-#undef CLOSEDIR_VOID
-
-/* Define to 1 to include built-in support for clustered LVM locking. */
-#undef CLUSTER_LOCKING_INTERNAL
-
-/* Path to clvmd binary. */
-#undef CLVMD_PATH
-
-/* Path to clvmd pidfile. */
-#undef CLVMD_PIDFILE
-
-/* Path to cmirrord pidfile. */
-#undef CMIRRORD_PIDFILE
-
-/* Define to 0 to exclude libSaCkpt. */
-#undef CMIRROR_HAS_CHECKPOINT
-
-/* Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP
-   systems. This function is required for `alloca.c' support on those systems.
-   */
-#undef CRAY_STACKSEG_END
-
-/* Define to 1 if using `alloca.c'. */
-#undef C_ALLOCA
-
-/* Name of default metadata archive subdirectory. */
-#undef DEFAULT_ARCHIVE_SUBDIR
-
-/* Name of default metadata backup subdirectory. */
-#undef DEFAULT_BACKUP_SUBDIR
-
-/* Name of default metadata cache subdirectory. */
-#undef DEFAULT_CACHE_SUBDIR
-
-/* Default data alignment. */
-#undef DEFAULT_DATA_ALIGNMENT
-
-/* Define default node creation behavior with dmsetup create */
-#undef DEFAULT_DM_ADD_NODE
-
-/* Define default name mangling behaviour */
-#undef DEFAULT_DM_NAME_MANGLING
-
-/* Default DM run directory. */
-#undef DEFAULT_DM_RUN_DIR
-
-/* Default system configuration directory. */
-#undef DEFAULT_ETC_DIR
-
-/* Fall back to LVM1 by default if device-mapper is missing from the kernel.
-   */
-#undef DEFAULT_FALLBACK_TO_LVM1
-
-/* Name of default locking directory. */
-#undef DEFAULT_LOCK_DIR
-
-/* Default segtype used for mirror volumes. */
-#undef DEFAULT_MIRROR_SEGTYPE
-
-/* Default directory to keep PID files in. */
-#undef DEFAULT_PID_DIR
-
-/* Name of default configuration profile subdirectory. */
-#undef DEFAULT_PROFILE_SUBDIR
-
-/* Default segtype used for raid10 volumes. */
-#undef DEFAULT_RAID10_SEGTYPE
-
-/* Default LVM run directory. */
-#undef DEFAULT_RUN_DIR
-
-/* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
-#undef DEFAULT_SI_UNIT_CONSISTENCY
-
-/* Default segtype used for sparse volumes. */
-#undef DEFAULT_SPARSE_SEGTYPE
-
-/* Path to LVM system directory. */
-#undef DEFAULT_SYS_DIR
-
-/* Use blkid wiping by default. */
-#undef DEFAULT_USE_BLKID_WIPING
-
-/* Use lvmetad by default. */
-#undef DEFAULT_USE_LVMETAD
-
-/* Use lvmlockd by default. */
-#undef DEFAULT_USE_LVMLOCKD
-
-/* Use lvmpolld by default. */
-#undef DEFAULT_USE_LVMPOLLD
-
-/* Define to 1 to enable LVM2 device-mapper interaction. */
-#undef DEVMAPPER_SUPPORT
-
-/* Define to 1 to enable the device-mapper event daemon. */
-#undef DMEVENTD
-
-/* Path to dmeventd binary. */
-#undef DMEVENTD_PATH
-
-/* Path to dmeventd pidfile. */
-#undef DMEVENTD_PIDFILE
-
-/* Define to enable compat protocol */
-#undef DM_COMPAT
-
-/* Define default group for device node */
-#undef DM_DEVICE_GID
-
-/* Define default mode for device node */
-#undef DM_DEVICE_MODE
-
-/* Define default owner for device node */
-#undef DM_DEVICE_UID
-
-/* Define to enable ioctls calls to kernel */
-#undef DM_IOCTLS
-
-/* Library version */
-#undef DM_LIB_VERSION
-
-/* Define to 1 if you have the `alarm' function. */
-#undef HAVE_ALARM
-
-/* Define to 1 if you have `alloca', as a function or macro. */
-#undef HAVE_ALLOCA
-
-/* Define to 1 if you have <alloca.h> and it should be used (not on Ultrix).
-   */
-#undef HAVE_ALLOCA_H
-
-/* Define to 1 if you have the <arpa/inet.h> header file. */
-#undef HAVE_ARPA_INET_H
-
-/* Define to 1 if you have the <asm/byteorder.h> header file. */
-#undef HAVE_ASM_BYTEORDER_H
-
-/* Define to 1 if you have the <assert.h> header file. */
-#undef HAVE_ASSERT_H
-
-/* Define to 1 if you have the `atexit' function. */
-#undef HAVE_ATEXIT
-
-/* Define to 1 if canonicalize_file_name is available. */
-#undef HAVE_CANONICALIZE_FILE_NAME
-
-/* Define to 1 if your system has a working `chown' function. */
-#undef HAVE_CHOWN
-
-/* Define to 1 if you have the `clock_gettime' function. */
-#undef HAVE_CLOCK_GETTIME
-
-/* Define to 1 if you have the <corosync/cmap.h> header file. */
-#undef HAVE_COROSYNC_CMAP_H
-
-/* Define to 1 if you have the <corosync/confdb.h> header file. */
-#undef HAVE_COROSYNC_CONFDB_H
-
-/* Define to 1 if you have the <ctype.h> header file. */
-#undef HAVE_CTYPE_H
-
-/* Define to 1 if you have the declaration of `strerror_r', and to 0 if you
-   don't. */
-#undef HAVE_DECL_STRERROR_R
-
-/* Define to 1 if you have the <dirent.h> header file. */
-#undef HAVE_DIRENT_H
-
-/* Define to 1 if you have the <dlfcn.h> header file. */
-#undef HAVE_DLFCN_H
-
-/* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
-#undef HAVE_DOPRNT
-
-/* Define to 1 if you have the `dup2' function. */
-#undef HAVE_DUP2
-
-/* Define to 1 if you have the <errno.h> header file. */
-#undef HAVE_ERRNO_H
-
-/* Define to 1 if you have the <fcntl.h> header file. */
-#undef HAVE_FCNTL_H
-
-/* Define to 1 if you have the <float.h> header file. */
-#undef HAVE_FLOAT_H
-
-/* Define to 1 if you have the `fork' function. */
-#undef HAVE_FORK
-
-/* Define to 1 if you have the `ftruncate' function. */
-#undef HAVE_FTRUNCATE
-
-/* Define to 1 if you have the `gethostname' function. */
-#undef HAVE_GETHOSTNAME
-
-/* Define to 1 if getline is available. */
-#undef HAVE_GETLINE
-
-/* Define to 1 if you have the `getmntent' function. */
-#undef HAVE_GETMNTENT
-
-/* Define to 1 if getopt_long is available. */
-#undef HAVE_GETOPTLONG
-
-/* Define to 1 if you have the <getopt.h> header file. */
-#undef HAVE_GETOPT_H
-
-/* Define to 1 if you have the `getpagesize' function. */
-#undef HAVE_GETPAGESIZE
-
-/* Define to 1 if you have the `gettimeofday' function. */
-#undef HAVE_GETTIMEOFDAY
-
-/* Define to 1 if you have the <inttypes.h> header file. */
-#undef HAVE_INTTYPES_H
-
-/* Define to 1 if you have the <langinfo.h> header file. */
-#undef HAVE_LANGINFO_H
-
-/* Define to 1 if you have the <libcman.h> header file. */
-#undef HAVE_LIBCMAN_H
-
-/* Define to 1 if dynamic libraries are available. */
-#undef HAVE_LIBDL
-
-/* Define to 1 if you have the <libdlm.h> header file. */
-#undef HAVE_LIBDLM_H
-
-/* Define to 1 if you have the <libgen.h> header file. */
-#undef HAVE_LIBGEN_H
-
-/* Define to 1 if you have the <libintl.h> header file. */
-#undef HAVE_LIBINTL_H
-
-/* Define to 1 if you have the <limits.h> header file. */
-#undef HAVE_LIMITS_H
-
-/* Define to 1 if you have the <linux/fs.h> header file. */
-#undef HAVE_LINUX_FS_H
-
-/* Define to 1 if you have the <locale.h> header file. */
-#undef HAVE_LOCALE_H
-
-/* Define to 1 if you have the `localtime_r' function. */
-#undef HAVE_LOCALTIME_R
-
-/* Define to 1 if `lstat' has the bug that it succeeds when given the
-   zero-length file name argument. */
-#undef HAVE_LSTAT_EMPTY_STRING_BUG
-
-/* Define to 1 if you have the <machine/endian.h> header file. */
-#undef HAVE_MACHINE_ENDIAN_H
-
-/* Define to 1 if your system has a GNU libc compatible `malloc' function, and
-   to 0 otherwise. */
-#undef HAVE_MALLOC
-
-/* Define to 1 if you have the <malloc.h> header file. */
-#undef HAVE_MALLOC_H
-
-/* Define to 1 if you have the `memchr' function. */
-#undef HAVE_MEMCHR
-
-/* Define to 1 if you have the `memmove' function. */
-#undef HAVE_MEMMOVE
-
-/* Define to 1 if you have the <memory.h> header file. */
-#undef HAVE_MEMORY_H
-
-/* Define to 1 if you have the `memset' function. */
-#undef HAVE_MEMSET
-
-/* Define to 1 if you have the `mkdir' function. */
-#undef HAVE_MKDIR
-
-/* Define to 1 if you have the `mkfifo' function. */
-#undef HAVE_MKFIFO
-
-/* Define to 1 if you have a working `mmap' system call. */
-#undef HAVE_MMAP
-
-/* Define to 1 if you have the <mntent.h> header file. */
-#undef HAVE_MNTENT_H
-
-/* Define to 1 if you have the `munmap' function. */
-#undef HAVE_MUNMAP
-
-/* Define to 1 if you have the <ndir.h> header file, and it defines `DIR'. */
-#undef HAVE_NDIR_H
-
-/* Define to 1 if you have the <netdb.h> header file. */
-#undef HAVE_NETDB_H
-
-/* Define to 1 if you have the <netinet/in.h> header file. */
-#undef HAVE_NETINET_IN_H
-
-/* Define to 1 if you have the `nl_langinfo' function. */
-#undef HAVE_NL_LANGINFO
-
-/* Define to 1 if you have the <paths.h> header file. */
-#undef HAVE_PATHS_H
-
-/* Define to 1 if you have the <pthread.h> header file. */
-#undef HAVE_PTHREAD_H
-
-/* Define to 1 if the system has the type `ptrdiff_t'. */
-#undef HAVE_PTRDIFF_T
-
-/* Define to 1 if you have the <readline/history.h> header file. */
-#undef HAVE_READLINE_HISTORY_H
-
-/* Define to 1 if you have the <readline/readline.h> header file. */
-#undef HAVE_READLINE_READLINE_H
-
-/* Define to 1 if your system has a GNU libc compatible `realloc' function,
-   and to 0 otherwise. */
-#undef HAVE_REALLOC
-
-/* Define to 1 if you have the `realpath' function. */
-#undef HAVE_REALPATH
-
-/* Define to 1 to include support for realtime clock. */
-#undef HAVE_REALTIME
-
-/* Define to 1 if you have the `rl_completion_matches' function. */
-#undef HAVE_RL_COMPLETION_MATCHES
-
-/* Define to 1 if you have the `rmdir' function. */
-#undef HAVE_RMDIR
-
-/* Define to 1 if you have the <search.h> header file. */
-#undef HAVE_SEARCH_H
-
-/* Define to 1 if you have the `select' function. */
-#undef HAVE_SELECT
-
-/* Define to 1 to include support for selinux. */
-#undef HAVE_SELINUX
-
-/* Define to 1 if you have the <selinux/label.h> header file. */
-#undef HAVE_SELINUX_LABEL_H
-
-/* Define to 1 if you have the <selinux/selinux.h> header file. */
-#undef HAVE_SELINUX_SELINUX_H
-
-/* Define to 1 if sepol_check_context is available. */
-#undef HAVE_SEPOL
-
-/* Define to 1 if you have the `setenv' function. */
-#undef HAVE_SETENV
-
-/* Define to 1 if you have the `setlocale' function. */
-#undef HAVE_SETLOCALE
-
-/* Define to 1 if you have the <signal.h> header file. */
-#undef HAVE_SIGNAL_H
-
-/* Define to 1 if you have the `socket' function. */
-#undef HAVE_SOCKET
-
-/* Define to 1 if `stat' has the bug that it succeeds when given the
-   zero-length file name argument. */
-#undef HAVE_STAT_EMPTY_STRING_BUG
-
-/* Define if struct stat has a field st_ctim with timespec for ctime */
-#undef HAVE_STAT_ST_CTIM
-
-/* Define to 1 if you have the <stdarg.h> header file. */
-#undef HAVE_STDARG_H
-
-/* Define to 1 if stdbool.h conforms to C99. */
-#undef HAVE_STDBOOL_H
-
-/* Define to 1 if you have the <stddef.h> header file. */
-#undef HAVE_STDDEF_H
-
-/* Define to 1 if you have the <stdint.h> header file. */
-#undef HAVE_STDINT_H
-
-/* Define to 1 if you have the <stdio.h> header file. */
-#undef HAVE_STDIO_H
-
-/* Define to 1 if you have the <stdlib.h> header file. */
-#undef HAVE_STDLIB_H
-
-/* Define to 1 if you have the `strcasecmp' function. */
-#undef HAVE_STRCASECMP
-
-/* Define to 1 if you have the `strchr' function. */
-#undef HAVE_STRCHR
-
-/* Define to 1 if you have the `strcspn' function. */
-#undef HAVE_STRCSPN
-
-/* Define to 1 if you have the `strdup' function. */
-#undef HAVE_STRDUP
-
-/* Define to 1 if you have the `strerror' function. */
-#undef HAVE_STRERROR
-
-/* Define to 1 if you have the `strerror_r' function. */
-#undef HAVE_STRERROR_R
-
-/* Define to 1 if you have the <strings.h> header file. */
-#undef HAVE_STRINGS_H
-
-/* Define to 1 if you have the <string.h> header file. */
-#undef HAVE_STRING_H
-
-/* Define to 1 if you have the `strncasecmp' function. */
-#undef HAVE_STRNCASECMP
-
-/* Define to 1 if you have the `strndup' function. */
-#undef HAVE_STRNDUP
-
-/* Define to 1 if you have the `strpbrk' function. */
-#undef HAVE_STRPBRK
-
-/* Define to 1 if you have the `strrchr' function. */
-#undef HAVE_STRRCHR
-
-/* Define to 1 if you have the `strspn' function. */
-#undef HAVE_STRSPN
-
-/* Define to 1 if you have the `strstr' function. */
-#undef HAVE_STRSTR
-
-/* Define to 1 if you have the `strtol' function. */
-#undef HAVE_STRTOL
-
-/* Define to 1 if you have the `strtoul' function. */
-#undef HAVE_STRTOUL
-
-/* Define to 1 if you have the `strtoull' function. */
-#undef HAVE_STRTOULL
-
-/* Define to 1 if `st_rdev' is a member of `struct stat'. */
-#undef HAVE_STRUCT_STAT_ST_RDEV
-
-/* Define to 1 if you have the <syslog.h> header file. */
-#undef HAVE_SYSLOG_H
-
-/* Define to 1 if you have the <sys/dir.h> header file, and it defines `DIR'.
-   */
-#undef HAVE_SYS_DIR_H
-
-/* Define to 1 if you have the <sys/disk.h> header file. */
-#undef HAVE_SYS_DISK_H
-
-/* Define to 1 if you have the <sys/file.h> header file. */
-#undef HAVE_SYS_FILE_H
-
-/* Define to 1 if you have the <sys/ioctl.h> header file. */
-#undef HAVE_SYS_IOCTL_H
-
-/* Define to 1 if you have the <sys/ipc.h> header file. */
-#undef HAVE_SYS_IPC_H
-
-/* Define to 1 if you have the <sys/mman.h> header file. */
-#undef HAVE_SYS_MMAN_H
-
-/* Define to 1 if you have the <sys/mount.h> header file. */
-#undef HAVE_SYS_MOUNT_H
-
-/* Define to 1 if you have the <sys/ndir.h> header file, and it defines `DIR'.
-   */
-#undef HAVE_SYS_NDIR_H
-
-/* Define to 1 if you have the <sys/param.h> header file. */
-#undef HAVE_SYS_PARAM_H
-
-/* Define to 1 if you have the <sys/resource.h> header file. */
-#undef HAVE_SYS_RESOURCE_H
-
-/* Define to 1 if you have the <sys/select.h> header file. */
-#undef HAVE_SYS_SELECT_H
-
-/* Define to 1 if you have the <sys/sem.h> header file. */
-#undef HAVE_SYS_SEM_H
-
-/* Define to 1 if you have the <sys/socket.h> header file. */
-#undef HAVE_SYS_SOCKET_H
-
-/* Define to 1 if you have the <sys/statvfs.h> header file. */
-#undef HAVE_SYS_STATVFS_H
-
-/* Define to 1 if you have the <sys/stat.h> header file. */
-#undef HAVE_SYS_STAT_H
-
-/* Define to 1 if you have the <sys/timerfd.h> header file. */
-#undef HAVE_SYS_TIMERFD_H
-
-/* Define to 1 if you have the <sys/time.h> header file. */
-#undef HAVE_SYS_TIME_H
-
-/* Define to 1 if you have the <sys/types.h> header file. */
-#undef HAVE_SYS_TYPES_H
-
-/* Define to 1 if you have the <sys/uio.h> header file. */
-#undef HAVE_SYS_UIO_H
-
-/* Define to 1 if you have the <sys/un.h> header file. */
-#undef HAVE_SYS_UN_H
-
-/* Define to 1 if you have the <sys/utsname.h> header file. */
-#undef HAVE_SYS_UTSNAME_H
-
-/* Define to 1 if you have the <sys/wait.h> header file. */
-#undef HAVE_SYS_WAIT_H
-
-/* Define to 1 if you have the <termios.h> header file. */
-#undef HAVE_TERMIOS_H
-
-/* Define to 1 if you have the <time.h> header file. */
-#undef HAVE_TIME_H
-
-/* Define to 1 if you have the `uname' function. */
-#undef HAVE_UNAME
-
-/* Define to 1 if you have the <unistd.h> header file. */
-#undef HAVE_UNISTD_H
-
-/* Define to 1 if you have the <utmpx.h> header file. */
-#undef HAVE_UTMPX_H
-
-/* valgrind.h found */
-#undef HAVE_VALGRIND
-
-/* Define to 1 if you have the `vfork' function. */
-#undef HAVE_VFORK
-
-/* Define to 1 if you have the <vfork.h> header file. */
-#undef HAVE_VFORK_H
-
-/* Define to 1 if you have the `vprintf' function. */
-#undef HAVE_VPRINTF
-
-/* Define to 1 if `fork' works. */
-#undef HAVE_WORKING_FORK
-
-/* Define to 1 if `vfork' works. */
-#undef HAVE_WORKING_VFORK
-
-/* Define to 1 if the system has the type `_Bool'. */
-#undef HAVE__BOOL
-
-/* Internalization package */
-#undef INTL_PACKAGE
-
-/* Locale-dependent data */
-#undef LOCALEDIR
-
-/* Define to 1 to include code that uses lvmlockd dlm option. */
-#undef LOCKDDLM_SUPPORT
-
-/* Define to 1 to include code that uses lvmlockd sanlock option. */
-#undef LOCKDSANLOCK_SUPPORT
-
-/* Define to 1 if `lstat' dereferences a symlink specified with a trailing
-   slash. */
-#undef LSTAT_FOLLOWS_SLASHED_SYMLINK
-
-/* Define to 1 if 'lvm' should fall back to using LVM1 binaries if
-   device-mapper is missing from the kernel */
-#undef LVM1_FALLBACK
-
-/* Define to 1 to include built-in support for LVM1 metadata. */
-#undef LVM1_INTERNAL
-
-/* Path to lvmetad pidfile. */
-#undef LVMETAD_PIDFILE
-
-/* Define to 1 to include code that uses lvmetad. */
-#undef LVMETAD_SUPPORT
-
-/* Path to lvmlockd pidfile. */
-#undef LVMLOCKD_PIDFILE
-
-/* Define to 1 to include code that uses lvmlockd. */
-#undef LVMLOCKD_SUPPORT
-
-/* Path to lvmpolld pidfile. */
-#undef LVMPOLLD_PIDFILE
-
-/* Define to 1 to include code that uses lvmpolld. */
-#undef LVMPOLLD_SUPPORT
-
-/* Path to lvm binary. */
-#undef LVM_PATH
-
-/* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
-   */
-#undef MAJOR_IN_MKDEV
-
-/* Define to 1 if `major', `minor', and `makedev' are declared in
-   <sysmacros.h>. */
-#undef MAJOR_IN_SYSMACROS
-
-/* Define to 1 to include built-in support for mirrors. */
-#undef MIRRORED_INTERNAL
-
-/* The path to 'modprobe', if available. */
-#undef MODPROBE_CMD
-
-/* Define to 1 to enable O_DIRECT support. */
-#undef O_DIRECT_SUPPORT
-
-/* Define to the address where bug reports for this package should be sent. */
-#undef PACKAGE_BUGREPORT
-
-/* Define to the full name of this package. */
-#undef PACKAGE_NAME
-
-/* Define to the full name and version of this package. */
-#undef PACKAGE_STRING
-
-/* Define to the one symbol short name of this package. */
-#undef PACKAGE_TARNAME
-
-/* Define to the home page for this package. */
-#undef PACKAGE_URL
-
-/* Define to the version of this package. */
-#undef PACKAGE_VERSION
-
-/* Define to 1 to include built-in support for GFS pool metadata. */
-#undef POOL_INTERNAL
-
-/* Define to 1 to include built-in support for raid. */
-#undef RAID_INTERNAL
-
-/* Define to 1 to include the LVM readline shell. */
-#undef READLINE_SUPPORT
-
-/* Define to 1 to include built-in support for replicators. */
-#undef REPLICATOR_INTERNAL
-
-/* Define as the return type of signal handlers (`int' or `void'). */
-#undef RETSIGTYPE
-
-/* Define to the type of arg 1 for `select'. */
-#undef SELECT_TYPE_ARG1
-
-/* Define to the type of args 2, 3 and 4 for `select'. */
-#undef SELECT_TYPE_ARG234
-
-/* Define to the type of arg 5 for `select'. */
-#undef SELECT_TYPE_ARG5
-
-/* Define to 1 to include built-in support for snapshots. */
-#undef SNAPSHOT_INTERNAL
-
-/* If using the C implementation of alloca, define if you know the
-   direction of stack growth for your system; otherwise it will be
-   automatically deduced at runtime.
-	STACK_DIRECTION > 0 => grows toward higher addresses
-	STACK_DIRECTION < 0 => grows toward lower addresses
-	STACK_DIRECTION = 0 => direction of growth unknown */
-#undef STACK_DIRECTION
-
-/* Define to 1 if you have the ANSI C header files. */
-#undef STDC_HEADERS
-
-/* Define to 1 if strerror_r returns char *. */
-#undef STRERROR_R_CHAR_P
-
-/* Path to testsuite data */
-#undef TESTSUITE_DATA
-
-/* The path to 'thin_check', if available. */
-#undef THIN_CHECK_CMD
-
-/* Define to 1 if the external 'thin_check' tool requires the
-   --clear-needs-check-flag option */
-#undef THIN_CHECK_NEEDS_CHECK
-
-/* The path to 'thin_dump', if available. */
-#undef THIN_DUMP_CMD
-
-/* Define to 1 to include built-in support for thin provisioning. */
-#undef THIN_INTERNAL
-
-/* The path to 'thin_repair', if available. */
-#undef THIN_REPAIR_CMD
-
-/* The path to 'thin_restore', if available. */
-#undef THIN_RESTORE_CMD
-
-/* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
-#undef TIME_WITH_SYS_TIME
-
-/* Define to 1 if your <sys/time.h> declares `struct tm'. */
-#undef TM_IN_SYS_TIME
-
-/* Define to 1 to enable synchronisation with udev processing. */
-#undef UDEV_SYNC_SUPPORT
-
-/* Enable a valgrind aware build of pool */
-#undef VALGRIND_POOL
-
-/* Define for Solaris 2.5.1 so the uint32_t typedef from <sys/synch.h>,
-   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
-   #define below would cause a syntax error. */
-#undef _UINT32_T
-
-/* Define for Solaris 2.5.1 so the uint64_t typedef from <sys/synch.h>,
-   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
-   #define below would cause a syntax error. */
-#undef _UINT64_T
-
-/* Define for Solaris 2.5.1 so the uint8_t typedef from <sys/synch.h>,
-   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
-   #define below would cause a syntax error. */
-#undef _UINT8_T
-
-/* Define to empty if `const' does not conform to ANSI C. */
-#undef const
-
-/* Define to `int' if <sys/types.h> doesn't define. */
-#undef gid_t
-
-/* Define to `__inline__' or `__inline' if that's what the C compiler
-   calls it, or to nothing if 'inline' is not supported under any name.  */
-#ifndef __cplusplus
-#undef inline
-#endif
-
-/* Define to the type of a signed integer type of width exactly 16 bits if
-   such a type exists and the standard includes do not define it. */
-#undef int16_t
-
-/* Define to the type of a signed integer type of width exactly 32 bits if
-   such a type exists and the standard includes do not define it. */
-#undef int32_t
-
-/* Define to the type of a signed integer type of width exactly 64 bits if
-   such a type exists and the standard includes do not define it. */
-#undef int64_t
-
-/* Define to the type of a signed integer type of width exactly 8 bits if such
-   a type exists and the standard includes do not define it. */
-#undef int8_t
-
-/* Define to rpl_malloc if the replacement function should be used. */
-#undef malloc
-
-/* Define to `int' if <sys/types.h> does not define. */
-#undef mode_t
-
-/* Define to `long int' if <sys/types.h> does not define. */
-#undef off_t
-
-/* Define to `int' if <sys/types.h> does not define. */
-#undef pid_t
-
-/* Define to rpl_realloc if the replacement function should be used. */
-#undef realloc
-
-/* Define to `unsigned int' if <sys/types.h> does not define. */
-#undef size_t
-
-/* Define to `int' if <sys/types.h> does not define. */
-#undef ssize_t
-
-/* Define to `int' if <sys/types.h> doesn't define. */
-#undef uid_t
-
-/* Define to the type of an unsigned integer type of width exactly 16 bits if
-   such a type exists and the standard includes do not define it. */
-#undef uint16_t
-
-/* Define to the type of an unsigned integer type of width exactly 32 bits if
-   such a type exists and the standard includes do not define it. */
-#undef uint32_t
-
-/* Define to the type of an unsigned integer type of width exactly 64 bits if
-   such a type exists and the standard includes do not define it. */
-#undef uint64_t
-
-/* Define to the type of an unsigned integer type of width exactly 8 bits if
-   such a type exists and the standard includes do not define it. */
-#undef uint8_t
-
-/* Define as `fork' if `vfork' does not work. */
-#undef vfork
diff --git a/lib/misc/lvm-version.h.in b/lib/misc/lvm-version.h.in
deleted file mode 100644
index 2574890..0000000
--- a/lib/misc/lvm-version.h.in
+++ /dev/null
@@ -1,30 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#ifndef _LVM_VERSION_H
-/**
- * The LVM version number
- *
- * LVM_MAJOR.LVM_MINOR.LVM_PATCHLEVEL(LVM_LIBAPI)[-LVM_RELEASE]
- */
-
-#define LVM_VERSION @LVM_VERSION@
-#define LVM_MAJOR @LVM_MAJOR@
-#define LVM_MINOR @LVM_MINOR@
-#define LVM_PATCHLEVEL @LVM_PATCHLEVEL@
-#define LVM_LIBAPI @LVM_LIBAPI@
-#define LVM_RELEASE @LVM_RELEASE@
-#define LVM_RELEASE_DATE @LVM_RELEASE_DATE@
-#endif


