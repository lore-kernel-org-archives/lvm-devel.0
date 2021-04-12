From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:35 +0000 (GMT)
Subject: main - configure: better support for use of --without
Message-ID: <20210412075535.E326E3835429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=744afec6c06d83049ed9fa3c700db2ccffeb146e
Commit:        744afec6c06d83049ed9fa3c700db2ccffeb146e
Parent:        aee0cd6530c6340f6f0a8256b887c8561f29dde6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 8 21:29:44 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:15 2021 +0200

configure: better support for use of --without

When --with-... option is used as --without-... it gets
assigned value 'no' - so support it better where we can.

Also remove 'shared' from help as it's not supported.
---
 configure    | 33 +++++++++++++++++----------------
 configure.ac | 38 ++++++++++++++++++++------------------
 2 files changed, 37 insertions(+), 34 deletions(-)

diff --git a/configure b/configure
index 9fe0c8ddf..154862bcc 100755
--- a/configure
+++ b/configure
@@ -1713,22 +1713,21 @@ Optional Packages:
                           create nodes on resume or create [ON=resume]
   --with-default-name-mangling=MANGLING
                           default name mangling: auto/none/hex [auto]
-  --with-snapshots=TYPE   snapshot support: internal/shared/none [internal]
-  --with-mirrors=TYPE     mirror support: internal/shared/none [internal]
+  --with-snapshots=TYPE   snapshot support: internal/none [internal]
+  --with-mirrors=TYPE     mirror support: internal/none [internal]
   --with-default-mirror-segtype=TYPE
                           default mirror segtype: raid1/mirror [raid1]
   --with-default-raid10-segtype=TYPE
                           default mirror segtype: raid10/mirror [raid10]
   --with-default-sparse-segtype=TYPE
                           default sparse segtype: thin/snapshot [thin]
-  --with-thin=TYPE        thin provisioning support: internal/shared/none
-                          [internal]
+  --with-thin=TYPE        thin provisioning support: internal/none [internal]
   --with-thin-check=PATH  thin_check tool: [autodetect]
   --with-thin-dump=PATH   thin_dump tool: [autodetect]
   --with-thin-repair=PATH thin_repair tool: [autodetect]
   --with-thin-restore=PATH
                           thin_restore tool: [autodetect]
-  --with-cache=TYPE       cache support: internal/shared/none [internal]
+  --with-cache=TYPE       cache support: internal/none [internal]
   --with-cache-check=PATH cache_check tool: [autodetect]
   --with-cache-dump=PATH  cache_dump tool: [autodetect]
   --with-cache-repair=PATH
@@ -8385,7 +8384,7 @@ fi
 
 case "$MANGLING" in
  auto) mangling=DM_STRING_MANGLING_AUTO;;
- none|disabled) mangling=DM_STRING_MANGLING_NONE;;
+ no|none|disabled) mangling=DM_STRING_MANGLING_NONE;;
  hex) mangling=DM_STRING_MANGLING_HEX;;
  *) as_fn_error $? "--with-default-name-mangling parameter invalid" "$LINENO" 5;;
 esac
@@ -8412,7 +8411,7 @@ fi
 $as_echo "$SNAPSHOTS" >&6; }
 
 case "$SNAPSHOTS" in
-  none|shared) ;;
+  no|none|shared) ;;
   internal)
 $as_echo "#define SNAPSHOT_INTERNAL 1" >>confdefs.h
  ;;
@@ -8434,7 +8433,7 @@ fi
 $as_echo "$MIRRORS" >&6; }
 
 case "$MIRRORS" in
-  none|shared) ;;
+  no|none|shared) ;;
   internal)
 $as_echo "#define MIRRORED_INTERNAL 1" >>confdefs.h
  ;;
@@ -8479,7 +8478,10 @@ _ACEOF
 
 # Check whether --with-default-sparse-segtype was given.
 if test "${with_default_sparse_segtype+set}" = set; then :
-  withval=$with_default_sparse_segtype; DEFAULT_SPARSE_SEGTYPE=$withval
+  withval=$with_default_sparse_segtype;  case "$withval" in
+				thin|snapshot) DEFAULT_SPARSE_SEGTYPE=$withval ;;
+				*) as_fn_error $? "--with-default-sparse-segtype parameter invalid" "$LINENO" 5 ;;
+			     esac
 else
   DEFAULT_SPARSE_SEGTYPE="thin"
 fi
@@ -8533,7 +8535,7 @@ fi
 $as_echo "$THIN" >&6; }
 
 case "$THIN" in
-  none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
+  no|none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
   shared) ;;
   internal)
 $as_echo "#define THIN_INTERNAL 1" >>confdefs.h
