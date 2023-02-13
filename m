From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:44 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20230213133144.10BBB3858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07cd341bd87a7559f33862a5a7480687b30e5f9c
Commit:        07cd341bd87a7559f33862a5a7480687b30e5f9c
Parent:        1e55e5c60a1b6067d7a46f881d78b2ab7d1431eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 22:54:33 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 14:30:47 2023 +0100

configure: update

---
 configure | 86 +++++++++++++++++++++++++++++----------------------------------
 1 file changed, 39 insertions(+), 47 deletions(-)

diff --git a/configure b/configure
index 7b160639f..3e09aa265 100755
--- a/configure
+++ b/configure
@@ -674,7 +674,6 @@ SILENT_RULES
 USE_TRACKING
 UDEV_HAS_BUILTIN_BLKID
 UDEV_RULE_EXEC_DETECTION
-UDEV_SYSTEMD_BACKGROUND_JOBS
 UDEV_SYNC
 UDEV_RULES
 UDEV_PC
@@ -773,6 +772,7 @@ CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
 BUILD_DMFILEMAPD
+BUILD_LOCKDIDM
 BUILD_LOCKDDLM_CONTROL
 BUILD_LOCKDDLM
 BUILD_LOCKDSANLOCK
@@ -9623,8 +9623,8 @@ fi
 		if test -z "$THIN_CHECK_CMD"
 then :
 
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_check not found in path $PATH" >&5
-printf "%s\n" "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_check not found in path $PATH_SBIN" >&5
+printf "%s\n" "$as_me: WARNING: thin_check not found in path $PATH_SBIN" >&2;}
 			THIN_CHECK_CMD="/usr/sbin/thin_check"
 			THIN_CONFIGURE_WARN="y"
 
@@ -9772,8 +9772,8 @@ fi
 		if test -z "$THIN_DUMP_CMD"
 then :
 
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_dump not found in path $PATH\"" >&5
-printf "%s\n" "$as_me: WARNING: \"thin_dump not found in path $PATH\"" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_dump not found in path $PATH_SBIN\"" >&5
+printf "%s\n" "$as_me: WARNING: \"thin_dump not found in path $PATH_SBIN\"" >&2;}
 			THIN_DUMP_CMD="/usr/sbin/thin_dump"
 			THIN_CONFIGURE_WARN="y"
 
@@ -9895,8 +9895,8 @@ fi
 		if test -z "$THIN_REPAIR_CMD"
 then :
 
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_repair not found in path $PATH\"" >&5
-printf "%s\n" "$as_me: WARNING: \"thin_repair not found in path $PATH\"" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_repair not found in path $PATH_SBIN\"" >&5
+printf "%s\n" "$as_me: WARNING: \"thin_repair not found in path $PATH_SBIN\"" >&2;}
 			THIN_REPAIR_CMD="/usr/sbin/thin_repair"
 			THIN_CONFIGURE_WARN="y"
 
@@ -10018,8 +10018,8 @@ fi
 		if test -z "$THIN_RESTORE_CMD"
 then :
 
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_restore not found in path $PATH\"" >&5
-printf "%s\n" "$as_me: WARNING: \"thin_restore not found in path $PATH\"" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_restore not found in path $PATH_SBIN\"" >&5
+printf "%s\n" "$as_me: WARNING: \"thin_restore not found in path $PATH_SBIN\"" >&2;}
 			THIN_RESTORE_CMD="/usr/sbin/thin_restore"
 			THIN_CONFIGURE_WARN="y"
 
@@ -10252,8 +10252,8 @@ fi
 		if test -z "$CACHE_CHECK_CMD"
 then :
 
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_check not found in path $PATH" >&5
-printf "%s\n" "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_check not found in path $PATH_SBIN" >&5
+printf "%s\n" "$as_me: WARNING: cache_check not found in path $PATH_SBIN" >&2;}
 			CACHE_CHECK_CMD="/usr/sbin/cache_check"
 			CACHE_CONFIGURE_WARN="y"
 
@@ -10419,8 +10419,8 @@ fi
 		if test -z "$CACHE_DUMP_CMD"
 then :
 
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_dump not found in path $PATH\"" >&5
-printf "%s\n" "$as_me: WARNING: \"cache_dump not found in path $PATH\"" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_dump not found in path $PATH_SBIN\"" >&5
+printf "%s\n" "$as_me: WARNING: \"cache_dump not found in path $PATH_SBIN\"" >&2;}
 			CACHE_DUMP_CMD="/usr/sbin/cache_dump"
 			CACHE_CONFIGURE_WARN="y"
 
@@ -10542,8 +10542,8 @@ fi
 		if test -z "$CACHE_REPAIR_CMD"
 then :
 
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_repair not found in path $PATH\"" >&5
-printf "%s\n" "$as_me: WARNING: \"cache_repair not found in path $PATH\"" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_repair not found in path $PATH_SBIN\"" >&5
+printf "%s\n" "$as_me: WARNING: \"cache_repair not found in path $PATH_SBIN\"" >&2;}
 			CACHE_REPAIR_CMD="/usr/sbin/cache_repair"
 			CACHE_CONFIGURE_WARN="y"
 
@@ -10665,8 +10665,8 @@ fi
 		if test -z "$CACHE_RESTORE_CMD"
 then :
 
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_restore not found in path $PATH\"" >&5
-printf "%s\n" "$as_me: WARNING: \"cache_restore not found in path $PATH\"" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_restore not found in path $PATH_SBIN\"" >&5
+printf "%s\n" "$as_me: WARNING: \"cache_restore not found in path $PATH_SBIN\"" >&2;}
 			CACHE_RESTORE_CMD="/usr/sbin/cache_restore"
 			CACHE_CONFIGURE_WARN="y"
 
