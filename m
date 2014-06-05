From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jun 2014 15:54:26 +0000 (UTC)
Subject: master - configure: reconfigure
Message-ID: <20140605155426.CE4CC61100@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b59f5a99c351448c43f9d7e71ee3088bafcc6c5
Commit:        1b59f5a99c351448c43f9d7e71ee3088bafcc6c5
Parent:        7cead4afea91a8905ac1b250f542ad808239ba0f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 17:24:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:47:23 2014 +0200

configure: reconfigure

---
 configure | 1066 +++++++++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 749 insertions(+), 317 deletions(-)

diff --git a/configure b/configure
index 7738c8f..bedccca 100755
--- a/configure
+++ b/configure
@@ -664,6 +664,7 @@ PKGCONFIG
 OCFDIR
 OCF
 MIRRORS
+MANGLING
 LVM_RELEASE_DATE
 LVM_RELEASE
 LVM_PATH
@@ -4461,8 +4462,9 @@ else
   RANLIB="$ac_cv_prog_RANLIB"
 fi
 
-# Extract the first word of "cflow", so it can be a program name with args.
-set dummy cflow; ac_word=$2
+if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}cflow", so it can be a program name with args.
+set dummy ${ac_tool_prefix}cflow; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_CFLOW_CMD+:} false; then :
@@ -4501,8 +4503,66 @@ $as_echo "no" >&6; }
 fi
 
 
-# Extract the first word of "cscope", so it can be a program name with args.
-set dummy cscope; ac_word=$2
+fi
+if test -z "$ac_cv_path_CFLOW_CMD"; then
+  ac_pt_CFLOW_CMD=$CFLOW_CMD
+  # Extract the first word of "cflow", so it can be a program name with args.
+set dummy cflow; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_CFLOW_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_CFLOW_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_CFLOW_CMD="$ac_pt_CFLOW_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CFLOW_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_CFLOW_CMD=$ac_cv_path_ac_pt_CFLOW_CMD
+if test -n "$ac_pt_CFLOW_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CFLOW_CMD" >&5
+$as_echo "$ac_pt_CFLOW_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_CFLOW_CMD" = x; then
+    CFLOW_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CFLOW_CMD=$ac_pt_CFLOW_CMD
+  fi
+else
+  CFLOW_CMD="$ac_cv_path_CFLOW_CMD"
+fi
+
+if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}cscope", so it can be a program name with args.
+set dummy ${ac_tool_prefix}cscope; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_CSCOPE_CMD+:} false; then :
@@ -4541,6 +4601,63 @@ $as_echo "no" >&6; }
 fi
 
 
+fi
+if test -z "$ac_cv_path_CSCOPE_CMD"; then
+  ac_pt_CSCOPE_CMD=$CSCOPE_CMD
+  # Extract the first word of "cscope", so it can be a program name with args.
+set dummy cscope; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_CSCOPE_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_CSCOPE_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_CSCOPE_CMD="$ac_pt_CSCOPE_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CSCOPE_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_CSCOPE_CMD=$ac_cv_path_ac_pt_CSCOPE_CMD
+if test -n "$ac_pt_CSCOPE_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CSCOPE_CMD" >&5
+$as_echo "$ac_pt_CSCOPE_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_CSCOPE_CMD" = x; then
+    CSCOPE_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CSCOPE_CMD=$ac_pt_CSCOPE_CMD
+  fi
+else
+  CSCOPE_CMD="$ac_cv_path_CSCOPE_CMD"
+fi
+
 
 ################################################################################
 ac_header_dirent=no
@@ -6863,10 +6980,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $OWNER" >&5
 $as_echo "$OWNER" >&6; }
-
-if test x$OWNER != x; then
-	INSTALL="$INSTALL -o $OWNER"
-fi
+test -n "$OWNER" && INSTALL="$INSTALL -o $OWNER"
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking group owner" >&5
@@ -6879,10 +6993,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $GROUP" >&5
 $as_echo "$GROUP" >&6; }
-
-if test x$GROUP != x; then
-	INSTALL="$INSTALL -g $GROUP"
-fi
+test -n "$GROUP" && INSTALL="$INSTALL -g $GROUP"
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking device node uid" >&5
@@ -6964,7 +7075,7 @@ fi
 
 case "$MANGLING" in
  auto) mangling=DM_STRING_MANGLING_AUTO;;
- disabled) mangling=DM_STRING_MANGLING_NONE;;
+ none|disabled) mangling=DM_STRING_MANGLING_NONE;;
  hex) mangling=DM_STRING_MANGLING_HEX;;
  *) as_fn_error $? "--with-default-name-mangling parameter invalid" "$LINENO" 5;;
 esac
@@ -6989,7 +7100,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVM1_FALLBACK" >&5
 $as_echo "$LVM1_FALLBACK" >&6; }
 
-if test x$LVM1_FALLBACK = xyes; then
+if test "$LVM1_FALLBACK" = yes; then
 
 $as_echo "#define LVM1_FALLBACK 1" >>confdefs.h
 
@@ -7006,19 +7117,17 @@ else
   LVM1=internal
 fi
 
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVM1" >&5
 $as_echo "$LVM1" >&6; }
 
-if [ "x$LVM1" != xnone -a "x$LVM1" != xinternal -a "x$LVM1" != xshared ];
- then  as_fn_error $? "--with-lvm1 parameter invalid
-" "$LINENO" 5
-fi;
-
-if test x$LVM1 = xinternal; then
-
+case "$LVM1" in
+  none|share) ;;
+  internal)
 $as_echo "#define LVM1_INTERNAL 1" >>confdefs.h
-
-fi
+ ;;
+  *) as_fn_error $? "--with-lvm1 parameter invalid" "$LINENO" 5 ;;
+esac
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include support for GFS pool metadata" >&5
@@ -7034,16 +7143,13 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $POOL" >&5
 $as_echo "$POOL" >&6; }
 
-if [ "x$POOL" != xnone -a "x$POOL" != xinternal -a "x$POOL" != xshared ];
- then  as_fn_error $? "--with-pool parameter invalid
-" "$LINENO" 5
-fi;
-
-if test x$POOL = xinternal; then
-
+case "$POOL" in
+  none|shared) ;;
+  internal)
 $as_echo "#define POOL_INTERNAL 1" >>confdefs.h