@@ -9014,7 +9016,6 @@ $as_echo "$THIN_CHECK_NEEDS_CHECK" >&6; }
 $as_echo "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
 
 	fi
-
 	;;
 esac
 
@@ -9089,7 +9090,7 @@ fi
 $as_echo "$CACHE" >&6; }
 
 case "$CACHE" in
- none|shared) ;;
+ no|none|shared) ;;
  internal)
 $as_echo "#define CACHE_INTERNAL 1" >>confdefs.h
  ;;
@@ -9626,7 +9627,7 @@ else
 fi
 
 case "$VDO" in
- none) ;;
+ no|none) ;;
  internal)
 
 $as_echo "#define VDO_INTERNAL 1" >>confdefs.h
@@ -9778,7 +9779,7 @@ fi
 $as_echo "$WRITECACHE" >&6; }
 
 case "$WRITECACHE" in
- none) ;;
+ no|none) ;;
  internal)
 
 $as_echo "#define WRITECACHE_INTERNAL 1" >>confdefs.h
@@ -9803,7 +9804,7 @@ fi
 $as_echo "$INTEGRITY" >&6; }
 
 case "$INTEGRITY" in
- none) ;;
+ no|none) ;;
  internal)
 
 $as_echo "#define INTEGRITY_INTERNAL 1" >>confdefs.h
@@ -10401,7 +10402,7 @@ $as_echo_n "checking whether to use symbol versioning... " >&6; }
 if test "${with_symvers+set}" = set; then :
   withval=$with_symvers;  case "$withval" in
 				gnu|no) symvers=$withval ;;
-				*) as_fn_error $? "Unknown argument to with-symvers" "$LINENO" 5 ;;
+				*) as_fn_error $? "--with-symvers parameter invalid" "$LINENO" 5 ;;
 			     esac
 else
   symvers=gnu
diff --git a/configure.ac b/configure.ac
index 21a1d311e..60b9c1043 100644
--- a/configure.ac
+++ b/configure.ac
@@ -289,7 +289,7 @@ AC_ARG_WITH(default-name-mangling,
 	    MANGLING=$withval, MANGLING=auto)
 case "$MANGLING" in
  auto) mangling=DM_STRING_MANGLING_AUTO;;
- none|disabled) mangling=DM_STRING_MANGLING_NONE;;
+ no|none|disabled) mangling=DM_STRING_MANGLING_NONE;;
  hex) mangling=DM_STRING_MANGLING_HEX;;
  *) AC_MSG_ERROR([--with-default-name-mangling parameter invalid]);;
 esac
@@ -301,12 +301,12 @@ dnl -- snapshots inclusion type
 AC_MSG_CHECKING(whether to include snapshots)
 AC_ARG_WITH(snapshots,
 	    AC_HELP_STRING([--with-snapshots=TYPE],
-			   [snapshot support: internal/shared/none [internal]]),
+			   [snapshot support: internal/none [internal]]),
 	    SNAPSHOTS=$withval, SNAPSHOTS=internal)
 AC_MSG_RESULT($SNAPSHOTS)
 
 case "$SNAPSHOTS" in
-  none|shared) ;;
+  no|none|shared) ;;
   internal) AC_DEFINE([SNAPSHOT_INTERNAL], 1,
 		      [Define to 1 to include built-in support for snapshots.]) ;;
   *) AC_MSG_ERROR([--with-snapshots parameter invalid]) ;;
@@ -317,12 +317,12 @@ dnl -- mirrors inclusion type
 AC_MSG_CHECKING(whether to include mirrors)
 AC_ARG_WITH(mirrors,
 	    AC_HELP_STRING([--with-mirrors=TYPE],
-			   [mirror support: internal/shared/none [internal]]),
+			   [mirror support: internal/none [internal]]),
 	    MIRRORS=$withval, MIRRORS=internal)
 AC_MSG_RESULT($MIRRORS)
 
 case "$MIRRORS" in
-  none|shared) ;;
+  no|none|shared) ;;
   internal) AC_DEFINE([MIRRORED_INTERNAL], 1,
 		      [Define to 1 to include built-in support for mirrors.]) ;;
   *) AC_MSG_ERROR([--with-mirrors parameter invalid]) ;;