@@ -12051,15 +12051,13 @@ printf %s "checking whether to build lvmlockdsanlock... " >&6; }
 # Check whether --enable-lvmlockd-sanlock was given.
 if test ${enable_lvmlockd_sanlock+y}
 then :
-  enableval=$enable_lvmlockd_sanlock; LOCKDSANLOCK=$enableval
+  enableval=$enable_lvmlockd_sanlock; BUILD_LOCKDSANLOCK=$enableval
 else $as_nop
-  LOCKDSANLOCK="no"
+  BUILD_LOCKDSANLOCK="no"
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDSANLOCK" >&5
-printf "%s\n" "$LOCKDSANLOCK" >&6; }
-
-BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LOCKDSANLOCK" >&5
+printf "%s\n" "$BUILD_LOCKDSANLOCK" >&6; }
 
 if test "$BUILD_LOCKDSANLOCK" = "yes"
 then :
@@ -12133,7 +12131,7 @@ else
 	LOCKD_SANLOCK_LIBS=$pkg_cv_LOCKD_SANLOCK_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	HAVE_LOCKD_SANLOCK=yes
+	HAVE_LOCKD_SANLOCK="yes"
 fi
 
 printf "%s\n" "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
@@ -12148,15 +12146,13 @@ printf %s "checking whether to build lvmlockddlm... " >&6; }
 # Check whether --enable-lvmlockd-dlm was given.
 if test ${enable_lvmlockd_dlm+y}
 then :
-  enableval=$enable_lvmlockd_dlm; LOCKDDLM=$enableval
+  enableval=$enable_lvmlockd_dlm; BUILD_LOCKDDLM=$enableval
 else $as_nop
-  LOCKDDLM="no"
+  BUILD_LOCKDDLM="no"
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM" >&5
-printf "%s\n" "$LOCKDDLM" >&6; }
-
-BUILD_LOCKDDLM=$LOCKDDLM
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LOCKDDLM" >&5
+printf "%s\n" "$BUILD_LOCKDDLM" >&6; }
 
 if test "$BUILD_LOCKDDLM" = "yes"
 then :
@@ -12230,7 +12226,7 @@ else
 	LOCKD_DLM_LIBS=$pkg_cv_LOCKD_DLM_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	HAVE_LOCKD_DLM=yes
+	HAVE_LOCKD_DLM="yes"
 fi
 
 printf "%s\n" "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
@@ -12245,15 +12241,13 @@ printf %s "checking whether to build lvmlockddlmcontrol... " >&6; }
 # Check whether --enable-lvmlockd-dlmcontrol was given.
 if test ${enable_lvmlockd_dlmcontrol+y}
 then :
-  enableval=$enable_lvmlockd_dlmcontrol; LOCKDDLM_CONTROL=$enableval
+  enableval=$enable_lvmlockd_dlmcontrol; BUILD_LOCKDDLM_CONTROL=$enableval
 else $as_nop
-  LOCKDDLM_CONTROL="no"
+  BUILD_LOCKDDLM_CONTROL="no"
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM_CONTROL" >&5
-printf "%s\n" "$LOCKDDLM_CONTROL" >&6; }
-
-BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LOCKDDLM_CONTROL" >&5
+printf "%s\n" "$BUILD_LOCKDDLM_CONTROL" >&6; }
 
 if test "$BUILD_LOCKDDLM_CONTROL" = "yes"
 then :
@@ -12342,15 +12336,13 @@ printf %s "checking whether to build lvmlockdidm... " >&6; }
 # Check whether --enable-lvmlockd-idm was given.
 if test ${enable_lvmlockd_idm+y}
 then :
-  enableval=$enable_lvmlockd_idm; LOCKDIDM=$enableval
+  enableval=$enable_lvmlockd_idm; BUILD_LOCKDIDM=$enableval
 else $as_nop
-  LOCKDIDM="no"
+  BUILD_LOCKDIDM="no"
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDIDM" >&5
-printf "%s\n" "$LOCKDIDM" >&6; }
-
-BUILD_LOCKDIDM=$LOCKDIDM
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LOCKDIDM" >&5
+printf "%s\n" "$BUILD_LOCKDIDM" >&6; }
 
 if test "$BUILD_LOCKDIDM" = "yes"
 then :
@@ -12672,9 +12664,9 @@ if test -n "$PKG_CONFIG" && \
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT=maybe
+  SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT="maybe"
 else
-  APP_MACHINEID_SUPPORT=no
+  APP_MACHINEID_SUPPORT="no"
 fi
 ac_fn_c_check_header_compile "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
 if test "x$ac_cv_header_systemd_sd_id128_h" = xyes
@@ -12684,7 +12676,7 @@ then :
   APP_MACHINEID_SUPPORT="yes"
 fi
 else $as_nop
-  APP_MACHINEID_SUPPORT=no
+  APP_MACHINEID_SUPPORT="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to support systemd appmachineid" >&5
@@ -14885,7 +14877,7 @@ then :
 
 printf "%s\n" "#define READLINE_SUPPORT 1" >>confdefs.h
 
-				READLINE=yes
+				READLINE="yes"
 		LIBS=$lvm_saved_libs
 		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for rl_line_buffer in -lreadline" >&5
 printf %s "checking for rl_line_buffer in -lreadline... " >&6; }