-
-fi
+ ;;
+  *) as_fn_error $? "--with-pool parameter invalid" "$LINENO" 5
+esac
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include support for cluster locking" >&5
@@ -7057,16 +7163,13 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CLUSTER" >&5
 $as_echo "$CLUSTER" >&6; }
 
-if [ "x$CLUSTER" != xnone -a "x$CLUSTER" != xinternal -a "x$CLUSTER" != xshared ];
- then  as_fn_error $? "--with-cluster parameter invalid
-" "$LINENO" 5
-fi;
-
-if test x$CLUSTER = xinternal; then
-
+case "$CLUSTER" in
+  none|shared) ;;
+  internal)
 $as_echo "#define CLUSTER_LOCKING_INTERNAL 1" >>confdefs.h
-
-fi
+ ;;
+  *) as_fn_error $? "--with-cluster parameter invalid" "$LINENO" 5 ;;
+esac
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include snapshots" >&5
@@ -7082,16 +7185,13 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $SNAPSHOTS" >&5
 $as_echo "$SNAPSHOTS" >&6; }
 
-if [ "x$SNAPSHOTS" != xnone -a "x$SNAPSHOTS" != xinternal -a "x$SNAPSHOTS" != xshared ];
- then  as_fn_error $? "--with-snapshots parameter invalid
-" "$LINENO" 5
-fi;
-
-if test x$SNAPSHOTS = xinternal; then
-
+case "$SNAPSHOTS" in
+  none|shared) ;;
+  internal)
 $as_echo "#define SNAPSHOT_INTERNAL 1" >>confdefs.h
-
-fi
+ ;;
+  *) as_fn_error $? "--with-snapshots parameter invalid" "$LINENO" 5 ;;
+esac
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include mirrors" >&5
@@ -7107,16 +7207,13 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $MIRRORS" >&5
 $as_echo "$MIRRORS" >&6; }
 
-if [ "x$MIRRORS" != xnone -a "x$MIRRORS" != xinternal -a "x$MIRRORS" != xshared ];
- then  as_fn_error $? "--with-mirrors parameter invalid
-" "$LINENO" 5
-fi;
-
-if test x$MIRRORS = xinternal; then
-
+case "$MIRRORS" in
+  none|shared) ;;
+  internal)
 $as_echo "#define MIRRORED_INTERNAL 1" >>confdefs.h
-
-fi
+ ;;
+  *) as_fn_error $? "--with-mirrors parameter invalid" "$LINENO" 5 ;;
+esac
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include raid" >&5
@@ -7132,16 +7229,13 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $RAID" >&5
 $as_echo "$RAID" >&6; }
 
-if [ "x$RAID" != xnone -a "x$RAID" != xinternal -a "x$RAID" != xshared ];
- then  as_fn_error $? "--with-raid parameter invalid
-" "$LINENO" 5
-fi;
-
-if test x$RAID = xinternal; then
-
+case "$RAID" in
+  none|shared) ;;
+  internal)
 $as_echo "#define RAID_INTERNAL 1" >>confdefs.h
-
-fi
+ ;;
+  *) as_fn_error $? "--with-raid parameter invalid" "$LINENO" 5 ;;
+esac
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include replicators" >&5
@@ -7728,16 +7822,13 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
 $as_echo "$CACHE" >&6; }
 
-if [ "x$CACHE" != xnone -a "x$CACHE" != xinternal -a "x$CACHE" != xshared ];
- then  as_fn_error $? "--with-cache parameter invalid
-" "$LINENO" 5
-fi;
-
-if test x$CACHE = xinternal; then
-
+case "$CACHE" in
+ none|shared) ;;
+ internal)
 $as_echo "#define CACHE_INTERNAL 1" >>confdefs.h
-
-fi
+ ;;
+ *) as_fn_error $? "--with-cache parameter invalid" "$LINENO" 5 ;;
+esac
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
@@ -7786,6 +7877,7 @@ fi
 
 ################################################################################
 pkg_config_init() {
+	if test "$PKGCONFIG_INIT" != 1; then
 
 
 
@@ -7979,7 +8071,8 @@ else
 $as_echo "yes" >&6; }
 
 fi
-	PKGCONFIG_INIT=1
+		PKGCONFIG_INIT=1
+	fi
 }
 
 ################################################################################
@@ -8039,19 +8132,13 @@ else
   CLVMD=none
 fi
 
-if test x$CLVMD = xyes; then
-	CLVMD=all
-fi
+test "$CLVMD" = yes && CLVMD=all
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CLVMD" >&5
 $as_echo "$CLVMD" >&6; }
 
-if  test x$CLVMD != xnone && test x$CLUSTER = xnone; then
-	CLUSTER=internal
-fi
+test "$CLVMD" != none -a "$CLUSTER" = none && CLUSTER=internal
 
-if test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
-	pkg_config_init
-fi
+test "$CLVMD" != none && pkg_config_init
 
 CLVMD_CMANAGERS=""
 CLVMD_NEEDS_QDISKD=no
@@ -8072,9 +8159,7 @@ if [ `expr x"$CLVMD" : '.*openais.*'` != 0 ]; then
 	BUILDOPENAIS=yes
 	CLVMD_CMANAGERS="$CLVMD_CMANAGERS openais"
 fi
-if test x$CLVMD_NEEDS_QDISKD != xno; then
-	CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
-fi
+test "$CLVMD_NEEDS_QDISKD" != no && CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
 
 soft_bailout() {
 	NOTFOUND=1
@@ -8084,7 +8169,7 @@ hard_bailout() {
 	as_fn_error $? "bailing out" "$LINENO" 5
 }
 
-if test x$CLVMD = xall; then
+if test "$CLVMD" = all; then
 	bailout=soft_bailout
 	BUILDCMAN=yes
 	BUILDCOROSYNC=yes
@@ -8151,7 +8236,7 @@ fi
 	LIBS=$ac_check_lib_save_LIBS
 }
 
-if test x$BUILDCMAN = xyes; then
+if test "$BUILDCMAN" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for CMAN" >&5
@@ -8269,8 +8354,7 @@ fi
 	CHECKDLM=yes
 fi
 
-if test x$BUILDCOROSYNC = xyes || \
-   test x$BUILDOPENAIS = xyes; then
+if test "$BUILDCOROSYNC" = yes -o "$BUILDOPENAIS" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for COROSYNC" >&5
@@ -8346,7 +8430,7 @@ fi
 	CHECKCMAP=yes
 fi
 