@@ -352,14 +352,17 @@ AC_DEFINE_UNQUOTED([DEFAULT_RAID10_SEGTYPE], ["$DEFAULT_RAID10_SEGTYPE"],
 AC_ARG_WITH(default-sparse-segtype,
 	    AC_HELP_STRING([--with-default-sparse-segtype=TYPE],
 			   [default sparse segtype: thin/snapshot [thin]]),
-			   DEFAULT_SPARSE_SEGTYPE=$withval, DEFAULT_SPARSE_SEGTYPE="thin")
+			   [ case "$withval" in
+				thin|snapshot) DEFAULT_SPARSE_SEGTYPE=$withval ;;
+				*) AC_MSG_ERROR(--with-default-sparse-segtype parameter invalid) ;;
+			     esac], DEFAULT_SPARSE_SEGTYPE="thin")
 
 ################################################################################
 dnl -- thin provisioning
 AC_MSG_CHECKING(whether to include thin provisioning)
 AC_ARG_WITH(thin,
 	    AC_HELP_STRING([--with-thin=TYPE],
-			   [thin provisioning support: internal/shared/none [internal]]),
+			   [thin provisioning support: internal/none [internal]]),
 	    THIN=$withval, THIN=internal)
 AC_ARG_WITH(thin-check,
 	    AC_HELP_STRING([--with-thin-check=PATH],
@@ -381,7 +384,7 @@ AC_ARG_WITH(thin-restore,
 AC_MSG_RESULT($THIN)
 
 case "$THIN" in
-  none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
+  no|none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
   shared) ;;
   internal) AC_DEFINE([THIN_INTERNAL], 1,
 		      [Define to 1 to include built-in support for thin provisioning.]) ;;
@@ -458,7 +461,6 @@ case "$THIN" in
 	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
 		AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
 	fi
-
 	;;
 esac
 
@@ -479,7 +481,7 @@ dnl -- cache inclusion type
 AC_MSG_CHECKING(whether to include cache)
 AC_ARG_WITH(cache,
 	    AC_HELP_STRING([--with-cache=TYPE],
-			   [cache support: internal/shared/none [internal]]),
+			   [cache support: internal/none [internal]]),
 			   CACHE=$withval, CACHE="internal")
 AC_ARG_WITH(cache-check,
 	    AC_HELP_STRING([--with-cache-check=PATH],
@@ -500,7 +502,7 @@ AC_ARG_WITH(cache-restore,
 AC_MSG_RESULT($CACHE)
 
 case "$CACHE" in
- none|shared) ;;
+ no|none|shared) ;;
  internal) AC_DEFINE([CACHE_INTERNAL], 1, [Define to 1 to include built-in support for cache.]) ;;
  *) AC_MSG_ERROR([--with-cache parameter invalid]) ;;
 esac
@@ -613,8 +615,8 @@ AC_ARG_WITH(vdo-format,
 			   [vdoformat tool: [autodetect]]),
 			   VDO_FORMAT_CMD=$withval, VDO_FORMAT_CMD="autodetect")
 case "$VDO" in
- none) ;;
- internal) 
+ no|none) ;;
+ internal)
 	AC_DEFINE([VDO_INTERNAL], 1, [Define to 1 to include built-in support for vdo.])
 	if test "$VDO_FORMAT_CMD" = "autodetect"; then
 		AC_PATH_TOOL(VDO_FORMAT_CMD, vdoformat, [], [$PATH])
@@ -643,7 +645,7 @@ AC_DEFINE_UNQUOTED([VDO_FORMAT_CMD], ["$VDO_FORMAT_CMD"],
 #AC_ARG_WITH(vdo-lib,
 #            AC_HELP_STRING([--with-vdo-lib=PATH],
 #                           [vdo support: Path to utils lib: [/usr/lib]]),
-#                           VDO_LIB=$withval, VDO_LIB="/usr/lib") 
+#                           VDO_LIB=$withval, VDO_LIB="/usr/lib")
 #AC_MSG_RESULT($VDO_LIB)
 
 ################################################################################
@@ -657,8 +659,8 @@ AC_ARG_WITH(writecache,
 AC_MSG_RESULT($WRITECACHE)
 
 case "$WRITECACHE" in
- none) ;;
- internal) 
+ no|none) ;;
+ internal)
 	AC_DEFINE([WRITECACHE_INTERNAL], 1, [Define to 1 to include built-in support for writecache.])
 	;;
  *) AC_MSG_ERROR([--with-writecache parameter invalid]) ;;
@@ -675,7 +677,7 @@ AC_ARG_WITH(integrity,
 AC_MSG_RESULT($INTEGRITY)
 
 case "$INTEGRITY" in
- none) ;;
+ no|none) ;;
  internal)
 	AC_DEFINE([INTEGRITY_INTERNAL], 1, [Define to 1 to include built-in support for integrity.])
 	;;
@@ -830,7 +832,7 @@ AC_ARG_WITH(symvers,
 			   [use symbol versioning of the shared library [default=gnu]]),
 			   [ case "$withval" in
 				gnu|no) symvers=$withval ;;
-				*) AC_MSG_ERROR(Unknown argument to with-symvers) ;;
+				*) AC_MSG_ERROR(--with-symvers parameter invalid) ;;
 			     esac], symvers=gnu)
 AC_MSG_RESULT($symvers)
 