-if test x$BUILDCOROSYNC = xyes; then
+if test "$BUILDCOROSYNC" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for QUORUM" >&5
@@ -8422,7 +8506,7 @@ fi
 	CHECKDLM=yes
 fi
 
-if test x$BUILDOPENAIS = xyes; then
+if test "$BUILDOPENAIS" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for SALCK" >&5
@@ -8499,7 +8583,7 @@ fi
 
 
 
-if test x$CHECKCONFDB = xyes; then
+if test "$CHECKCONFDB" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for CONFDB" >&5
@@ -8587,8 +8671,7 @@ fi
 done
 
 
-	if test x$HAVE_CONFDB != xyes && \
-	   test x$HAVE_CONFDB_H = xyes; then
+	if test "$HAVE_CONFDB" != yes -a "$HAVE_CONFDB_H" = yes; then
 		check_lib_no_libs confdb confdb_initialize
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no pkg for confdb, using -lconfdb" >&5
 $as_echo "no pkg for confdb, using -lconfdb" >&6; }
@@ -8598,7 +8681,7 @@ $as_echo "no pkg for confdb, using -lconfdb" >&6; }
 fi
 
 
-if test x$CHECKCMAP = xyes; then
+if test "$CHECKCMAP" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for CMAP" >&5
@@ -8686,8 +8769,7 @@ fi
 done
 
 
-	if test x$HAVE_CMAP != xyes && \
-	   test x$HAVE_CMAP_H = xyes; then
+	if test "$HAVE_CMAP" != yes -a "$HAVE_CMAP_H" = yes; then
 		check_lib_no_libs cmap cmap_initialize
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no pkg for cmap, using -lcmap" >&5
 $as_echo "no pkg for cmap, using -lcmap" >&6; }
@@ -8696,15 +8778,12 @@ $as_echo "no pkg for cmap, using -lcmap" >&6; }
 	fi
 fi
 
-if test x$BUILDCOROSYNC = xyes; then
-	if test x$HAVE_CMAP != xyes && \
-	   test x$HAVE_CONFDB != xyes && \
-	   test x$CLVMD != xall; then
-		as_fn_error $? "bailing out... cmap (corosync >= 2.0) or confdb (corosync < 2.0) library is required" "$LINENO" 5
-	fi
+if test "$BUILDCOROSYNC" = yes -a \
+	"$HAVE_CMAP" != yes -a "$HAVE_CONFDB" != yes -a "$CLVMD" != all; then
+	as_fn_error $? "bailing out... cmap (corosync >= 2.0) or confdb (corosync < 2.0) library is required" "$LINENO" 5
 fi
 
-if test x$CHECKCPG = xyes; then
+if test "$CHECKCPG" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for CPG" >&5
@@ -8778,7 +8857,7 @@ $as_echo "yes" >&6; }
 fi
 fi
 
-if test x$CHECKDLM = xyes; then
+if test "$CHECKDLM" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for DLM" >&5
@@ -8894,54 +8973,48 @@ $as_echo "yes" >&6; }
 fi
 fi
 
-if test x$CLVMD = xall; then
+if test "$CLVMD" = all; then
 	CLVMD=none
 	CLVMD_CMANAGERS=""
 	CLVMD_NEEDS_QDISKD=no
-	if test x$HAVE_CMAN = xyes && \
-	   test x$HAVE_DLM = xyes; then
+	if test "$HAVE_CMAN" = yes -a \
+		"$HAVE_DLM" = yes; then
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: Enabling clvmd cman cluster manager" >&5
 $as_echo "Enabling clvmd cman cluster manager" >&6; }
 		CLVMD="$CLVMD,cman"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS cman"
 		CLVMD_NEEDS_QDISKD=yes
 	fi
-	if test x$HAVE_COROSYNC = xyes && \
-	   test x$HAVE_QUORUM = xyes && \
-	   test x$HAVE_CPG = xyes && \
-	   test x$HAVE_DLM = xyes; then
-	   if test x$HAVE_CONFDB = xyes || test x$HAVE_CMAP = xyes; then
+	if test "$HAVE_COROSYNC" = yes -a \
+		"$HAVE_QUORUM" = yes -a \
+		"$HAVE_CPG" = yes -a \
+		"$HAVE_DLM" = yes; then
+	   if test "$HAVE_CONFDB" = yes -o "$HAVE_CMAP" = yes; then
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: Enabling clvmd corosync cluster manager" >&5
 $as_echo "Enabling clvmd corosync cluster manager" >&6; }
 		CLVMD="$CLVMD,corosync"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
 	   fi
 	fi
-	if test x$HAVE_COROSYNC = xyes && \
-	   test x$HAVE_CPG = xyes && \
-	   test x$HAVE_SALCK = xyes; then
+	if test "$HAVE_COROSYNC" = yes -a \
+		"$HAVE_CPG" = yes -a \
+		"$HAVE_SALCK" = yes; then
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: Enabling clvmd openais cluster manager" >&5
 $as_echo "Enabling clvmd openais cluster manager" >&6; }
 		CLVMD="$CLVMD,openais"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS openais"
 	fi
-	if test x$CLVMD_NEEDS_QDISKD != xno; then
-		CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
-	fi
-	if test x$CLVMD = xnone; then
-		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: Disabling clvmd build. No cluster manager detected." >&5
+	test "$CLVMD_NEEDS_QDISKD" != no && CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
+	test "$CLVMD" = none && { $as_echo "$as_me:${as_lineno-$LINENO}: result: Disabling clvmd build. No cluster manager detected." >&5
 $as_echo "Disabling clvmd build. No cluster manager detected." >&6; }
-	fi
 fi
 
 if [ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]; then
-   if test x$HAVE_CMAP = xyes; then
-	CLVMD_CMANAGERS="$CLVMD_CMANAGERS dlm"
-   fi
+   test "$HAVE_CMAP" = yes && CLVMD_CMANAGERS="$CLVMD_CMANAGERS dlm"
 fi
 
 ################################################################################
-if test "x$CLVMD" != xnone; then
+if test "$CLVMD" != none; then
 
 # Check whether --with-clvmd-pidfile was given.
 if test "${with_clvmd_pidfile+set}" = set; then :
@@ -8973,7 +9046,7 @@ $as_echo "$CMIRRORD" >&6; }
 BUILD_CMIRRORD=$CMIRRORD
 
 ################################################################################
-if test "x$BUILD_CMIRRORD" = xyes; then
+if test "$BUILD_CMIRRORD" = yes; then
 
 # Check whether --with-cmirrord-pidfile was given.
 if test "${with_cmirrord_pidfile+set}" = set; then :
@@ -8990,10 +9063,8 @@ _ACEOF
 fi
 
 ################################################################################
-if [ "x$BUILD_CMIRRORD" = xyes ]; then
-		if  test x$PKGCONFIG_INIT != x1; then
-		pkg_config_init
-	fi
+if [ "$BUILD_CMIRRORD" = yes ]; then
+	pkg_config_init
 
 
 $as_echo "#define CMIRROR_HAS_CHECKPOINT 1" >>confdefs.h
@@ -9078,8 +9149,7 @@ $as_echo "yes" >&6; }
 	HAVE_SACKPT=yes
 fi
 
-	if test x$HAVE_CPG != xyes; then
-
+	test "$HAVE_CPG" != yes &&
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for CPG" >&5
 $as_echo_n "checking for CPG... " >&6; }
@@ -9170,7 +9240,6 @@ else
 $as_echo "yes" >&6; }
 
 fi
-	fi
 fi
 
 ################################################################################
@@ -9186,7 +9255,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEBUG" >&5
 $as_echo "$DEBUG" >&6; }
 
-if test x$DEBUG = xyes; then
+if test "$DEBUG" = yes; then
 	COPTIMISE_FLAG=
 else
 	CSCOPE_CMD=
@@ -9294,10 +9363,11 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PROFILING" >&5
 $as_echo "$PROFILING" >&6; }
 
-if test "x$PROFILING" = xyes; then
+if test "$PROFILING" = yes; then
   COPTIMISE_FLAG="$COPTIMISE_FLAG -fprofile-arcs -ftest-coverage"
-  # Extract the first word of "lcov", so it can be a program name with args.
-set dummy lcov; ac_word=$2
+  if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}lcov", so it can be a program name with args.
+set dummy ${ac_tool_prefix}lcov; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_LCOV+:} false; then :
@@ -9336,8 +9406,66 @@ $as_echo "no" >&6; }
 fi
 
 
-  # Extract the first word of "genhtml", so it can be a program name with args.
-set dummy genhtml; ac_word=$2
+fi
+if test -z "$ac_cv_path_LCOV"; then
+  ac_pt_LCOV=$LCOV
+  # Extract the first word of "lcov", so it can be a program name with args.
+set dummy lcov; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_LCOV+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_LCOV in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_LCOV="$ac_pt_LCOV" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_LCOV="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_LCOV=$ac_cv_path_ac_pt_LCOV
+if test -n "$ac_pt_LCOV"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_LCOV" >&5
+$as_echo "$ac_pt_LCOV" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_LCOV" = x; then
+    LCOV=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    LCOV=$ac_pt_LCOV
+  fi
+else
+  LCOV="$ac_cv_path_LCOV"
+fi
+
+  if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}genhtml", so it can be a program name with args.
+set dummy ${ac_tool_prefix}genhtml; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_GENHTML+:} false; then :
@@ -9376,19 +9504,19 @@ $as_echo "no" >&6; }
 fi
 
 
-  if test -z "$LCOV" -o -z "$GENHTML"; then
-    as_fn_error $? "lcov and genhtml are required for profiling" "$LINENO" 5
-  fi
-  # Extract the first word of "genpng", so it can be a program name with args.
-set dummy genpng; ac_word=$2
+fi
+if test -z "$ac_cv_path_GENHTML"; then
+  ac_pt_GENHTML=$GENHTML
+  # Extract the first word of "genhtml", so it can be a program name with args.
+set dummy genhtml; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_GENPNG+:} false; then :
+if ${ac_cv_path_ac_pt_GENHTML+:} false; then :
   $as_echo_n "(cached) " >&6
 else
-  case $GENPNG in
+  case $ac_pt_GENHTML in
   [\\/]* | ?:[\\/]*)
-  ac_cv_path_GENPNG="$GENPNG" # Let the user override the test with a path.
+  ac_cv_path_ac_pt_GENHTML="$ac_pt_GENHTML" # Let the user override the test with a path.
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
@@ -9398,7 +9526,7 @@ do
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
   if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_GENPNG="$as_dir/$ac_word$ac_exec_ext"
+    ac_cv_path_ac_pt_GENHTML="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
   fi
@@ -9409,37 +9537,150 @@ IFS=$as_save_IFS
   ;;
 esac
 fi
-GENPNG=$ac_cv_path_GENPNG
-if test -n "$GENPNG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $GENPNG" >&5
-$as_echo "$GENPNG" >&6; }
+ac_pt_GENHTML=$ac_cv_path_ac_pt_GENHTML
+if test -n "$ac_pt_GENHTML"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_GENHTML" >&5
+$as_echo "$ac_pt_GENHTML" >&6; }
 else
   { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
 fi
 
-
-  if test -n "$GENPNG"; then
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $GENPNG has all required modules" >&5
-$as_echo_n "checking whether $GENPNG has all required modules... " >&6; }
-    if $GENPNG --help > /dev/null 2>&1 ; then
-      { $as_echo "$as_me:${as_lineno-$LINENO}: result: ok" >&5
-$as_echo "ok" >&6; }
-      GENHTML="$GENHTML --frames"
-    else
-      { $as_echo "$as_me:${as_lineno-$LINENO}: result: not supported" >&5
-$as_echo "not supported" >&6; }
-      { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: GD.pm perl module is not installed" >&5
-$as_echo "$as_me: WARNING: GD.pm perl module is not installed" >&2;}
-      GENPNG=
-    fi
+  if test "x$ac_pt_GENHTML" = x; then
+    GENHTML=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    GENHTML=$ac_pt_GENHTML
   fi
+else
+  GENHTML="$ac_cv_path_GENHTML"
 fi
 
-################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable unit testing" >&5
-$as_echo_n "checking whether to enable unit testing... " >&6; }
-# Check whether --enable-testing was given.
+  test -z "$LCOV" -o -z "$GENHTML" && as_fn_error $? "lcov and genhtml are required for profiling" "$LINENO" 5
+  if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}genpng", so it can be a program name with args.
+set dummy ${ac_tool_prefix}genpng; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_GENPNG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $GENPNG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_GENPNG="$GENPNG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_GENPNG="$as_dir/$ac_word$ac_exec_ext"
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
+GENPNG=$ac_cv_path_GENPNG
+if test -n "$GENPNG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $GENPNG" >&5
+$as_echo "$GENPNG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_GENPNG"; then
+  ac_pt_GENPNG=$GENPNG
+  # Extract the first word of "genpng", so it can be a program name with args.
+set dummy genpng; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_GENPNG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_GENPNG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_GENPNG="$ac_pt_GENPNG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_GENPNG="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_GENPNG=$ac_cv_path_ac_pt_GENPNG
+if test -n "$ac_pt_GENPNG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_GENPNG" >&5
+$as_echo "$ac_pt_GENPNG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_GENPNG" = x; then
+    GENPNG=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    GENPNG=$ac_pt_GENPNG
+  fi
+else
+  GENPNG="$ac_cv_path_GENPNG"
+fi
+
+  if test -n "$GENPNG"; then
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $GENPNG has all required modules" >&5
+$as_echo_n "checking whether $GENPNG has all required modules... " >&6; }
+    if "$GENPNG" --help > /dev/null 2>&1 ; then
+      { $as_echo "$as_me:${as_lineno-$LINENO}: result: ok" >&5
+$as_echo "ok" >&6; }
+      GENHTML="$GENHTML --frames"
+    else
+      { $as_echo "$as_me:${as_lineno-$LINENO}: result: not supported" >&5
+$as_echo "not supported" >&6; }
+      { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: GD.pm perl module is not installed" >&5
+$as_echo "$as_me: WARNING: GD.pm perl module is not installed" >&2;}
+      GENPNG=
+    fi
+  fi
+fi
+
+################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable unit testing" >&5
+$as_echo_n "checking whether to enable unit testing... " >&6; }
+# Check whether --enable-testing was given.
 if test "${enable_testing+set}" = set; then :
   enableval=$enable_testing; TESTING=$enableval
 else
@@ -9450,9 +9691,7 @@ fi
 $as_echo "$TESTING" >&6; }
 
 if test "$TESTING" = yes; then
-	if  test x$PKGCONFIG_INIT != x1; then
-		pkg_config_init
-	fi
+	pkg_config_init
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for CUNIT" >&5
@@ -9560,6 +9799,7 @@ fi
 $as_echo "$VALGRIND_POOL" >&6; }
 
 if test "$VALGRIND_POOL" = yes; then
+	pkg_config_init
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for VALGRIND" >&5
@@ -9649,7 +9889,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEVMAPPER" >&5
 $as_echo "$DEVMAPPER" >&6; }
 
-if test x$DEVMAPPER = xyes; then
+if test "$DEVMAPPER" = yes; then
 
 $as_echo "#define DEVMAPPER_SUPPORT 1" >>confdefs.h
 
@@ -9668,7 +9908,7 @@ $as_echo "$LVMETAD" >&6; }
 
 BUILD_LVMETAD=$LVMETAD
 
-if test x$BUILD_LVMETAD = xyes; then
+if test "$BUILD_LVMETAD" = yes; then
 
 $as_echo "#define LVMETAD_SUPPORT 1" >>confdefs.h
 
@@ -9701,10 +9941,8 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
 $as_echo "$BLKID_WIPING" >&6; }
 
-if test x$BLKID_WIPING != xno; then
-		if test x$PKGCONFIG_INIT != x1; then
-		pkg_config_init
-	fi
+if test "$BLKID_WIPING" != no; then
+	pkg_config_init
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for BLKID" >&5
@@ -9764,31 +10002,27 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$BLKID_PKG_ERRORS" >&5
 
-	if test x$BLKID_WIPING = xmaybe; then
-					BLKID_WIPING=no
-				 else
-					as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
-				 fi
-
+	if test "$BLKID_WIPING" = maybe; then
+				BLKID_WIPING=no
+			   else
+			        as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
+			   fi
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
-	if test x$BLKID_WIPING = xmaybe; then
-					BLKID_WIPING=no
-				 else
-					as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
-				 fi
-
+	if test "$BLKID_WIPING" = maybe; then
+				BLKID_WIPING=no
+			   else
+			        as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
+			   fi
 else
 	BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
 	BLKID_LIBS=$pkg_cv_BLKID_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-	if test x$BLKID_WIPING = xmaybe; then
-					BLKID_WIPING=yes
-				 fi
+	test "$BLKID_WIPING" = maybe && BLKID_WIPING=yes
 fi
-	if test x$BLKID_WIPING = xyes; then
+	if test "$BLKID_WIPING" = yes; then
 		BLKID_PC="blkid"
 
 $as_echo "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
@@ -9822,10 +10056,8 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYNC" >&5
 $as_echo "$UDEV_SYNC" >&6; }
 
-if test x$UDEV_SYNC = xyes; then
-		if  test x$PKGCONFIG_INIT != x1; then
-		pkg_config_init
-	fi
+if test "$UDEV_SYNC" = yes; then
+	pkg_config_init
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for UDEV" >&5
@@ -9946,16 +10178,18 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULE_EXEC_DETECTION" >&5
 $as_echo "$UDEV_RULE_EXEC_DETECTION" >&6; }
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether udev supports built-in blkid" >&5
+if test "$UDEV_RULE" != no ; then
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether udev supports built-in blkid" >&5
 $as_echo_n "checking whether udev supports built-in blkid... " >&6; }
-test x$PKGCONFIG_INIT != x1 && pkg_config_init
-if $($PKG_CONFIG --atleast-version=176 libudev); then
-	UDEV_HAS_BUILTIN_BLKID=yes
-else
-	UDEV_HAS_BUILTIN_BLKID=no
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_HAS_BUILTIN_BLKID" >&5
+	pkg_config_init
+	if $("$PKG_CONFIG" --atleast-version=176 libudev); then
+		UDEV_HAS_BUILTIN_BLKID=yes
+	else
+		UDEV_HAS_BUILTIN_BLKID=no
+	fi
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_HAS_BUILTIN_BLKID" >&5
 $as_echo "$UDEV_HAS_BUILTIN_BLKID" >&6; }
+fi
 
 ################################################################################
 # Check whether --enable-compat was given.
@@ -9966,11 +10200,10 @@ else
 fi
 
 
-if test x$DM_COMPAT = xyes; then
+if test "$DM_COMPAT" = yes; then
 	as_fn_error $? "--enable-compat is not currently supported.
 Since device-mapper version 1.02.66, only one version (4) of the device-mapper
-ioctl protocol is supported.
-	" "$LINENO" 5
+ioctl protocol is supported." "$LINENO" 5
 fi
 
 ################################################################################
@@ -9982,7 +10215,7 @@ else
 fi
 
 
-if test x$UNITS_COMPAT = xyes; then
+if test "$UNITS_COMPAT" = yes; then
 
 $as_echo "#define DEFAULT_SI_UNIT_CONSISTENCY 0" >>confdefs.h
 
@@ -10006,7 +10239,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ODIRECT" >&5
 $as_echo "$ODIRECT" >&6; }
 
-if test x$ODIRECT = xyes; then
+if test "$ODIRECT" = yes; then
 
 $as_echo "#define O_DIRECT_SUPPORT 1" >>confdefs.h
 
@@ -10025,7 +10258,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $APPLIB" >&5
 $as_echo "$APPLIB" >&6; }
 
-test x$APPLIB = xyes \
+test "$APPLIB" = yes \
   && LVM2APP_LIB=-llvm2app \
   || LVM2APP_LIB=
 
@@ -10042,7 +10275,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CMDLIB" >&5
 $as_echo "$CMDLIB" >&6; }
 
-test x$CMDLIB = xyes \
+test "$CMDLIB" = yes \
   && LVM2CMD_LIB=-llvm2cmd \
   || LVM2CMD_LIB=
 
@@ -10059,14 +10292,12 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON_BINDINGS" >&5
 $as_echo "$PYTHON_BINDINGS" >&6; }
 
-if test x$PYTHON_BINDINGS = xyes; then
-	if test x$APPLIB != xyes; then
-		as_fn_error $? "--enable-python_bindings requires --enable-applib
-		" "$LINENO" 5
-	fi
+if test "$PYTHON_BINDINGS" = yes; then
+	test "$APPLIB" != yes && as_fn_error $? "--enable-python_bindings requires --enable-applib" "$LINENO" 5
 
-	# Extract the first word of "python", so it can be a program name with args.
-set dummy python; ac_word=$2
+	if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}python", so it can be a program name with args.
+set dummy ${ac_tool_prefix}python; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_PYTHON+:} false; then :
@@ -10092,7 +10323,6 @@ done
   done
 IFS=$as_save_IFS
 
-  test -z "$ac_cv_path_PYTHON" && ac_cv_path_PYTHON="notfound"
   ;;
 esac
 fi
@@ -10106,13 +10336,68 @@ $as_echo "no" >&6; }
 fi
 
 
-	if test x$PYTHON == xnotfound; then
-		as_fn_error $? "python is required for --enable-python_bindings but cannot be found
-		" "$LINENO" 5
-	fi
+fi
+if test -z "$ac_cv_path_PYTHON"; then
+  ac_pt_PYTHON=$PYTHON
+  # Extract the first word of "python", so it can be a program name with args.
+set dummy python; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_PYTHON+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_PYTHON in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_PYTHON="$ac_pt_PYTHON" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_PYTHON="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
 
-	# Extract the first word of "python-config", so it can be a program name with args.
-set dummy python-config; ac_word=$2
+  ;;
+esac
+fi
+ac_pt_PYTHON=$ac_cv_path_ac_pt_PYTHON
+if test -n "$ac_pt_PYTHON"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON" >&5
+$as_echo "$ac_pt_PYTHON" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_PYTHON" = x; then
+    PYTHON=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    PYTHON=$ac_pt_PYTHON
+  fi
+else
+  PYTHON="$ac_cv_path_PYTHON"
+fi
+
+	test -z "$PYTHON" && as_fn_error $? "python is required for --enable-python_bindings but cannot be found" "$LINENO" 5
+
+	if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}python-config", so it can be a program name with args.
+set dummy ${ac_tool_prefix}python-config; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_PYTHON_CONFIG+:} false; then :
@@ -10138,7 +10423,6 @@ done
   done
 IFS=$as_save_IFS
 
-  test -z "$ac_cv_path_PYTHON_CONFIG" && ac_cv_path_PYTHON_CONFIG="notfound"
   ;;
 esac
 fi
@@ -10152,14 +10436,67 @@ $as_echo "no" >&6; }
 fi
 
 
-	if test x$PYTHON_CONFIG == xnotfound; then
-		as_fn_error $? "python headers are required for --enable-python_bindings but cannot be found
-		" "$LINENO" 5
-	fi
+fi
+if test -z "$ac_cv_path_PYTHON_CONFIG"; then
+  ac_pt_PYTHON_CONFIG=$PYTHON_CONFIG
+  # Extract the first word of "python-config", so it can be a program name with args.
+set dummy python-config; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_PYTHON_CONFIG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_PYTHON_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_PYTHON_CONFIG="$ac_pt_PYTHON_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_PYTHON_CONFIG="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
 
-	PYTHON_INCDIRS=`$PYTHON_CONFIG --includes`
-	PYTHON_LIBDIRS=`$PYTHON_CONFIG --libs`
+  ;;
+esac
+fi
+ac_pt_PYTHON_CONFIG=$ac_cv_path_ac_pt_PYTHON_CONFIG
+if test -n "$ac_pt_PYTHON_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON_CONFIG" >&5
+$as_echo "$ac_pt_PYTHON_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
 
+  if test "x$ac_pt_PYTHON_CONFIG" = x; then
+    PYTHON_CONFIG=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    PYTHON_CONFIG=$ac_pt_PYTHON_CONFIG
+  fi
+else
+  PYTHON_CONFIG="$ac_cv_path_PYTHON_CONFIG"
+fi
+
+	test -z "$PYTHON_CONFIG" && as_fn_error $? "python headers are required for --enable-python_bindings but cannot be found" "$LINENO" 5
+
+	PYTHON_INCDIRS=`"$PYTHON_CONFIG" --includes`
+	PYTHON_LIBDIRS=`"$PYTHON_CONFIG" --libs`
 fi
 
 ################################################################################
@@ -10215,18 +10552,14 @@ $as_echo "$DMEVENTD" >&6; }
 
 BUILD_DMEVENTD=$DMEVENTD
 
-if test x$DMEVENTD = xyes; then
-   if test x$MIRRORS != xinternal; then
-      as_fn_error $? "--enable-dmeventd currently requires --with-mirrors=internal
-      " "$LINENO" 5
+if test "$DMEVENTD" = yes; then
+   if test "$MIRRORS" != internal; then
+      as_fn_error $? "--enable-dmeventd currently requires --with-mirrors=internal" "$LINENO" 5
    fi
-   if test x$CMDLIB = xno; then
-      as_fn_error $? "--enable-dmeventd requires --enable-cmdlib to be used as well
-      " "$LINENO" 5
+   if test "$CMDLIB" = no; then
+      as_fn_error $? "--enable-dmeventd requires --enable-cmdlib to be used as well" "$LINENO" 5
    fi
-fi
 
-if test x$DMEVENTD = xyes; then
 
 $as_echo "#define DMEVENTD 1" >>confdefs.h
 
@@ -10323,9 +10656,7 @@ fi
 
 
 ################################################################################
-if [ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ];
- then  exec_prefix="";
-fi;
+test "$exec_prefix" = NONE -a "$prefix" = NONE && exec_prefix=""
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for dlopen in -ldl" >&5
@@ -10366,26 +10697,22 @@ fi
 $as_echo "$ac_cv_lib_dl_dlopen" >&6; }
 if test "x$ac_cv_lib_dl_dlopen" = xyes; then :
 
-
 $as_echo "#define HAVE_LIBDL 1" >>confdefs.h
 
-	DL_LIBS="-ldl"
-	HAVE_LIBDL=yes
+	      DL_LIBS="-ldl"
+	      HAVE_LIBDL=yes
 else
-
-	DL_LIBS=
-	HAVE_LIBDL=no
+  DL_LIBS=
+	      HAVE_LIBDL=no
 fi
 
 
 ################################################################################
-if [ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
-      -o "x$SNAPSHOTS" = xshared -o "x$MIRRORS" = xshared \
-      -o "x$RAID" = xshared \
-      -o "x$CACHE" = xshared \
-      \) -a "x$STATIC_LINK" = xyes ];
- then  as_fn_error $? "Features cannot be 'shared' when building statically
-" "$LINENO" 5
+if [ \( "$LVM1" = shared -o "$POOL" = shared -o "$CLUSTER" = shared \
+      -o "$SNAPSHOTS" = shared -o "$MIRRORS" = shared \
+      -o "$RAID" = shared -o "$CACHE" = shared \
+      \) -a "$STATIC_LINK" = yes ]; then
+	as_fn_error $? "Features cannot be 'shared' when building statically" "$LINENO" 5
 fi
 
 ################################################################################
@@ -10444,7 +10771,7 @@ fi
 $as_echo "$SELINUX" >&6; }
 
 ################################################################################
-if test x$SELINUX = xyes; then
+if test "$SELINUX" = yes; then
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for sepol_check_context in -lsepol" >&5
 $as_echo_n "checking for sepol_check_context in -lsepol... " >&6; }
 if ${ac_cv_lib_sepol_sepol_check_context+:} false; then :
@@ -10572,7 +10899,7 @@ fi
 fi
 
 ################################################################################
-if test x$REALTIME = xyes; then
+if test "$REALTIME" = yes; then
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for clock_gettime in -lrt" >&5
 $as_echo_n "checking for clock_gettime in -lrt... " >&6; }
 if ${ac_cv_lib_rt_clock_gettime+:} false; then :
@@ -10616,7 +10943,7 @@ else
 fi
 
 
-	if test x$HAVE_REALTIME = xyes; then
+	if test "$HAVE_REALTIME" = yes; then
 
 $as_echo "#define HAVE_REALTIME 1" >>confdefs.h
 
@@ -10843,11 +11170,12 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $INTL" >&5
 $as_echo "$INTL" >&6; }
 
-if test x$INTL = xyes; then
+if test "$INTL" = yes; then
 # FIXME - Move this - can be device-mapper too
 	INTL_PACKAGE="lvm2"
-	# Extract the first word of "msgfmt", so it can be a program name with args.
-set dummy msgfmt; ac_word=$2
+	if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}msgfmt", so it can be a program name with args.
+set dummy ${ac_tool_prefix}msgfmt; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_MSGFMT+:} false; then :
@@ -10886,10 +11214,66 @@ $as_echo "no" >&6; }
 fi
 
 
-	if [ "x$MSGFMT" == x ];
-		then  as_fn_error $? "msgfmt not found in path $PATH
-		" "$LINENO" 5
-	fi;
+fi
+if test -z "$ac_cv_path_MSGFMT"; then
+  ac_pt_MSGFMT=$MSGFMT
+  # Extract the first word of "msgfmt", so it can be a program name with args.
+set dummy msgfmt; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_MSGFMT+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_MSGFMT in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_MSGFMT="$ac_pt_MSGFMT" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_MSGFMT="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_MSGFMT=$ac_cv_path_ac_pt_MSGFMT
+if test -n "$ac_pt_MSGFMT"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_MSGFMT" >&5
+$as_echo "$ac_pt_MSGFMT" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_MSGFMT" = x; then
+    MSGFMT=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    MSGFMT=$ac_pt_MSGFMT
+  fi
+else
+  MSGFMT="$ac_cv_path_MSGFMT"
+fi
+
+	if [ -z "$MSGFMT" ]; then
+		as_fn_error $? "msgfmt not found in path $PATH" "$LINENO" 5
+	fi
 
 
 # Check whether --with-localedir was given.
@@ -10963,23 +11347,17 @@ fi
 if test "${with_systemdsystemunitdir+set}" = set; then :
   withval=$with_systemdsystemunitdir; systemdsystemunitdir=$withval
 else
-  	    test x$PKGCONFIG_INIT != x1 && pkg_config_init
-	    pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)
+  pkg_config_init
+	    pkg_systemdsystemunitdir=$("$PKG_CONFIG" --variable=systemdsystemunitdir systemd)
 fi
 
 
-if test -n "$pkg_systemdsystemunitdir"; then
-	    systemdsystemunitdir=$pkg_systemdsystemunitdir;
-fi
+test -n "$pkg_systemdsystemunitdir" && systemdsystemunitdir=$pkg_systemdsystemunitdir
+test -z "$systemdsystemunitdir" && systemdsystemunitdir='${exec_prefix}/lib/systemd/system';
 
-if test -z "$systemdsystemunitdir"; then
-	    systemdsystemunitdir='${exec_prefix}/lib/systemd/system';
-fi
+systemdutildir=$("$PKG_CONFIG" --variable=systemdutildir systemd)
+test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
 
-systemdutildir=$($PKG_CONFIG --variable=systemdutildir systemd)
-if test -z "$systemdutildir"; then
-	    systemdutildir='${exec_prefix}/lib/systemd';
-fi
 ################################################################################
 
 # Check whether --with-tmpfilesdir was given.
@@ -10990,7 +11368,7 @@ else
 fi
 
 ################################################################################
-if test x$READLINE = xyes; then
+if test "$READLINE" = yes; then
 	for ac_header in readline/readline.h readline/history.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
@@ -11001,14 +11379,14 @@ if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
 _ACEOF
 
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  hard_bailout
 fi
 
 done
 
 fi
 
-if test x$CLVMD != xnone; then
+if test "$CLVMD" != none; then
 	for ac_header in mntent.h netdb.h netinet/in.h pthread.h search.h sys/mount.h sys/socket.h sys/uio.h sys/un.h utmpx.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
@@ -11034,7 +11412,7 @@ if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
 _ACEOF
 
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  hard_bailout
 fi
 done
 
@@ -11179,7 +11557,7 @@ rm -f conftest*
 
 fi
 
-if test x$CLUSTER != xnone; then
+if test "$CLUSTER" != none; then
 	for ac_header in sys/socket.h sys/un.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
@@ -11190,7 +11568,7 @@ if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
 _ACEOF
 
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  hard_bailout
 fi
 
 done
@@ -11204,13 +11582,13 @@ if test "x$ac_cv_func_socket" = xyes; then :
 _ACEOF
 
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  hard_bailout
 fi
 done
 
 fi
 
-if test x$DMEVENTD = xyes; then
+if test "$DMEVENTD" = yes; then
 	for ac_header in arpa/inet.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "arpa/inet.h" "ac_cv_header_arpa_inet_h" "$ac_includes_default"
@@ -11220,14 +11598,14 @@ if test "x$ac_cv_header_arpa_inet_h" = xyes; then :
 _ACEOF
 
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  hard_bailout
 fi
 
 done
 
 fi
 
-if test x$HAVE_LIBDL = xyes; then
+if test "$HAVE_LIBDL" = yes; then
 	for ac_header in dlfcn.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "dlfcn.h" "ac_cv_header_dlfcn_h" "$ac_includes_default"
@@ -11237,14 +11615,14 @@ if test "x$ac_cv_header_dlfcn_h" = xyes; then :
 _ACEOF
 
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  hard_bailout
 fi
 
 done
 
 fi
 
-if test x$INTL = xyes; then
+if test "$INTL" = yes; then
 	for ac_header in libintl.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "libintl.h" "ac_cv_header_libintl_h" "$ac_includes_default"
@@ -11254,14 +11632,14 @@ if test "x$ac_cv_header_libintl_h" = xyes; then :
 _ACEOF
 
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  hard_bailout
 fi
 
 done
 
 fi
 
-if test x$UDEV_SYNC = xyes; then
+if test "$UDEV_SYNC" = yes; then
 	for ac_header in sys/ipc.h sys/sem.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
@@ -11272,7 +11650,7 @@ if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
 _ACEOF
 
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  hard_bailout
 fi
 
 done
@@ -11280,8 +11658,9 @@ done
 fi
 
 ################################################################################
-# Extract the first word of "modprobe", so it can be a program name with args.
-set dummy modprobe; ac_word=$2
+if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}modprobe", so it can be a program name with args.
+set dummy ${ac_tool_prefix}modprobe; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_MODPROBE_CMD+:} false; then :
@@ -11320,8 +11699,65 @@ $as_echo "no" >&6; }
 fi
 
 
+fi
+if test -z "$ac_cv_path_MODPROBE_CMD"; then
+  ac_pt_MODPROBE_CMD=$MODPROBE_CMD
+  # Extract the first word of "modprobe", so it can be a program name with args.
+set dummy modprobe; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_MODPROBE_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_MODPROBE_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_MODPROBE_CMD="$ac_pt_MODPROBE_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_MODPROBE_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_MODPROBE_CMD=$ac_cv_path_ac_pt_MODPROBE_CMD
+if test -n "$ac_pt_MODPROBE_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_MODPROBE_CMD" >&5
+$as_echo "$ac_pt_MODPROBE_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_MODPROBE_CMD" = x; then
+    MODPROBE_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    MODPROBE_CMD=$ac_pt_MODPROBE_CMD
+  fi
+else
+  MODPROBE_CMD="$ac_cv_path_MODPROBE_CMD"
+fi
+
 
-if test x$MODPROBE_CMD != x; then
+if test -n "$MODPROBE_CMD"; then
 
 cat >>confdefs.h <<_ACEOF
 #define MODPROBE_CMD "$MODPROBE_CMD"
@@ -11341,9 +11777,9 @@ _ACEOF
 
 
 if  test "$CLVMD" != none; then
-        clvmd_prefix=$ac_default_prefix
-        CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
-        test "$prefix" != NONE && clvmd_prefix=$prefix
+	clvmd_prefix=$ac_default_prefix
+	CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
+	test "$prefix" != NONE && clvmd_prefix=$prefix
 
 cat >>confdefs.h <<_ACEOF
 #define CLVMD_PATH "$CLVMD_PATH"
@@ -11495,10 +11931,7 @@ else
   interface=ioctl
 fi
 
-if [ "x$interface" != xioctl ];
-then
-  as_fn_error $? "--with-interface=ioctl required. fs no longer supported." "$LINENO" 5
-fi
+test "$interface" != ioctl && as_fn_error $? "--with-interface=ioctl required. fs no longer supported." "$LINENO" 5
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $interface" >&5
 $as_echo "$interface" >&6; }
 
@@ -11655,6 +12088,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile
  python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
@@ -13019,7 +13453,5 @@ $as_echo "$as_me: WARNING: Support for thin provisioning is limited since some t
 test -n "$THIN_CHECK_VERSION_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&5
 $as_echo "$as_me: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&2;}
 
-if test x$ODIRECT != xyes; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
+test "$ODIRECT" != yes && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 $as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
-fi


