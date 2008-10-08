From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Oct 2008 12:50:25 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in ./ ...
Message-ID: <20081008125025.3380.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-08 12:50:14

Modified files:
	.              : WHATS_NEW configure configure.in make.tmpl.in 
	man            : Makefile.in 
Added files:
	man            : clvmd.8.in fsadm.8.in lvchange.8.in 
	                 lvconvert.8.in lvcreate.8.in lvdisplay.8.in 
	                 lvextend.8.in lvm.8.in lvm.conf.5.in 
	                 lvmchange.8.in lvmdiskscan.8.in lvmdump.8.in 
	                 lvreduce.8.in lvremove.8.in lvrename.8.in 
	                 lvresize.8.in lvs.8.in lvscan.8.in 
	                 pvchange.8.in pvck.8.in pvcreate.8.in 
	                 pvdisplay.8.in pvmove.8.in pvremove.8.in 
	                 pvresize.8.in pvs.8.in pvscan.8.in 
	                 vgcfgbackup.8.in vgcfgrestore.8.in 
	                 vgchange.8.in vgck.8.in vgconvert.8.in 
	                 vgcreate.8.in vgdisplay.8.in vgexport.8.in 
	                 vgextend.8.in vgimport.8.in vgmerge.8.in 
	                 vgmknodes.8.in vgreduce.8.in vgremove.8.in 
	                 vgrename.8.in vgs.8.in vgscan.8.in vgsplit.8.in 
Removed files:
	man            : clvmd.8 lvchange.8 lvconvert.8 lvcreate.8 
	                 lvdisplay.8 lvextend.8 lvm.8 lvm.conf.5 
	                 lvmchange.8 lvmdiskscan.8 lvmdump.8 lvreduce.8 
	                 lvremove.8 lvrename.8 lvresize.8 lvs.8 lvscan.8 
	                 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 
	                 pvmove.8 pvremove.8 pvresize.8 pvs.8 pvscan.8 
	                 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 vgck.8 
	                 vgconvert.8 vgcreate.8 vgdisplay.8 vgexport.8 
	                 vgextend.8 vgimport.8 vgmerge.8 vgmknodes.8 
	                 vgreduce.8 vgremove.8 vgrename.8 vgs.8 vgscan.8 
	                 vgsplit.8 

Log message:
	Generate man pages from templates and include version.  (romster)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.972&r2=1.973
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/fsadm.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvdisplay.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmchange.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdiskscan.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdump.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvremove.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvrename.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvscan.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvck.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvdisplay.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvremove.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvresize.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgbackup.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgrestore.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgck.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgconvert.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgdisplay.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgexport.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgimport.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmerge.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmknodes.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgreduce.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgremove.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgrename.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgscan.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.16&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.diff?cvsroot=lvm2&r1=1.10&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.22&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvdisplay.8.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.diff?cvsroot=lvm2&r1=1.10&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.diff?cvsroot=lvm2&r1=1.13&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.diff?cvsroot=lvm2&r1=1.23&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmchange.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdiskscan.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdump.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.diff?cvsroot=lvm2&r1=1.11&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvremove.8.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvrename.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.diff?cvsroot=lvm2&r1=1.8&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvscan.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvck.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvdisplay.8.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvremove.8.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvresize.8.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgbackup.8.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgrestore.8.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.diff?cvsroot=lvm2&r1=1.14&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgck.8.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgconvert.8.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.diff?cvsroot=lvm2&r1=1.8&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgdisplay.8.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgexport.8.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgimport.8.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmerge.8.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmknodes.8.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgreduce.8.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgremove.8.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgrename.8.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgscan.8.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.diff?cvsroot=lvm2&r1=1.8&r2=NONE

--- LVM2/WHATS_NEW	2008/10/07 19:11:58	1.972
+++ LVM2/WHATS_NEW	2008/10/08 12:50:12	1.973
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Generate man pages from templates and include version.
   Add usrlibdir and usrsbindir to configure.
   Fix conversion of md chunk size into sectors.
   Free text metadata buffer after a failure writing it.
--- LVM2/configure	2008/10/07 19:11:59	1.78
+++ LVM2/configure	2008/10/08 12:50:12	1.79
@@ -663,6 +663,7 @@
 target_cpu
 target_vendor
 target_os
+SED
 AWK
 CC
 CFLAGS
@@ -1990,6 +1991,90 @@
 esac
 
 ################################################################################
+{ echo "$as_me:$LINENO: checking for a sed that does not truncate output" >&5
+echo $ECHO_N "checking for a sed that does not truncate output... $ECHO_C" >&6; }
+if test "${ac_cv_path_SED+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+            ac_script=s/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb/
+     for ac_i in 1 2 3 4 5 6 7; do
+       ac_script="$ac_script$as_nl$ac_script"
+     done
+     echo "$ac_script" | sed 99q >conftest.sed
+     $as_unset ac_script || ac_script=
+     # Extract the first word of "sed gsed" to use in msg output
+if test -z "$SED"; then
+set dummy sed gsed; ac_prog_name=$2
+if test "${ac_cv_path_SED+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  ac_path_SED_found=false
+# Loop through the user's path and test for each of PROGNAME-LIST
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_prog in sed gsed; do
+  for ac_exec_ext in '' $ac_executable_extensions; do
+    ac_path_SED="$as_dir/$ac_prog$ac_exec_ext"
+    { test -f "$ac_path_SED" && $as_test_x "$ac_path_SED"; } || continue
+    # Check for GNU ac_path_SED and select it if it is found.
+  # Check for GNU $ac_path_SED
+case `"$ac_path_SED" --version 2>&1` in
+*GNU*)
+  ac_cv_path_SED="$ac_path_SED" ac_path_SED_found=:;;
+*)
+  ac_count=0
+  echo $ECHO_N "0123456789$ECHO_C" >"conftest.in"
+  while :
+  do
+    cat "conftest.in" "conftest.in" >"conftest.tmp"
+    mv "conftest.tmp" "conftest.in"
+    cp "conftest.in" "conftest.nl"
+    echo '' >> "conftest.nl"
+    "$ac_path_SED" -f conftest.sed < "conftest.nl" >"conftest.out" 2>/dev/null || break
+    diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
+    ac_count=`expr $ac_count + 1`
+    if test $ac_count -gt ${ac_path_SED_max-0}; then
+      # Best one so far, save it but keep looking for a better one
+      ac_cv_path_SED="$ac_path_SED"
+      ac_path_SED_max=$ac_count
+    fi
+    # 10*(2^10) chars as input seems more than enough
+    test $ac_count -gt 10 && break
+  done
+  rm -f conftest.in conftest.tmp conftest.nl conftest.out;;
+esac
+
+
+    $ac_path_SED_found && break 3
+  done
+done
+
+done
+IFS=$as_save_IFS
+
+
+fi
+
+SED="$ac_cv_path_SED"
+if test -z "$SED"; then
+  { { echo "$as_me:$LINENO: error: no acceptable $ac_prog_name could be found in \$PATH" >&5
+echo "$as_me: error: no acceptable $ac_prog_name could be found in \$PATH" >&2;}
+   { (exit 1); exit 1; }; }
+fi
+
+else
+  ac_cv_path_SED=$SED
+fi
+
+fi
+{ echo "$as_me:$LINENO: result: $ac_cv_path_SED" >&5
+echo "${ECHO_T}$ac_cv_path_SED" >&6; }
+ SED="$ac_cv_path_SED"
+  rm -f conftest.sed
+
 for ac_prog in gawk mawk nawk awk
 do
   # Extract the first word of "$ac_prog", so it can be a program name with args.
@@ -12175,6 +12260,7 @@
 target_cpu!$target_cpu$ac_delim
 target_vendor!$target_vendor$ac_delim
 target_os!$target_os$ac_delim
+SED!$SED$ac_delim
 AWK!$AWK$ac_delim
 CC!$CC$ac_delim
 CFLAGS!$CFLAGS$ac_delim
@@ -12222,7 +12308,6 @@
 DM_LIB_VERSION!$DM_LIB_VERSION$ac_delim
 FSADM!$FSADM$ac_delim
 GROUP!$GROUP$ac_delim
-HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 _ACEOF
 
   if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 97; then
@@ -12264,6 +12349,7 @@
 ac_delim='%!_!# '
 for ac_last_try in false false false false false :; do
   cat >conf$$subs.sed <<_ACEOF
+HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 HAVE_REALTIME!$HAVE_REALTIME$ac_delim
 HAVE_SELINUX!$HAVE_SELINUX$ac_delim
 INTL!$INTL$ac_delim
@@ -12289,7 +12375,7 @@
 LTLIBOBJS!$LTLIBOBJS$ac_delim
 _ACEOF
 
-  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 23; then
+  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 24; then
     break
   elif $ac_last_try; then
     { { echo "$as_me:$LINENO: error: could not make $CONFIG_STATUS" >&5
--- LVM2/configure.in	2008/10/07 19:11:59	1.79
+++ LVM2/configure.in	2008/10/08 12:50:13	1.80
@@ -62,6 +62,7 @@
 
 ################################################################################
 dnl -- Checks for programs.
+AC_PROG_SED
 AC_PROG_AWK
 AC_PROG_CC
 
--- LVM2/make.tmpl.in	2008/10/07 19:11:59	1.56
+++ LVM2/make.tmpl.in	2008/10/08 12:50:13	1.57
@@ -26,6 +26,8 @@
 LCOV = @LCOV@
 GENHTML = @GENHTML@
 LN_S = @LN_S@
+SED = @SED@
+
 LIBS = @LIBS@
 DEFS += @DEFS@
 CFLAGS += @CFLAGS@
@@ -96,6 +98,8 @@
 STRIP=
 #STRIP = -s
 
+LVM_VERSION := $(shell cat $(top_srcdir)/VERSION)
+
 LIB_VERSION := $(shell cat $(top_srcdir)/VERSION | \
 		 awk -F '.' '{printf "%s.%s",$$1,$$2}')
 
/cvs/lvm2/LVM2/man/clvmd.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/clvmd.8.in
+++ -	2008-10-08 12:50:14.672460000 +0000
@@ -0,0 +1,80 @@
+.TH CLVMD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.SH NAME
+clvmd \- cluster LVM daemon
+.SH SYNOPSIS
+.B clvmd
+[\-d [<value>]] [\-C] [\-h]
+[\-R]
+[\-t <timeout>]
+[\-T <start timeout>]
+[\-V]
+.SH DESCRIPTION
+clvmd is the daemon that distributes LVM metadata updates around a cluster.
+It must be running on all nodes in the cluster and will give an error 
+if a node in the cluster does not have this daemon running.
+.SH OPTIONS
+.TP
+.I \-d [<value>]
+Enable debug logging. Value can be 0, 1 or 2.
+.br
+0 disables debug logging in a running clvmd
+.br
+1 sends debug logs to stderr (clvmd will not fork in this case)
+.br
+2 sends debug logs to syslog
+.br
+If 
+.B -d 
+is specified without a value then 1 is assumed if you are starting a
+new clvmd, 2 if you are enabling debug in a running clvmd.
+.TP
+.I \-C
+Only valid if 
+.B -d 
+is also specified. Tells all clvmds in a cluster to enable/disable debug logging.
+Without this switch, only the local clvmd will change its debug level to that
+given with 
+.B -d.
+.br
+This does not work correctly if specified on the command-line that starts clvmd.
+If you want to start clvmd 
+.B and 
+enable cluster-wide logging then the command needs to be issued twice, eg:
+.br
+clvmd
+.br
+clvmd -d2
+.br
+.TP
+.I \-t <timeout>
+Specifies the timeout for commands to run around the cluster. This should not
+be so small that commands with many disk updates to do will fail, so you
+may need to increase this on systems with very large disk farms. 
+The default is 30 seconds.
+.TP
+.I \-T <start timeout>
+Specifies the timeout for clvmd daemon startup. If the daemon does not report 
+that it has started up within this time then the parent command will exit with 
+status of 5. This does NOT mean that clvmd has not started! What it means is 
+that the startup of clvmd has been delayed for some reason; the most likely 
+cause of this is an inquorate cluster though it could be due to locking 
+latencies on a cluster with large numbers of logical volumes. If you get the 
+return code of 5 it is usually not necessary to restart clvmd - it will start
+as soon as that blockage has cleared. This flag is to allow startup scripts
+to exit in a timely fashion even if the cluster is stalled for some reason.
+.br
+The default is 0 (no timeout) and the value is in seconds. Don't set this too
+small or you will experience spurious errors. 10 or 20 seconds might be
+sensible.
+.br
+This timeout will be ignored if you start clvmd with the -d switch.
+.TP
+.I \-R
+Tells all the running clvmds in the cluster to reload their device cache and
+re-read the lvm configuration file. This command should be run whenever the
+devices on a cluster system are changed.
+.TP
+.I \-V
+Display the version of the cluster LVM daemon.
+.SH SEE ALSO
+.BR lvm (8)
/cvs/lvm2/LVM2/man/fsadm.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/fsadm.8.in
+++ -	2008-10-08 12:50:14.752330000 +0000
@@ -0,0 +1,56 @@
+.TH "FSADM" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.SH "NAME"
+fsadm \- utility to resize or check filesystem on a device
+.SH "SYNOPSIS"
+.B fsdam
+.RI [options]\ check\ device
+
+.B fsdam
+.RI [options]\ resize\ device\ [new_size[BKMGTEP]]
+
+.SH "DESCRIPTION"
+\fBfsadm\fR utility resizes or checks the filesystem on a device. It tries to use the same API for \fBExt2/3\fR, \fBReiserFS\fR and \fBXFS\fR filesystem and simply resize and filesystem check operation.
+.SH "OPTIONS"
+.TP 
+\fB\-h \-\-help\fR
+\(em print help message
+.TP 
+\fB\-v \-\-verbose\fR
+\(em be more verbose
+.TP 
+\fB\-e \-\-ext\-offline\fR
+\(em unmount Ext2/3 filesystem before doing resize
+.TP 
+\fB\-f \-\-force\fR
+\(em bypass some sanity checks
+.TP 
+\fB\-n \-\-dry\-run\fR
+\(em print commands without running them
+.TP 
+\fB\-y \-\-yes\fR
+\(em answer "yes" at any prompts
+.TP  
+\fBnew_size\fR
+\(em Absolute number of filesystem blocks to be in the filesystem, or an absolute size using a suffix (in powers of 1024). If new_size is not supplied, the whole device is used.
+
+
+.SH "EXAMPLES"
+"fsadm \-e \-y resize /dev/vg/test 1000M" tries to resize the size of the filesystem on logical volume /dev/vg/test. If /dev/vg/test contains Ext2/3 filesystem it will be unmounted prior the resize. All [y|n] questions will be answered 'y'.
+.SH "ENVIRONMENT VARIABLES"
+.TP 
+\fBTMPDIR\fP 
+Where the temporary directory should be created.
+.TP 
+.BR 
+.SH "SEE ALSO"
+.BR lvm (8), 
+.BR lvresize (8), 
+.BR lvm.conf (5),
+.BR tune2fs (8),
+.BR resize2fs (8),
+.BR reiserfstune (8),
+.BR resize_reiserfs (8),
+.BR xfs_info (8),
+.BR xfs_growfs (8),
+.BR xfs_check (8)
+
/cvs/lvm2/LVM2/man/lvchange.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvchange.8.in
+++ -	2008-10-08 12:50:14.841655000 +0000
@@ -0,0 +1,95 @@
+.TH LVCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvchange \- change attributes of a logical volume
+.SH SYNOPSIS
+.B lvchange
+[\-\-addtag Tag]
+[\-A/\-\-autobackup y/n] [\-a/\-\-available y/n/ey/en/ly/ln]
+[\-\-alloc AllocationPolicy]
+[\-C/\-\-contiguous y/n] [\-d/\-\-debug] [\-\-deltag Tag]
+[\-\-resync]
+[\-h/\-?/\-\-help]
+[\-\-ignorelockingfailure]
+[\-\-ignoremonitoring]
+[\-\-monitor {y|n}]
+[\-M/\-\-persistent y/n] [\-\-minor minor]
+[\-P/\-\-partial]
+[\-p/\-\-permission r/w] [\-r/\-\-readahead ReadAheadSectors|auto|none]
+[\-\-refresh]
+[\-t/\-\-test]
+[\-v/\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+.SH DESCRIPTION
+lvchange allows you to change the attributes of a logical volume
+including making them known to the kernel ready for use.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-a, \-\-available y/n/ey/en/ly/ln
+Controls the availability of the logical volumes for use.
+Communicates with the kernel device-mapper driver via
+libdevmapper to activate (-ay) or deactivate (-an) the 
+logical volumes.
+.IP
+If clustered locking is enabled, -aey will activate exclusively
+on one node and -aly will activate only on the local node.
+To deactivate only on the local node use -aln.
+Logical volumes with single-host snapshots are always activated 
+exclusively because they can only be used on one node at once.
+.TP
+.I \-C, \-\-contiguous y/n
+Tries to set or reset the contiguous allocation policy for
+logical volumes. It's only possible to change a non-contiguous
+logical volume's allocation policy to contiguous, if all of the
+allocated physical extents are already contiguous.
+.TP
+.I \-\-resync
+Forces the complete resynchronization of a mirror.  In normal
+circumstances you should not need this option because synchronization
+happens automatically.  Data is read from the primary mirror device
+and copied to the others, so this can take a considerable amount of
+time - and during this time you are without a complete redundant copy
+of your data.
+.TP
+.I \-\-minor minor
+Set the minor number.
+.TP
+.I \-\-monitor y/n
+Controls whether or not a mirrored logical volume is monitored by
+dmeventd, if it is installed.
+If a device used by a monitored mirror reports an I/O error,
+the failure is handled according to 
+\fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
+set in \fBlvm.conf\fP.
+.TP
+.I \-\-ignoremonitoring
+Make no attempt to interact with dmeventd unless \-\-monitor
+is specified.
+Do not use this if dmeventd is already monitoring a device.
+.TP
+.I \-M, \-\-persistent y/n
+Set to y to make the minor number specified persistent.
+.TP
+.I \-p, \-\-permission r/w
+Change access permission to read-only or read/write.
+.TP
+.I \-r, \-\-readahead ReadAheadSectors|auto|none
+Set read ahead sector count of this logical volume.
+For volume groups with metadata in lvm1 format, this must
+be a value between 2 and 120 sectors.
+The default value is "auto" which allows the kernel to choose
+a suitable value automatically.
+"None" is equivalent to specifying zero.
+.TP
+.I \-\-refresh
+If the logical volume is active, reload its metadata.
+This is not necessary in normal operation, but may be useful
+if something has gone wrong or if you're doing clustering 
+manually without a clustered lock manager.
+.SH Examples
+"lvchange -pr vg00/lvol1" changes the permission on 
+volume lvol1 in volume group vg00 to be read-only.
+
+.SH SEE ALSO
+.BR lvm (8), 
+.BR lvcreate (8),
+.BR vgchange (8)
/cvs/lvm2/LVM2/man/lvconvert.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvconvert.8.in
+++ -	2008-10-08 12:50:14.920502000 +0000
@@ -0,0 +1,110 @@
+.TH LVCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
+.SH NAME
+lvconvert \- convert a logical volume from linear to mirror or snapshot
+.SH SYNOPSIS
+.B lvconvert
+\-m/\-\-mirrors Mirrors [\-\-mirrorlog {disk|core}] [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]
+[\-A/\-\-alloc AllocationPolicy]
+[\-b/\-\-background] [\-i/\-\-interval Seconds]
+[\-h/\-?/\-\-help]
+[\-v/\-\-verbose]
+[\-\-version]
+.br
+LogicalVolume[Path] [PhysicalVolume[Path]...]
+.br
+
+.br
+.B lvconvert
+\-s/\-\-snapshot [\-c/\-\-chunksize ChunkSize]
+[\-h/\-?/\-\-help]
+[\-v/\-\-verbose]
+[\-Z/\-\-zero y/n]
+[\-\-version]
+.br
+OriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]
+.SH DESCRIPTION
+lvconvert will change a linear logical volume to a mirror
+logical volume or to a snapshot of linear volume and vice versa.
+It is also used to add and remove disk logs from mirror devices.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.br
+Exactly one of \-\-mirrors or \-\-snapshot arguments required.
+.br
+.TP
+.I \-m, \-\-mirrors Mirrors
+Specifies the degree of the mirror you wish to create.
+For example, "-m 1" would convert the original logical
+volume to a mirror volume with 2-sides; that is, a
+linear volume plus one copy.
+.TP
+.I \-\-mirrorlog {disk|core}
+Specifies the type of log to use.
+The default is disk, which is persistent and requires
+a small amount of storage space, usually on a separate device
+from the data being mirrored. 
+Core may be useful for short-lived mirrors: It means the mirror is
+regenerated by copying the data from the first device again every
+time the device is activated - perhaps, for example, after every reboot.
+.TP
+.I \-\-corelog
+The optional argument "--corelog" is the same as specifying "--mirrorlog core".
+.TP
+.I \-R, \-\-regionsize MirrorLogRegionSize
+A mirror is divided into regions of this size (in MB), and the mirror log
+uses this granularity to track which regions are in sync.
+.TP
+.I \-b, \-\-background
+Run the daemon in the background.
+.TP
+.I \-i, \-\-interval Seconds
+Report progress as a percentage at regular intervals.
+.br
+.TP
+.I \-s, \-\-snapshot
+Create a snapshot from existing logical volume using another
+existing logical volume as its origin.
+.TP
+.I \-c, \-\-chunksize ChunkSize
+Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
+.TP
+.I \-Z, \-\-zero y/n
+Controls zeroing of the first KB of data in the snapshot.
+If the volume is read-only the snapshot will not be zeroed.
+.br
+.SH Examples
+"lvconvert -m1 vg00/lvol1"
+.br
+converts the linear logical volume "vg00/lvol1" to
+a two-way mirror logical volume.
+
+"lvconvert --mirrorlog core vg00/lvol1"
+.br
+converts a mirror with a disk log to a
+mirror with an in-memory log.
+
+"lvconvert --mirrorlog disk vg00/lvol1"
+.br
+converts a mirror with an in-memory log
+to a mirror with a disk log.
+
+"lvconvert -m0 vg00/lvol1"
+.br
+converts a mirror logical volume to a linear logical
+volume.
+.br
+
+.br
+"lvconvert -s vg00/lvol1 vg00/lvol2"
+.br
+converts logical volume "vg00/lvol2" to snapshot of original volume "vg00/lvol1"
+
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcreate (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvdisplay (8),
+.BR lvscan (8)
/cvs/lvm2/LVM2/man/lvcreate.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvcreate.8.in
+++ -	2008-10-08 12:50:14.999820000 +0000
@@ -0,0 +1,191 @@
+.TH LVCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvcreate \- create a logical volume in an existing volume group
+.SH SYNOPSIS
+.B lvcreate
+[\-\-addtag Tag]
+[\-\-alloc AllocationPolicy]
+[\-A/\-\-autobackup y/n] [\-C/\-\-contiguous y/n] [\-d/\-\-debug]
+[\-h/\-?/\-\-help]
+[\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
+{\-l/\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
+ \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
+[\-M/\-\-persistent y/n] [\-\-minor minor]
+[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
+[\-R/\-\-regionsize MirrorLogRegionSize]]
+[\-n/\-\-name LogicalVolumeName]
+[\-p/\-\-permission r/rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
+[\-t/\-\-test]
+[\-v/\-\-verbose] [\-Z/\-\-zero y/n]
+VolumeGroupName [PhysicalVolumePath...]
+.br
+
+.br
+.B lvcreate
+{\-l/\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
+ \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
+[\-c/\-\-chunksize ChunkSize]
+\-s/\-\-snapshot \-n/\-\-name SnapshotLogicalVolumeName OriginalLogicalVolumePath
+.SH DESCRIPTION
+lvcreate creates a new logical volume in a volume group ( see
+.B vgcreate(8), vgchange(8)
+) by allocating logical extents from the free physical extent pool
+of that volume group.  If there are not enough free physical extents then
+the volume group can be extended ( see
+.B vgextend(8)
+) with other physical volumes or by reducing existing logical volumes
+of this volume group in size ( see
+.B lvreduce(8)
+).
+.br
+The second form supports the creation of snapshot logical volumes which 
+keep the contents of the original logical volume for backup purposes.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-c, \-\-chunksize ChunkSize
+Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
+.TP
+.I \-C, \-\-contiguous y/n
+Sets or resets the contiguous allocation policy for
+logical volumes. Default is no contiguous allocation based
+on a next free principle.
+.TP
+.I \-i, \-\-stripes Stripes
+Gives the number of stripes.
+This is equal to the number of physical volumes to scatter
+the logical volume.
+.TP
+.I \-I, \-\-stripesize StripeSize
+Gives the number of kilobytes for the granularity of the stripes.
+.br
+StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
+For metadata in LVM2 format, the stripe size may be a larger
+power of 2 but must not exceed the physical extent size.
+.TP
+.I \-l, \-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}]
+Gives the number of logical extents to allocate for the new
+logical volume.
+This can also be expressed as a percentage of the total space
+in the Volume Group with the suffix %VG, of the remaining
+free space in the Volume Group with the suffix %FREE, or
+of the remaining free space for the specified PhysicalVolume(s)
+with the suffix %PVS,
+.TP
+.I \-L, \-\-size LogicalVolumeSize[kKmMgGtTpPeE]
+Gives the size to allocate for the new logical volume.
+A size suffix of K for kilobytes, M for megabytes,
+G for gigabytes, T for terabytes, P for petabytes
+or E for exabytes is optional.
+.br
+Default unit is megabytes.
+.TP
+.I \-\-minor minor
+Set the minor number.
+.TP
+.I \-M, \-\-persistent y/n
+Set to y to make the minor number specified persistent.
+.TP
+.I \-m, \-\-mirrors Mirrors
+Creates a mirrored logical volume with Mirrors copies.  For example,
+specifying "-m 1" would result in a mirror with two-sides; that is, a
+linear volume plus one copy.
+
+Specifying the optional argument --nosync will cause the creation
+of the mirror to skip the initial resynchronization.  Any data written
+afterwards will be mirrored, but the original contents will not be
+copied.  This is useful for skipping a potentially long and resource
+intensive initial sync of an empty device.
+
+The optional argument --mirrorlog specifies the type of log to be used.
+The default is disk, which is persistent and requires
+a small amount of storage space, usually on a separate device from the
+data being mirrored. Using core means the mirror is regenerated
+by copying the data from the first device again each time the
+device is activated, for example, after every reboot.
+
+The optional argument --corelog is equivalent to --mirrorlog core.
+
+.TP
+.I \-n, \-\-name LogicalVolumeName
+The name for the new logical volume.
+.br
+Without this option a default names of "lvol#" will be generated where
+# is the LVM internal number of the logical volume.
+.TP
+.I \-p, \-\-permission r/w
+Set access permissions to read only or read and write.
+.br
+Default is read and write.
+.TP
+.I \-r, \-\-readahead ReadAheadSectors|auto|none
+Set read ahead sector count of this logical volume.
+For volume groups with metadata in lvm1 format, this must
+be a value between 2 and 120.
+The default value is "auto" which allows the kernel to choose
+a suitable value automatically.
+"None" is equivalent to specifying zero.
+.TP
+.I \-R, \-\-regionsize MirrorLogRegionSize
+A mirror is divided into regions of this size (in MB), and the mirror log 
+uses this granularity to track which regions are in sync.
+.TP
+.I \-s, \-\-snapshot
+Create a snapshot logical volume (or snapshot) for an existing, so called
+original logical volume (or origin).
+Snapshots provide a 'frozen image' of the contents of the origin
+while the origin can still be updated. They enable consistent
+backups and online recovery of removed/overwritten data/files. The snapshot
+does not need the same amount of storage the origin has. In a typical scenario,
+15-20% might be enough. In case the snapshot runs out of storage, use
+.B lvextend(8)
+to grow it. Shrinking a snapshot is supported by
+.B lvreduce(8)
+as well. Run
+.B lvdisplay(8)
+on the snapshot in order to check how much data is allocated to it.
+.TP
+.I \-Z, \-\-zero y/n
+Controls zeroing of the first KB of data in the new logical volume.
+.br
+Default is yes.
+.br
+Volume will not be zeroed if read only flag is set.
+.br
+Snapshot volumes are zeroed always.
+
+.br
+Warning: trying to mount an unzeroed logical volume can cause the system to
+hang.
+.SH Examples
+"lvcreate -i 3 -I 8 -L 100M vg00" tries to create a striped logical
+volume with 3 stripes, a stripesize of 8KB and a size of 100MB in the volume
+group named vg00. The logical volume name will be chosen by lvcreate.
+
+"lvcreate -m1 -L 500M vg00" tries to create a mirror logical volume
+with 2 sides with a useable size of 500 MiB.  This operation would
+require 3 devices - two for the mirror devices and one for the disk
+log.
+
+"lvcreate -m1 --mirrorlog core -L 500M vg00" tries to create a mirror logical volume
+with 2 sides with a useable size of 500 MiB.  This operation would
+require 2 devices - the log is "in-memory".
+
+"lvcreate --size 100m --snapshot --name snap /dev/vg00/lvol1"
+.br
+creates a snapshot logical volume named /dev/vg00/snap which has access to the
+contents of the original logical volume named /dev/vg00/lvol1
+at snapshot logical volume creation time. If the original logical volume
+contains a file system, you can mount the snapshot logical volume on an
+arbitrary directory in order to access the contents of the filesystem to run
+a backup while the original filesystem continues to get updated.
+
+.SH SEE ALSO
+.BR lvm (8), 
+.BR vgcreate (8), 
+.BR lvremove (8), 
+.BR lvrename (8)
+.BR lvextend (8), 
+.BR lvreduce (8), 
+.BR lvdisplay (8), 
+.BR lvscan (8)
/cvs/lvm2/LVM2/man/lvdisplay.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvdisplay.8.in
+++ -	2008-10-08 12:50:15.079027000 +0000
@@ -0,0 +1,61 @@
+.TH LVDISPLAY 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvdisplay \- display attributes of a logical volume
+.SH SYNOPSIS
+.B lvdisplay
+[\-c/\-\-colon] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-\-ignorelockingfailure]
+[\-\-maps] [\-P/\-\-partial]
+[\-v/\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+.SH DESCRIPTION
+lvdisplay allows you to see the attributes of a logical volume
+like size, read/write status, snapshot information etc.
+.P
+\fBlvs\fP (8) is an alternative that provides the same information 
+in the style of \fBps\fP (1).  \fBlvs\fP is recommended over
+\fBlvdisplay\fP.
+
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-c, \-\-colon
+Generate colon separated output for easier parsing in scripts or programs.
+N.B. \fBlvs\fP (8) provides considerably more control over the output.
+.nf
+
+The values are:
+
+* logical volume name
+* volume group name
+* logical volume access
+* logical volume status
+* internal logical volume number
+* open count of logical volume
+* logical volume size in sectors
+* current logical extents associated to logical volume
+* allocated logical extents of logical volume
+* allocation policy of logical volume
+* read ahead sectors of logical volume
+* major device number of logical volume
+* minor device number of logical volume
+
+.fi
+.TP
+.I \-m, \-\-maps
+Display the mapping of logical extents to physical volumes and
+physical extents.
+.SH Examples
+"lvdisplay -v /dev/vg00/lvol2" shows attributes of that logical volume.
+If snapshot
+logical volumes have been created for this original logical volume,
+this command shows a list of all snapshot logical volumes and their
+status (active or inactive) as well.
+
+"lvdisplay /dev/vg00/snapshot" shows the attributes of this snapshot
+logical volume and also which original logical volume
+it is associated with.
+
+.SH SEE ALSO
+.BR lvm (8), 
+.BR lvcreate (8), 
+.BR lvscan (8)
/cvs/lvm2/LVM2/man/lvextend.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvextend.8.in
+++ -	2008-10-08 12:50:15.158226000 +0000
@@ -0,0 +1,69 @@
+.TH LVEXTEND 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvextend \- extend the size of a logical volume
+.SH SYNOPSIS
+.B lvextend
+[\-\-alloc AllocationPolicy]
+[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
+{\-l/\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
+\-L/\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
+[\-t/\-\-test]
+[\-v/\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
+.SH DESCRIPTION
+lvextend allows you to extend the size of a logical volume.
+Extension of snapshot logical volumes (see
+.B lvcreate(8)
+for information to create snapshots) is supported as well.
+But to change the number of copies in a mirrored logical
+volume use 
+.BR lvconvert (8).
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
+Extend or set the logical volume size in units of logical extents.
+With the + sign the value is added to the actual size
+of the logical volume and without it, the value is taken as an absolute one.
+The number can also be expressed as a percentage of the total space
+in the Volume Group with the suffix %VG, relative to the existing
+size of the Logical Volume with the suffix %LV, of the remaining
+free space for the specified PhysicalVolume(s) with the suffix %PVS,
+or as a percentage of the remaining free space in the Volume Group
+with the suffix %FREE.
+.TP
+.I \-L, \-\-size [+]LogicalVolumeSize[kKmMgGtTpPeE]
+Extend or set the logical volume size in units of megabytes.
+A size suffix of M for megabytes,
+G for gigabytes, T for terabytes, P for petabytes 
+or E for exabytes is optional.
+With the + sign the value is added to the actual size
+of the logical volume and without it, the value is taken as an absolute one.
+.TP
+.I \-i, \-\-stripes Stripes
+Gives the number of stripes for the extension.
+Not applicable to LVs using the original metadata LVM format, which must
+use a single value throughout.
+.TP
+.I \-I, \-\-stripesize StripeSize
+Gives the number of kilobytes for the granularity of the stripes.
+Not applicable to LVs using the original metadata LVM format, which must
+use a single value throughout.
+.br
+StripeSize must be 2^n (n = 2 to 9)
+.SH Examples
+"lvextend -L +54 /dev/vg01/lvol10 /dev/sdk3" tries to extend the size of
+that logical volume by 54MB on physical volume /dev/sdk3.
+This is only possible if /dev/sdk3 is a member of volume group vg01 and
+there are enough free physical extents in it.
+
+"lvextend /dev/vg01/lvol01 /dev/sdk3" tries to extend the size of that
+logical volume by the amount of free space on physical volume /dev/sdk3.
+This is equivalent to specifying "-l +100%PVS" on the command line.
+.SH SEE ALSO
+.BR lvm (8), 
+.BR lvcreate (8), 
+.BR lvconvert (8), 
+.BR lvreduce (8), 
+.BR lvresize (8), 
+.BR lvchange (8)
/cvs/lvm2/LVM2/man/lvm.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvm.8.in
+++ -	2008-10-08 12:50:15.238520000 +0000
@@ -0,0 +1,316 @@
+.TH LVM 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvm \- LVM2 tools
+.SH SYNOPSIS
+.B lvm
+[command | file]
+.SH DESCRIPTION
+\fBlvm\fP provides the command-line tools for LVM2.  A separate
+manual page describes each command in detail.
+.LP
+If \fBlvm\fP is invoked with no arguments it presents a readline prompt
+(assuming it was compiled with readline support).
+LVM commands may be entered interactively at this prompt with 
+readline facilities including history and command name and option 
+completion.  Refer to \fBreadline\fP(3) for details.
+.LP
+If \fBlvm\fP is invoked with argv[0] set to the name of a specific
+LVM command (for example by using a hard or soft link) it acts as 
+that command.  
+.LP
+Where commands take VG or LV names as arguments, the full path name is
+optional.  An LV called "lvol0" in a VG called "vg0" can be specified
+as "vg0/lvol0".  Where a list of VGs is required but is left empty, 
+a list of all VGs will be substituted.  Where a list of LVs is required
+but a VG is given, a list of all the LVs in that VG will be substituted.
+So "lvdisplay vg0" will display all the LVs in "vg0".
+Tags can also be used - see \fBaddtag\fP below.
+.LP
+One advantage of using the built-in shell is that configuration 
+information gets cached internally between commands.  
+.LP
+A file containing a simple script with one command per line 
+can also be given on the command line.  The script can also be
+executed directly if the first line is #! followed by the absolute
+path of \fBlvm\fP.
+.SH BUILT-IN COMMANDS
+The following commands are built into lvm without links normally
+being created in the filesystem for them.
+.TP
+\fBdumpconfig\fP \(em Display the configuration information after 
+loading \fBlvm.conf\fP (5) and any other configuration files.
+.TP
+\fBformats\fP \(em Display recognised metadata formats.
+.TP
+\fBhelp\fP \(em Display the help text.
+.TP
+\fBpvdata\fP \(em Not implemented in LVM2.
+.TP
+\fBsegtypes\fP \(em Display recognised logical volume segment types.
+.TP
+\fBversion\fP \(em Display version information.
+.LP
+.SH COMMANDS
+The following commands implement the core LVM functionality.
+.TP
+\fBpvchange\fP \(em Change attributes of a physical volume.
+.TP
+\fBpvck\fP \(em Check physical volume metadata.
+.TP
+\fBpvcreate\fP \(em Initialize a disk or partition for use by LVM.
+.TP
+\fBpvdisplay\fP \(em Display attributes of a physical volume.
+.TP
+\fBpvmove\fP \(em Move physical extents.
+.TP
+\fBpvremove\fP \(em Remove a physical volume.
+.TP
+\fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
+.TP
+\fBpvs\fP \(em Report information about physical volumes.
+.TP
+\fBpvscan\fP \(em Scan all disks for physical volumes.
+.TP
+\fBvgcfgbackup\fP \(em Backup volume group descriptor area.
+.TP
+\fBvgcfgrestore\fP \(em Restore volume group descriptor area.
+.TP
+\fBvgchange\fP \(em Change attributes of a volume group.
+.TP
+\fBvgck\fP \(em Check volume group metadata.
+.TP
+\fBvgconvert\fP \(em Convert volume group metadata format.
+.TP
+\fBvgcreate\fP \(em Create a volume group.
+.TP
+\fBvgdisplay\fP \(em Display attributes of volume groups.
+.TP
+\fBvgexport\fP \(em Make volume groups unknown to the system.
+.TP
+\fBvgextend\fP \(em Add physical volumes to a volume group.
+.TP
+\fBvgimport\fP \(em Make exported volume groups known to the system.
+.TP
+\fBvgmerge\fP \(em Merge two volume groups.
+.TP
+\fBvgmknodes\fP \(em Recreate volume group directory and logical volume special files
+.TP
+\fBvgreduce\fP \(em Reduce a volume group by removing one or more physical volumes.
+.TP
+\fBvgremove\fP \(em Remove a volume group.
+.TP
+\fBvgrename\fP \(em Rename a volume group.
+.TP
+\fBvgs\fP \(em Report information about volume groups.
+.TP
+\fBvgscan\fP \(em Scan all disks for volume groups and rebuild caches.
+.TP
+\fBvgsplit\fP \(em Split a volume group into two, moving any logical volumes from one volume group to another by moving entire physical volumes.
+.TP
+\fBlvchange\fP \(em Change attributes of a logical volume.
+.TP
+\fBlvconvert\fP \(em Convert a logical volume from linear to mirror or snapshot.
+.TP
+\fBlvcreate\fP \(em Create a logical volume in an existing volume group.
+.TP
+\fBlvdisplay\fP \(em Display attributes of a logical volume.
+.TP
+\fBlvextend\fP \(em Extend the size of a logical volume.
+.TP
+\fBlvmchange\fP \(em Change attributes of the logical volume manager.
+.TP
+\fBlvmdiskscan\fP \(em Scan for all devices visible to LVM2.
+.TP
+\fBlvmdump\fP \(em Create lvm2 information dumps for diagnostic purposes.
+.TP
+\fBlvreduce\fP \(em Reduce the size of a logical volume.
+.TP
+\fBlvremove\fP \(em Remove a logical volume.
+.TP
+\fBlvrename\fP \(em Rename a logical volume.
+.TP
+\fBlvresize\fP \(em Resize a logical volume.
+.TP
+\fBlvs\fP \(em Report information about logical volumes.
+.TP
+\fBlvscan\fP \(em Scan (all disks) for logical volumes.
+.TP
+The following commands are not implemented in LVM2 but might be in the future: lvmsadc, lvmsar, pvdata.
+.SH OPTIONS
+The following options are available for many of the commands. 
+They are implemented generically and documented here rather 
+than repeated on individual manual pages.
+.TP
+\fB-h | --help\fP \(em Display the help text.
+.TP
+\fB--version\fP \(em Display version information.
+.TP
+\fB-v | --verbose\fP \(em Set verbose level.
+Repeat from 1 to 3 times to increase the detail of messages 
+sent to stdout and stderr.  Overrides config file setting.
+.TP
+\fB-d | --debug\fP \(em Set debug level.
+Repeat from 1 to 6 times to increase the detail of messages sent 
+to the log file and/or syslog (if configured).
+Overrides config file setting.
+.TP
+\fB--quiet\fP \(em Suppress output and log messages.
+Overrides -d and -v.
+.TP
+\fB-t | --test\fP \(em Run in test mode.
+Commands will not update metadata.
+This is implemented by disabling all metadata writing but nevertheless
+returning success to the calling function.  This may lead to unusual
+error messages in multi-stage operations if a tool relies on reading
+back metadata it believes has changed but hasn't.
+.TP
+\fB--driverloaded\fP { \fBy\fP | \fBn\fP }
+Whether or not the device-mapper kernel driver is loaded.
+If you set this to \fBn\fP, no attempt will be made to contact the driver.
+.TP
+\fB-A | --autobackup\fP { \fBy\fP | \fBn\fP }
+Whether or not to metadata should be backed up automatically after a change.  
+You are strongly advised not to disable this!
+See
+.B vgcfgbackup (8).
+.TP
+\fB-P | --partial\fP
+When set, the tools will do their best to provide access to volume groups
+that are only partially available.  Where part of a logical volume is 
+missing, \fB/dev/ioerror\fP will be substituted, and you could use
+\fBdmsetup (8)\fP to set this up to return I/O errors when accessed,
+or create it as a large block device of nulls.  Metadata may not be
+changed with this option. To insert a replacement physical volume
+of the same or large size use \fBpvcreate -u\fP to set the uuid to 
+match the original followed by \fBvgcfgrestore (8)\fP.
+.TP
+\fB-M | --metadatatype type\fP
+Specifies which type of on-disk metadata to use, such as \fBlvm1\fP 
+or \fBlvm2\fP, which can be abbreviated to \fB1\fP or \fB2\fP respectively.
+The default (lvm2) can be changed by setting \fBformat\fP in the \fBglobal\fP
+section of the config file.
+.TP
+\fB--ignorelockingfailure\fP
+This lets you proceed with read-only metadata operations such as
+\fBlvchange -ay\fP and \fBvgchange -ay\fP even if the locking module fails.
+One use for this is in a system init script if the lock directory 
+is mounted read-only when the script runs.
+.TP
+\fB--addtag tag\fP
+Add the tag \fBtag\fP to a PV, VG or LV.  
+A tag is a word that can be used to group LVM2 objects of the same type 
+together. 
+Tags can be given on the command line in place of PV, VG or LV 
+arguments.  Tags should be prefixed with @ to avoid ambiguity.
+Each tag is expanded by replacing it with all objects possessing
+that tag which are of the type expected by its position on the command line.
+PVs can only possess tags while they are part of a Volume Group:
+PV tags are discarded if the PV is removed from the VG.
+As an example, you could tag some LVs as \fBdatabase\fP and others 
+as \fBuserdata\fP and then activate the database ones 
+with \fBlvchange -ay @database\fP.
+Objects can possess multiple tags simultaneously.
+Only the new LVM2 metadata format supports tagging: objects using the
+LVM1 metadata format cannot be tagged because the on-disk format does not
+support it.
+Snapshots cannot be tagged.
+Characters allowed in tags are: A-Z a-z 0-9 _ + . -
+.TP
+\fB--deltag tag\fP
+Delete the tag \fBtag\fP from a PV, VG or LV, if it's present.
+.TP
+\fB--alloc AllocationPolicy\fP
+The allocation policy to use: \fBcontiguous\fP, \fBcling\fP, \fBnormal\fP, \fBanywhere\fP or \fBinherit\fP.
+When a command needs to allocate physical extents from the volume group,
+the allocation policy controls how they are chosen.  
+Each volume group and logical volume has an allocation policy.
+The default for a volume group is \fBnormal\fP which applies
+common-sense rules such as not placing parallel stripes on the same
+physical volume.  The default for a logical volume is \fBinherit\fP
+which applies the same policy as for the volume group.  These policies can
+be changed using \fBlvchange\fP (8) and \fBvgchange\fP (8) or over-ridden
+on the command line of any command that performs allocation.
+The \fBcontiguous\fP policy requires that new extents be placed adjacent
+to existing extents. 
+The \fBcling\fP policy places new extents on the same physical
+volume as existing extents in the same stripe of the Logical Volume.
+If there are sufficient free extents to satisfy
+an allocation request but \fBnormal\fP doesn't use them,
+\fBanywhere\fP will - even if that reduces performance by
+placing two stripes on the same physical volume.
+.IP
+N.B. The policies described above are not implemented fully yet.
+In particular, contiguous free space cannot be broken up to
+satisfy allocation attempts.
+.SH ENVIRONMENT VARIABLES
+.TP
+\fBLVM_SYSTEM_DIR\fP 
+Directory containing lvm.conf and other LVM
+system files.
+Defaults to "/etc/lvm".
+.TP
+\fBHOME\fP 
+Directory containing .lvm_history if the internal readline shell
+is invoked.
+.TP
+\fBLVM_VG_NAME\fP 
+The volume group name that is assumed for 
+any reference to a logical volume that doesn't specify a path.
+Not set by default.
+.SH VALID NAMES
+The following characters are valid for VG and LV names:
+\fBa-z A-Z 0-9 + _ . -\fP
+.LP
+VG and LV names cannot begin with a hyphen.
+There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
+A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
+A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain the strings '_mlog' or '_mimage'
+
+
+.SH DIAGNOSTICS
+All tools return a status code of zero on success or non-zero on failure.
+.SH FILES
+.I /etc/lvm/lvm.conf
+.br
+.I $HOME/.lvm_history
+.SH SEE ALSO
+.BR clvmd (8),
+.BR lvchange (8),
+.BR lvcreate (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvmchange (8),
+.BR lvmdiskscan (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvs (8),
+.BR pvscan (8),
+.BR vgcfgbackup (8),
+.BR vgchange  (8),
+.BR vgck (8),
+.BR vgconvert (8),
+.BR vgcreate (8),
+.BR vgdisplay (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
+.BR readline (3),
+.BR lvm.conf (5)
+
/cvs/lvm2/LVM2/man/lvm.conf.5.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvm.conf.5.in
+++ -	2008-10-08 12:50:15.322501000 +0000
@@ -0,0 +1,395 @@
+.TH LVM.CONF 5 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvm.conf \- Configuration file for LVM2
+.SH SYNOPSIS
+.B /etc/lvm/lvm.conf
+.SH DESCRIPTION
+lvm.conf is loaded during the initialisation phase of 
+\fBlvm\fP (8).  This file can in turn lead to other files
+being loaded - settings read in later override earlier
+settings.  File timestamps are checked between commands and if 
+any have changed, all the files are reloaded.  
+.LP
+Use \fBlvm dumpconfig\fP to check what settings are in use.
+.SH SYNTAX
+.LP
+This section describes the configuration file syntax.
+.LP
+Whitespace is not significant unless it is within quotes. 
+This provides a wide choice of acceptable indentation styles.
+Comments begin with # and continue to the end of the line.
+They are treated as whitespace.
+.LP
+Here is an informal grammar:
+.TP
+\fBfile = value*\fP
+.br
+A configuration file consists of a set of values.
+.TP
+\fBvalue = section | assignment\fP
+.br
+A value can either be a new section, or an assignment.
+.TP
+\fBsection = identifier '{' value* '}'\fP
+.br
+A section is groups associated values together.  
+.br
+It is denoted by a name and delimited by curly brackets.
+.br
+e.g.	backup {
+.br
+		...
+.br
+	}
+.TP
+\fBassignment = identifier '=' (array | type)\fP
+.br
+An assignment associates a type with an identifier.
+.br
+e.g.	max_archives = 42
+.br
+.TP
+\fBarray = '[' (type ',')* type ']' | '[' ']'\fP
+.br
+Inhomogeneous arrays are supported. 
+.br
+Elements must be separated by commas.  
+.br
+An empty array is acceptable.
+.TP
+\fBtype = integer | float | string\fP
+\fBinteger = [0-9]*\fP
+.br
+\fBfloat = [0-9]*\.[0-9]*\fP
+.br
+\fBstring = '"' .* '"'\fP
+.IP
+Strings must be enclosed in double quotes.
+
+.SH SECTIONS
+.LP
+The sections that may be present in the file are:
+.TP
+\fBdevices\fP \(em Device settings
+.IP
+\fBdir\fP \(em Directory in which to create volume group device nodes.
+Defaults to "/dev".  Commands also accept this as a prefix on volume 
+group names.
+.IP
+\fBscan\fP \(em List of directories to scan recursively for 
+LVM physical volumes.
+Devices in directories outside this hierarchy will be ignored.
+Defaults to "/dev".
+.IP
+\fBpreferred_names\fP \(em List of patterns compared in turn against
+all the pathnames referencing the same device in in the scanned directories.
+The pathname that matches the earliest pattern in the list is the
+one used in any output.  As an example, if device-mapper multipathing
+is used, the following will select multipath device names:
+.br
+\fBdevices { preferred_names = [ "^/dev/mapper/mpath" ] }\fP
+.IP
+\fBfilter\fP \(em List of patterns to apply to devices found by a scan.
+Patterns are regular expressions delimited by any character and preceded
+by \fBa\fP (for accept) or \fBr\fP (for reject).  The list is traversed
+in order, and the first regex that matches determines if the device
+will be accepted or rejected (ignored).  Devices that don't match
+any patterns are accepted. If you want to reject patterns that
+don't match, end the list with "r/.*/".
+If there are several names for the same device (e.g. symbolic links
+in /dev), if any name matches any \fBa\fP pattern, the
+device is accepted; otherwise if any name matches any \fBr\fP
+pattern it is rejected; otherwise it is accepted.
+As an example, to ignore /dev/cdrom you could use:
+.br
+\fBdevices { filter=["r|cdrom|"] }\fP 
+.IP
+\fBcache_dir\fP \(em Persistent filter cache file directory.
+Defaults to "/etc/lvm/cache".
+.IP
+\fBwrite_cache_state\fP \(em Set to 0 to disable the writing out of the 
+persistent filter cache file when \fBlvm\fP exits.
+Defaults to 1.
+.IP
+\fBtypes\fP \(em List of pairs of additional acceptable block device types
+found in /proc/devices together with maximum (non-zero) number of
+partitions (normally 16).  By default, LVM2 supports ide, sd, md, loop, 
+dasd, dac960, nbd, ida, cciss, ubd, ataraid, drbd, power2, i2o_block
+and iseries/vd.  Block devices with major
+numbers of different types are ignored by LVM2.  
+Example: \fBtypes = ["fd", 16]\fP.
+To create physical volumes on device-mapper volumes
+created outside LVM2, perhaps encrypted ones from \fBcryptsetup\fP,
+you'll need \fBtypes = ["device-mapper", 16]\fP.  But if you do this,
+be careful to avoid recursion within LVM2.  The figure for number 
+of partitions is not currently used in LVM2 - and might never be.
+.IP
+\fBsysfs_scan\fP (em If set to 1 and your kernel supports sysfs and 
+it is mounted, sysfs will be used as a quick way of filtering out
+block devices that are not present.
+.IP
+\fBmd_component_detection\fP (em If set to 1, LVM2 will ignore devices
+used as components of software RAID (md) devices by looking for md
+superblocks. This doesn't always work satisfactorily e.g. if a device 
+has been reused without wiping the md superblocks first.
+.TP
+\fBlog\fP \(em Default log settings
+.IP
+\fBfile\fP \(em Location of log file.  If this entry is not present, no
+log file is written.
+.IP
+\fBoverwrite\fP \(em Set to 1 to overwrite the log file each time a tool
+is invoked.  By default tools append messages to the log file.
+.IP
+\fBlevel\fP \(em Log level (0-9) of messages to write to the file.
+9 is the most verbose; 0 should produce no output.
+.IP
+\fBverbose\fP \(em Default level (0-3) of messages sent to stdout or stderr.
+3 is the most verbose; 0 should produce the least output.
+.IP
+\fBsyslog\fP \(em Set to 1 (the default) to send log messages through syslog.
+Turn off by setting to 0.  If you set to an integer greater than one,
+this is used - unvalidated - as the facility.  The default is LOG_USER.  
+See /usr/include/sys/syslog.h for safe facility values to use.
+For example, LOG_LOCAL0 might be 128.
+.IP
+\fBindent\fP \(em When set to 1 (the default) messages are indented 
+according to their severity, two spaces per level.  
+Set to 0 to turn off indentation.
+.IP
+\fBcommand_names\fP \(em When set to 1, the command name is used as a
+prefix for each message.
+Default is 0 (off).
+.IP
+\fBprefix\fP \(em Prefix used for all messages (after the command name).
+Default is two spaces.
+.IP
+\fBactivation\fP \(em Set to 1 to log messages while
+devices are suspended during activation.  
+Only set this temporarily while debugging a problem because
+in low memory situations this setting can cause your machine to lock up.
+.TP
+\fBbackup\fP \(em Configuration for metadata backups.
+.IP
+\fBarchive_dir\fP \(em Directory used for automatic metadata archives.
+Backup copies of former metadata for each volume group are archived here.
+Defaults to "/etc/lvm/archive".
+.IP
+\fBbackup_dir\fP \(em Directory used for automatic metadata backups.
+A single backup copy of the current metadata for each volume group 
+is stored here.
+Defaults to "/etc/lvm/backup".
+.IP
+\fBarchive\fP \(em Whether or not tools automatically archive existing
+metadata into \fBarchive_dir\fP before making changes to it.
+Default is 1 (automatic archives enabled).  
+Set to 0 to disable.  
+Disabling this might make metadata recovery difficult or impossible 
+if something goes wrong.
+.IP
+\fBbackup\fP \(em Whether or not tools make an automatic backup 
+into \fBbackup_dir\fP after changing metadata.  
+Default is 1 (automatic backups enabled).  Set to 0 to disable.
+Disabling this might make metadata recovery difficult or impossible 
+if something goes wrong.
+.IP
+\fBretain_min\fP \(em Minimum number of archives to keep.
+Defaults to 10.
+.IP
+\fBretain_days\fP \(em Minimum number of days to keep archive files.
+Defaults to 30.
+.TP
+\fBshell\fP \(em LVM2 built-in readline shell settings
+.IP
+\fBhistory_size\fP \(em Maximum number of lines of shell history to retain (default 100) in $HOME/.lvm_history
+.TP
+\fBglobal\fP \(em Global settings
+.IP
+\fBtest\fP \(em If set to 1, run tools in test mode i.e. no changes to
+the on-disk metadata will get made.  It's equivalent to having the
+-t option on every command.
+.IP
+\fBactivation\fP \(em Set to 0 to turn off all communication with
+the device-mapper driver.  Useful if you want to manipulate logical
+volumes while device-mapper is not present in your kernel.
+.IP
+\fBproc\fP \(em Mount point of proc filesystem.
+Defaults to /proc.
+.IP
+\fBumask\fP \(em File creation mask for any files and directories created.
+Interpreted as octal if the first digit is zero.
+Defaults to 077.  
+Use 022 to allow other users to read the files by default.
+.IP
+\fBformat\fP \(em The default value of \fB--metadatatype\fP used
+to determine which format of metadata to use when creating new 
+physical volumes and volume groups. \fBlvm1\fP or \fBlvm2\fP.
+.IP
+\fBfallback_to_lvm1\fP \(em Set this to 1 if you need to 
+be able to switch between 2.4 kernels using LVM1 and kernels
+including device-mapper.
+The LVM2 tools should be installed as normal and
+the LVM1 tools should be installed with a .lvm1 suffix e.g.
+vgscan.lvm1.  
+If an LVM2 tool is then run but unable to communicate
+with device-mapper, it will automatically invoke the equivalent LVM1 
+version of the tool.  Note that for LVM1 tools to 
+manipulate physical volumes and volume groups created by LVM2 you 
+must use \fB--metadataformat lvm1\fP when creating them.
+.IP
+\fBlibrary_dir\fP \(em A directory searched for LVM2's shared libraries
+ahead of the places \fBdlopen\fP (3) searches.
+.IP
+\fBformat_libraries\fP \(em A list of shared libraries to load that contain
+code to process different formats of metadata. For example, liblvm2formatpool.so
+is needed to read GFS pool metadata if LVM2 was configured \fB--with-pool=shared\fP.
+.IP
+\fBlocking_type\fP \(em What type of locking to use.
+1 is the default, which use flocks on files in \fBlocking_dir\fP
+(see below) to
+avoid conflicting LVM2 commands running concurrently on a single
+machine. 0 disables locking and risks corrupting your metadata.
+If set to 2, the tools will load the external \fBlocking_library\fP
+(see below).
+If the tools were configured \fB--with-cluster=internal\fP 
+(the default) then 3 means to use built-in cluster-wide locking.
+All changes to logical volumes and their states are communicated
+using locks.
+.IP
+\fBlocking_dir\fP \(em The directory LVM2 places its file locks
+if \fBlocking_type\fP is set to 1.  The default is \fB/var/lock/lvm\fP.
+.IP
+\fBlocking_library\fP \(em The name of the external locking
+library to load if \fBlocking_type\fP is set to 2.
+The default is \fBliblvm2clusterlock.so\fP.  If you need to write
+such a library, look at the lib/locking source code directory.
+.TP
+\fBtags\fP \(em Host tag settings
+.IP
+\fBhosttags\fP \(em If set to 1, create a host tag with the machine name.
+Setting this to 0 does nothing, neither creating nor destroying any tag.
+The machine name used is the nodename as returned by \fBuname\fP (2).
+.IP
+Additional host tags to be set can be listed here as subsections. 
+The @ prefix for tags is optional.
+Each of these host tag subsections can contain a \fBhost_list\fP 
+array of host names. If any one of these entries matches the machine 
+name exactly then the host tag gets defined on this particular host, 
+otherwise it doesn't.
+.IP
+After lvm.conf has been processed, LVM2 works through each host
+tag that has been defined in turn, and if there is a configuration
+file called lvm_\fB<host_tag>\fP.conf it attempts to load it.
+Any settings read in override settings found in earlier files.
+Any additional host tags defined get appended to the search list,
+so in turn they can lead to further configuration files being processed.
+Use \fBlvm dumpconfig\fP to check the result of config
+file processing.
+.IP
+The following example always sets host tags \fBtag1\fP and
+sets \fBtag2\fP on machines fs1 and fs2:
+.IP
+tags { tag1 { } tag2 { host_list = [ "fs1", "fs2" ] } }
+.IP
+These options are useful if you are replicating configuration files
+around a cluster.  Use of \fBhosttags = 1\fP means every machine
+can have static and identical local configuration files yet use 
+different settings and activate different logical volumes by
+default.  See also \fBvolume_list\fP below and \fB--addtag\fP 
+in \fBlvm\fP (8).
+.TP
+\fBactivation\fP \(em Settings affecting device-mapper activation
+.IP
+\fBmissing_stripe_filler\fP \(em When activating an incomplete logical
+volume in partial mode, this option dictates how the missing data is
+replaced.  A value of "error" will cause activation to create error
+mappings for the missing data, meaning that read access to missing
+portions of the volume will result in I/O errors. You can instead also
+use a device path, and in that case this device will be used in place of
+missing stripes. However, note that using anything other than
+"error" with mirrored or snapshotted volumes is likely to result in data
+corruption.  For instructions on how to create a device that always
+returns zeros, see \fBlvcreate\fP (8).
+.IP
+\fBmirror_region_size\fP \(em Unit size in KB for copy operations
+when mirroring.
+.IP
+\fBreadahead\fP \(em Used when there is no readahead value stored 
+in the volume group metadata.  Set to \fBnone\fP to disable
+readahead in these circumstances or \fBauto\fP to use the default
+value chosen by the kernel.
+.IP
+\fBreserved_memory\fP, \fBreserved_stack\fP \(em How many KB to reserve 
+for LVM2 to use while logical volumes are suspended.  If insufficient 
+memory is reserved before suspension, there is a risk of machine deadlock.
+.IP
+\fBprocess_priority\fP \(em The nice value to use while devices are
+suspended.  This is set to a high priority so that logical volumes
+are suspended (with I/O generated by other processes to those
+logical volumes getting queued) for the shortest possible time.
+.IP
+\fBvolume_list\fP \(em This acts as a filter through which
+all requests to activate a logical volume on this machine
+are passed.  A logical volume is only activated if it matches
+an item in the list.  Tags must be preceded by @ and are checked
+against all tags defined in the logical volume and volume group 
+metadata for a match.
+@* is short-hand to check every tag set on the host machine (see
+\fBtags\fP above).
+Logical volume and volume groups can also be included in the list
+by name e.g. vg00, vg00/lvol1.
+.TP
+\fBmetadata\fP \(em Advanced metadata settings
+.IP
+\fBpvmetadatacopies\fP \(em When creating a physical volume using the
+LVM2 metadata format, this is the default number of copies of metadata
+to store on each physical volume.  
+Currently it can be set to 0, 1 or 2.  The default is 1.  
+If set to 2, one copy is placed at the beginning of the disk
+and the other is placed at the end.
+It can be overridden on the command line with \fB--metadatacopies\fP.
+If creating a volume group with just one physical volume, it's a
+good idea to have 2 copies.  If creating a large volume group with
+many physical volumes, you may decide that 3 copies of the metadata
+is sufficient, i.e. setting it to 1 on three of the physical volumes,
+and 0 on the rest.  Every volume group must contain at least one 
+physical volume with at least 1 copy of the metadata (unless using
+the text files described below).  The disadvantage of having lots
+of copies is that every time the tools access the volume group, every
+copy of the metadata has to be accessed, and this slows down the
+tools.
+.IP
+\fBpvmetadatasize\fP \(em Approximate number of sectors to set aside
+for each copy of the metadata. Volume groups with large numbers of
+physical or logical volumes, or volumes groups containing complex 
+logical volume structures will need additional space for their metadata.
+The metadata areas are treated as circular buffers, so
+unused space becomes filled with an archive of the most recent
+previous versions of the metadata.
+.IP
+\fBdirs\fP \(em List of directories holding live copies of LVM2
+metadata as text files.  These directories must not be on logical
+volumes.  It is possible to use LVM2 with a couple of directories
+here, preferably on different (non-logical-volume) filesystems
+and with no other on-disk metadata, \fBpvmetadatacopies = 0\fP.
+Alternatively these directories can be in addition to the
+on-disk metadata areas.  This feature was created during the
+development of the LVM2 metadata before the new on-disk metadata
+areas were designed and no longer gets tested.  
+It is not supported under low-memory conditions, and it is 
+important never to edit these metadata files unless you fully 
+understand how things work: to make changes you should always use 
+the tools as normal, or else vgcfgbackup, edit backup, vgcfgrestore.
+.SH FILES
+.I /etc/lvm/lvm.conf
+.I /etc/lvm/archive
+.I /etc/lvm/backup
+.I /etc/lvm/cache/.cache
+.I /var/lock/lvm
+.SH SEE ALSO
+.BR lvm (8),
+.BR umask (2),
+.BR uname (2),
+.BR dlopen (3),
+.BR syslog (3),
+.BR syslog.conf (5)
/cvs/lvm2/LVM2/man/lvmchange.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvmchange.8.in
+++ -	2008-10-08 12:50:15.408136000 +0000
@@ -0,0 +1,10 @@
+.TH LVMCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvmchange \- change attributes of the logical volume manager
+.SH SYNOPSIS
+.B lvmchange
+.SH DESCRIPTION
+lvmchange is not currently supported under LVM2, although
+\fBdmsetup (8)\fP has a \fBremove_all\fP command.
+.SH SEE ALSO
+.BR dmsetup (8)
/cvs/lvm2/LVM2/man/lvmdiskscan.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvmdiskscan.8.in
+++ -	2008-10-08 12:50:15.486810000 +0000
@@ -0,0 +1,24 @@
+.TH LVMDISKSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvmdiskscan \- scan for all devices visible to LVM2
+.SH SYNOPSIS
+.B lvmdiskscan
+[\-d/\-\-debug] [\-h/\-?/\-\-help] 
+[\-l/\-\-lvmpartition]
+[\-v/\-\-verbose]
+.SH DESCRIPTION
+\fBlvmdiskscan\fP scans all SCSI, (E)IDE disks, multiple devices and a bunch
+of other block devices in the system looking for LVM physical volumes.
+The size reported is the real device size.
+Define a filter in \fBlvm.conf\fP(5) to restrict 
+the scan to avoid a CD ROM, for example.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-l, \-\-lvmpartition
+Only reports Physical Volumes.
+.SH SEE ALSO
+.BR lvm (8), 
+.BR lvm.conf (5),
+.BR pvscan (8),
+.BR vgscan (8)
/cvs/lvm2/LVM2/man/lvmdump.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvmdump.8.in
+++ -	2008-10-08 12:50:15.568339000 +0000
@@ -0,0 +1,50 @@
+.TH LVMDUMP 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.SH NAME
+lvmdump - create lvm2 information dumps for diagnostic purposes
+.SH SYNOPSIS
+\fBlvmdump\fP [options] [-d directory]
+.SH DESCRIPTION
+\fBlvmdump\fP is a tool to dump various information concerning LVM2. By default, it creates a tarball suitable for submission along with a problem report.
+.PP
+The content of the tarball is as follows:
+.br
+- dmsetup info
+.br
+- table of currently running processes
+.br
+- recent entries from /var/log/messages (containing system messages)
+.br
+- complete lvm configuration and cache
+.br
+- list of device nodes present under /dev
+.br
+- if enabled with -m, metadata dump will be also included
+.br
+- if enabled with -a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
+.br
+- if enabled with -c, cluster status info
+.SH OPTIONS
+.TP
+\fB\-h\fR \(em print help message
+.TP
+\fB\-a\fR \(em advanced collection 
+\fBWARNING\fR: if lvm is already hung, then this script may hang as well if \fB\-a\fR is used
+.TP
+\fB\-m\fR \(em gather LVM metadata from the PVs
+This option generates a 1:1 dump of the metadata area from all PVs visible to the system, which can cause the dump to increase in size considerably. However, the metadata dump may represent a valuable diagnostic resource.
+.TP
+\fB\-d\fR directory \(em dump into a directory instead of tarball
+By default, lvmdump will produce a single compressed tarball containing all the information. Using this option, it can be instructed to only produce the raw dump tree, rooted in \fBdirectory\fP.
+.TP
+\fB\-c\fR \(em if clvmd is running, gather cluster data as well
+.SH ENVIRONMENT VARIABLES
+.TP
+\fBLVM_BINARY\fP 
+The LVM2 binary to use.
+Defaults to "lvm".
+Sometimes you might need to set this to "/sbin/lvm.static", for example.
+.TP
+\fBDMSETUP_BINARY\fP 
+The dmsetup binary to use.
+Defaults to "dmsetup".
+.PP
/cvs/lvm2/LVM2/man/lvreduce.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvreduce.8.in
+++ -	2008-10-08 12:50:15.647763000 +0000
@@ -0,0 +1,67 @@
+.TH LVREDUCE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvreduce \- reduce the size of a logical volume
+.SH SYNOPSIS
+.B lvreduce
+[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-f/\-\-force]
+[\-h/\-?/\-\-help]
+{\-l/\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}] |
+\-L/\-\-size [\-]LogicalVolumeSize[kKmMgGtT]}
+[\-t/\-\-test]
+[\-v/\-\-verbose] LogicalVolume[Path]
+.SH DESCRIPTION
+lvreduce allows you to reduce the size of a logical volume.
+Be careful when reducing a logical volume's size, because data in the
+reduced part is lost!!! 
+.br 
+You should therefore ensure that any filesystem on the volume is 
+resized
+.I before
+running lvreduce so that the extents that are to be removed are not in use.
+.br
+Shrinking snapshot logical volumes (see
+.B lvcreate(8)
+for information to create snapshots) is supported as well.
+But to change the number of copies in a mirrored logical
+volume use 
+.B lvconvert (8).
+.br
+Sizes will be rounded if necessary - for example, the volume size must
+be an exact number of extents and the size of a striped segment must
+be a multiple of the number of stripes.
+.br
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-f, \-\-force
+Force size reduction without any question.
+.TP
+.I \-l, \-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}]
+Reduce or set the logical volume size in units of logical extents.
+With the - sign the value will be subtracted from
+the logical volume's actual size and without it the will be taken as
+an absolute size.
+The number can also be expressed as a percentage of the total space
+in the Volume Group with the suffix %VG or relative to the existing
+size of the Logical Volume with the suffix %LV or as a percentage of the remaining
+free space in the Volume Group with the suffix %FREE.
+.TP
+.I \-L, \-\-size [\-]LogicalVolumeSize[kKmMgGtTpPeE]
+Reduce or set the logical volume size in units of megabyte by default.
+A size suffix of k for kilobyte, m for megabyte, 
+g for gigabytes, t for terabytes, p for petabytes 
+or e for exabytes is optional.
+With the - sign the value will be subtracted from
+the logical volume's actual size and without it it will be taken as
+an absolute size.
+.SH Example
+"lvreduce -l -3 vg00/lvol1" reduces the size of logical volume lvol1
+in volume group vg00 by 3 logical extents.
+.SH SEE ALSO
+.BR lvchange (8),
+.BR lvconvert (8), 
+.BR lvcreate (8), 
+.BR lvextend (8), 
+.BR lvm (8), 
+.BR lvresize (8),
+.BR vgreduce (8)
/cvs/lvm2/LVM2/man/lvremove.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvremove.8.in
+++ -	2008-10-08 12:50:15.728022000 +0000
@@ -0,0 +1,40 @@
+.TH LVREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvremove \- remove a logical volume
+.SH SYNOPSIS
+.B lvremove
+[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-f/\-\-force]
+[\-h/\-?/\-\-help] 
+[\-t/\-\-test]
+[\-v/\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+.SH DESCRIPTION
+\fBlvremove\fP removes one or more logical volumes.
+Confirmation will be requested before deactivating any active logical
+volume prior to removal.  Logical volumes cannot be deactivated
+or removed while they are open (e.g. if they contain a mounted filesystem).
+.sp
+If the logical volume is clustered then it must be deactivated on all
+nodes in the cluster before it can be removed. A single lvchange command
+issued from one node can do this.
+.SH OPTIONS
+See \fBlvm\fP(8) for common options.
+.TP
+.I \-f, \-\-force
+Remove active logical volumes without confirmation.
+.SH EXAMPLES
+Remove the active logical volume lvol1 in volume group vg00 
+without asking for confirmation:
+.sp
+\	\fBlvremove -f vg00/lvol1\fP
+.sp
+Remove all logical volumes in volume group vg00:
+.sp
+\	\fBlvremove vg00\fP
+.SH SEE ALSO
+.BR lvcreate (8), 
+.BR lvdisplay (8),
+.BR lvchange (8),  
+.BR lvm (8), 
+.BR lvs (8),
+.BR lvscan (8),
+.BR vgremove (8)
/cvs/lvm2/LVM2/man/lvrename.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvrename.8.in
+++ -	2008-10-08 12:50:15.807076000 +0000
@@ -0,0 +1,47 @@
+.TH LVRENAME 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvrename \- rename a logical volume
+.SH SYNOPSIS
+.B lvrename
+.RB [ \-A | \-\-autobackup " {" y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-f | \-\-force ]
+.RB [ \-h | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.TP
+.IR "OldLogicalVolumePath NewLogicalVolume" { Path | Name }
+.TP
+.I VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName
+.SH DESCRIPTION
+.B lvrename
+renames an existing logical volume from
+.IR OldLogicalVolume { Name | Path }
+to
+.IR NewLogicalVolume { Name | Path }.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH EXAMPLE
+To rename
+.B lvold
+in volume group
+.B vg02
+to
+.BR lvnew :
+.nf
+
+\	lvrename /dev/vg02/lvold /dev/vg02/lvnew
+
+.fi
+An alternate syntax to rename this logical volume is
+.nf
+
+\	lvrename vg02 lvold lvnew
+
+.fi
+.SH SEE ALSO
+.BR lvm (8), 
+.BR lvchange (8),
+.BR vgcreate (8), 
+.BR vgrename (8)
/cvs/lvm2/LVM2/man/lvresize.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvresize.8.in
+++ -	2008-10-08 12:50:15.887062000 +0000
@@ -0,0 +1,66 @@
+.TH LVRESIZE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvresize \- resize a logical volume
+.SH SYNOPSIS
+.B lvresize
+[\-\-alloc AllocationPolicy]
+[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
+{\-l/\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
+\-L/\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
+[\-t/\-\-test]
+[\-v/\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
+.SH DESCRIPTION
+lvresize allows you to resize a logical volume.
+Be careful when reducing a logical volume's size, because data in the reduced
+part is lost!!!
+You should therefore ensure that any filesystem on the volume is
+shrunk first so that the extents that are to be removed are not in use.
+Resizing snapshot logical volumes (see
+.B lvcreate(8)
+for information about creating snapshots) is supported as well.
+But to change the number of copies in a mirrored logical
+volume use 
+.BR lvconvert (8).
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-l, \-\-extents [+/-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
+Change or set the logical volume size in units of logical extents.
+With the + or - sign the value is added to or subtracted from the actual size
+of the logical volume and without it, the value is taken as an absolute one.
+The number can also be expressed as a percentage of the total space
+in the Volume Group with the suffix %VG, relative to the existing
+size of the Logical Volume with the suffix %LV, as a percentage of
+the remaining free space of the PhysicalVolumes on the command line with the
+suffix %PVS, or as a percentage of the remaining free space in the
+Volume Group with the suffix %FREE.
+.TP
+.I \-L, \-\-size [+/-]LogicalVolumeSize[kKmMgGtTpPeE]
+Change or set the logical volume size in units of megabytes.
+A size suffix of M for megabytes,
+G for gigabytes, T for terabytes, P for petabytes 
+or E for exabytes is optional.
+With the + or - sign the value is added to or subtracted from
+the actual size of the logical volume and without it, the value is taken as an
+absolute one.
+.TP
+.I \-i, \-\-stripes Stripes
+Gives the number of stripes to use when extending a Logical Volume.
+Defaults to whatever the last segment of the Logical Volume uses.
+Not applicable to LVs using the original metadata LVM format, which must
+use a single value throughout.
+.TP
+.I \-I, \-\-stripesize StripeSize
+Gives the number of kilobytes for the granularity of the stripes.
+Defaults to whatever the last segment of the Logical Volume uses.
+Not applicable to LVs using the original metadata LVM format, which
+must use a single value throughout.
+.br
+StripeSize must be 2^n (n = 2 to 9)
+.SH SEE ALSO
+.BR lvm (8), 
+.BR lvconvert (8),
+.BR lvcreate (8), 
+.BR lvreduce (8), 
+.BR lvchange (8)
/cvs/lvm2/LVM2/man/lvs.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvs.8.in
+++ -	2008-10-08 12:50:15.968888000 +0000
@@ -0,0 +1,89 @@
+.TH LVS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvs \- report information about logical volumes
+.SH SYNOPSIS
+.B lvs
+[\-\-aligned] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-o/\-\-options [+]Field[,Field]]
+[\-O/\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-P/\-\-partial] [\-\-segments]
+[\-\-separator Separator] [\-\-unbuffered]
+[\-\-units hsbkmgtHKMGT]
+[\-v/\-\-verbose] 
+[\-\-version] [VolumeGroupName [VolumeGroupName...]]
+.SH DESCRIPTION
+lvs produces formatted output about logical volumes.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-\-aligned
+Use with \-\-separator to align the output columns.
+.TP
+.I \-\-noheadings
+Suppress the headings line that is normally the first line of output.
+Useful if grepping the output.
+.TP
+.I \-\-nosuffix
+Suppress the suffix on output sizes.  Use with \-\-units (except h and H)
+if processing the output.
+.TP
+.I \-o, \-\-options
+Comma-separated ordered list of columns.  Precede the list with '+' to append
+to the default selection of columns instead of replacing it.  Column names are: 
+lv_uuid, lv_name, lv_attr, lv_major, lv_minor, lv_kernel_major, lv_kernel_minor,
+lv_size, seg_count, origin, snap_percent,
+copy_percent, move_pv, lv_tags,
+segtype, stripes,
+stripesize, chunksize, seg_start, seg_size, seg_tags, devices,
+regionsize, mirror_log, modules.
+.IP
+With \-\-segments, any "seg_" prefixes are optional; otherwise any "lv_"
+prefixes are optional.  Columns mentioned in \fBvgs (8)\fP 
+can also be chosen.
+Use \fb-o help\fP to view the full list of fields available.
+.IP
+The lv_attr bits are: 
+.RS
+.IP 1 3
+Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin, (p)vmove, (s)napshot, 
+invalid (S)napshot, (v)irtual, mirror (i)mage, mirror (I)mage out-of-sync,
+under (c)onversion
+.IP 2 3
+Permissions: (w)riteable, (r)ead-only
+.IP 3 3
+Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
+This is capitalised if the volume is currently locked against allocation
+changes, for example during \fBpvmove\fP (8).
+.IP 4 3
+fixed (m)inor
+.IP 5 3
+State: (a)ctive, (s)uspended, (I)nvalid snapshot, invalid (S)uspended snapshot,
+mapped (d)evice present without tables, mapped device present with (i)nactive table
+.IP 6 3
+device (o)pen
+.RE
+.TP
+.I \-\-segments
+Use default columns that emphasize segment information.
+.TP
+.I \-O, \-\-sort
+Comma-separated ordered list of columns to sort by.  Replaces the default
+selection. Precede any column with - for a reverse sort on that column.
+.TP
+.I \-\-separator Separator
+String to use to separate each column.  Useful if grepping the output.
+.TP
+.I \-\-unbuffered
+Produce output immediately without sorting or aligning the columns properly.
+.TP
+.I \-\-units hsbkmgtHKMGT
+All sizes are output in these units: (h)uman-readable, (s)ectors, (b)ytes,
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
+of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
+\-\-units 3M
+.SH SEE ALSO
+.BR lvm (8),
+.BR lvdisplay (8),
+.BR pvs (8),
+.BR vgs (8)
/cvs/lvm2/LVM2/man/lvscan.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvscan.8.in
+++ -	2008-10-08 12:50:16.050814000 +0000
@@ -0,0 +1,25 @@
+.TH LVSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvscan \- scan (all disks) for logical volumes
+.SH SYNOPSIS
+.B lvscan
+.RB [ \-b | \-\-blockdevice ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-P | \-\-partial ]
+.RB [ \-v | \-\-verbose ]
+.SH DESCRIPTION
+.B lvscan
+scans all known volume groups or all supported LVM block devices
+in the system for defined logical volumes.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.BR \-b ", " \-\-blockdevice
+Adds the device major and minor numbers to the display
+of each logical volume.
+.SH SEE ALSO
+.BR lvm (8), 
+.BR lvcreate (8),
+.BR lvdisplay (8)
/cvs/lvm2/LVM2/man/pvchange.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvchange.8.in
+++ -	2008-10-08 12:50:16.133689000 +0000
@@ -0,0 +1,34 @@
+.TH PVCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvchange \- change attributes of a physical volume
+.SH SYNOPSIS
+.B pvchange
+[\-\-addtag Tag]
+[\-A/\-\-autobackup y/n] [\-d/\-\-debug] 
+[\-\-deltag Tag]
+[\-h/\-?/\-\-help]
+[\-t/\-\-test]
+[\-v/\-\-verbose] [\-a/\-\-all] [\-x/\-\-allocatable y/n]
+[\-u/\-\-uuid] [PhysicalVolumePath...]
+.SH DESCRIPTION
+pvchange allows you to change the allocation permissions of one or
+more physical volumes.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-a, \-\-all
+If PhysicalVolumePath is not specified on the command line all
+physical volumes are searched for and used.
+.TP
+.I \-u, \-\-uuid
+Generate new random UUID for specified physical volumes.
+.TP
+.I \-x, \-\-allocatable y/n
+Enable or disable allocation of physical extents on this physical volume.
+.SH Example
+"pvchange -x n /dev/sdk1" disallows the allocation of physical extents
+on this physical volume (possibly because of disk errors, or because it will
+be removed after freeing it.
+.SH SEE ALSO
+.BR lvm (8), 
+.BR pvcreate (8)
/cvs/lvm2/LVM2/man/pvck.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvck.8.in
+++ -	2008-10-08 12:50:16.234636000 +0000
@@ -0,0 +1,33 @@
+.TH PVCK 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvck \- check physical volume metadata
+.SH SYNOPSIS
+.B pvck
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-labelsector ]
+.IR PhysicalVolume " [" PhysicalVolume ...]
+.SH DESCRIPTION
+pvck checks physical volume LVM metadata for consistency.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.BR \-\-labelsector " sector"
+By default, 4 sectors of \fBPhysicalVolume\fP are scanned for an LVM label,
+starting at sector 0.  This parameter allows you to specify a different
+starting sector for the scan and is useful for recovery situations.  For
+example, suppose the partition table is corrupted or lost on /dev/sda,
+but you suspect there was an LVM partition at approximately 100 MB.  This
+area of the disk may be scanned by using the \fB--labelsector\fP parameter
+with a value of 204800 (100 * 1024 * 1024 / 512 = 204800):
+.sp
+.BI "pvck --labelsector 204800 /dev/sda"
+.sp
+Note that a script can be used with \fB--labelsector\fP to automate the
+process of finding LVM labels.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvcreate (8),
+.BR pvscan (8)
+.BR vgck (8)
/cvs/lvm2/LVM2/man/pvcreate.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvcreate.8.in
+++ -	2008-10-08 12:50:16.329187000 +0000
@@ -0,0 +1,137 @@
+.TH PVCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvcreate \- initialize a disk or partition for use by LVM
+.SH SYNOPSIS
+.B pvcreate
+.RB [ \-d | \-\-debug ]
+.RB [ \-f [ f ]| \-\-force " [" \-\-force ]]
+.RB [ \-y | \-\-yes ]
+.RB [ \-h | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-labelsector ]
+.RB [ \-M | \-\-metadatatype type ]
+.RB [ \-\-metadatacopies #copies ]
+.RB [ \-\-metadatasize size ]
+.RB [ \-\-restorefile file ]
+.RB [ \-\-setphysicalvolumesize size ]
+.RB [ \-u | \-\-uuid uuid ]
+.RB [ \-\-version ]
+.RB [ \-Z | \-\-zero y/n ]
+.IR PhysicalVolume " [" PhysicalVolume ...]
+.SH DESCRIPTION
+.B pvcreate
+initializes
+.I PhysicalVolume
+for later use by the Logical Volume Manager (LVM).  Each
+.I PhysicalVolume
+can be a disk partition, whole disk, meta device, or loopback file.
+For DOS disk partitions, the partition id should be set to 0x8e using
+.BR fdisk "(8), " cfdisk "(8), "
+or a equivalent.  For
+.B whole disk devices only
+the partition table must be erased, which will effectively destroy all
+data on that disk.  This can be done by zeroing the first sector with:
+.sp
+.BI "dd if=/dev/zero of=" PhysicalVolume " bs=512 count=1"
+.sp
+Continue with
+.BR vgcreate (8)
+to create a new volume group on
+.IR PhysicalVolume ,
+or
+.BR vgextend (8)
+to add
+.I PhysicalVolume
+to an existing volume group.
+.SH OPTIONS
+See \fBlvm\fP(8) for common options.
+.TP
+.BR \-f ", " \-\-force
+Force the creation without any confirmation.  You can not recreate
+(reinitialize) a physical volume belonging to an existing volume group.
+In an emergency you can override this behaviour with -ff.
+.TP
+.BR \-u ", " \-\-uuid " uuid"
+Specify the uuid for the device.  
+Without this option, \fBpvcreate\fP generates a random uuid.
+All of your physical volumes must have unique uuids.
+You need to use this option before restoring a backup of LVM metadata 
+onto a replacement device - see \fBvgcfgrestore\fP(8).
+.TP
+.BR \-y ", " \-\-yes
+Answer yes to all questions.
+.TP
+.BR \-Z ", " \-\-zero " y/n"
+Whether or not the first 4 sectors (2048 bytes) of the device should be 
+wiped.
+If this option is not given, the 
+default is to wipe these sectors unless either or both of the --restorefile 
+or --uuid options were specified.
+.SH NEW METADATA OPTIONS
+LVM2 introduces a new format for storing metadata on disk.
+This new format is more efficient and resilient than the format the 
+original version of LVM used and offers the advanced user greater 
+flexibility and control.
+.sp
+The new format may be selected on the command line with \fB-M2\fP or by 
+setting \fBformat = "lvm2"\fP in the \fBglobal\fP section of \fBlvm.conf\fP.
+Each physical volume in the same volume group must use the same format, but
+different volume groups on a machine may use different formats 
+simultaneously: the tools can handle both formats.
+Additional formats can be added as shared libraries.
+.sp
+Additional tools for manipulating the locations and sizes of metadata areas 
+will be written in due course.  Use the verbose/debug options on the tools
+to see where the metadata areas are placed.
+.TP
+.BR \-\-metadatasize " size"
+The approximate amount of space to be set aside for each metadata area.
+(The size you specify may get rounded.)
+.TP
+.BR \-\-metadatacopies " copies"
+The number of metadata areas to set aside on each PV.  Currently
+this can be 0, 1 or 2.  
+If set to 2, two copies of the volume group metadata 
+are held on the PV, one at the front of the PV and one at the end.  
+If set to 1 (the default), one copy is kept at the front of the PV 
+(starting in the 5th sector).
+If set to 0, no copies are kept on this PV - you might wish to use this
+with VGs containing large numbers of PVs.  But if you do this and
+then later use \fBvgsplit\fP you must ensure that each VG is still going 
+to have a suitable number of copies of the metadata after the split!
+.TP
+.BR \-\-restorefile " file"
+In conjunction with \fB--uuid\fP, this extracts the location and size
+of the data on the PV from the file (produced by \fBvgcfgbackup\fP)
+and ensures that the metadata that the program produces is consistent 
+with the contents of the file i.e. the physical extents will be in 
+the same place and not get overwritten by new metadata.  This provides
+a mechanism to upgrade the metadata format or to add/remove metadata
+areas. Use with care. See also \fBvgconvert\fP(8).
+.TP
+.BR \-\-labelsector " sector"
+By default the PV is labelled with an LVM2 identifier in its second 
+sector (sector 1).  This lets you use a different sector near the
+start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
+in the source).  Use with care.
+.TP
+.BR \-\-setphysicalvolumesize " size"
+Overrides the automatically-detected size of the PV.  Use with care.
+.SH Example
+Initialize partition #4 on the third SCSI disk and the entire fifth
+SCSI disk for later use by LVM:
+.sp
+.B pvcreate /dev/sdc4 /dev/sde
+.sp
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcreate (8), 
+.BR vgextend (8), 
+.BR lvcreate (8), 
+.BR cfdisk (8), 
+.BR fdisk (8), 
+.BR losetup (8), 
+.BR mdadm (8), 
+.BR vgcfgrestore (8), 
+.BR vgconvert (8)
/cvs/lvm2/LVM2/man/pvdisplay.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvdisplay.8.in
+++ -	2008-10-08 12:50:16.409611000 +0000
@@ -0,0 +1,50 @@
+.TH PVDISPLAY 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvdisplay \- display attributes of a physical volume
+.SH SYNOPSIS
+.B pvdisplay
+[\-c/\-\-colon] [\-d/\-\-debug] [\-h/\-?/\-\-help] [\-s/\-\-short]
+[\-v[v]/\-\-verbose [\-\-verbose]]
+PhysicalVolumePath [PhysicalVolumePath...]
+.SH DESCRIPTION
+pvdisplay allows you to see the attributes of one or more physical volumes
+like size, physical extent size, space used for the volume group descriptor
+area and so on.
+.P
+\fBpvs\fP (8) is an alternative that provides the same information 
+in the style of \fBps\fP (1).
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-c, \-\-colon
+Generate colon separated output for easier parsing in scripts or programs.
+N.B. \fBpvs\fP (8) provides considerably more control over the output.
+.nf
+
+The values are:
+
+* physical volume device name
+* volume group name
+* physical volume size in kilobytes
+* internal physical volume number (obsolete)
+* physical volume status
+* physical volume (not) allocatable
+* current number of logical volumes on this physical volume
+* physical extent size in kilobytes
+* total number of physical extents
+* free number of physical extents
+* allocated number of physical extents
+
+.fi
+.TP
+.I \-s, \-\-short
+Only display the size of the given physical volumes.
+.TP
+.I \-m, \-\-maps
+Display the mapping of physical extents to logical volumes and
+logical extents.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvcreate (8),
+.BR lvcreate (8),
+.BR vgcreate (8)
/cvs/lvm2/LVM2/man/pvmove.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvmove.8.in
+++ -	2008-10-08 12:50:16.488930000 +0000
@@ -0,0 +1,99 @@
+.TH PVMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvmove \- move physical extents
+.SH SYNOPSIS
+.B pvmove
+[\-\-abort]
+[\-\-alloc AllocationPolicy]
+[\-b/\-\-background]
+[\-d/\-\-debug] [\-h/\-\-help] [\-i/\-\-interval Seconds] [\-v/\-\-verbose]
+[\-n/\-\-name LogicalVolume] 
+[SourcePhysicalVolume[:PE[-PE]...] [DestinationPhysicalVolume[:PE[-PE]...]...]]
+.SH DESCRIPTION
+.B pvmove
+allows you to move the allocated physical extents (PEs) on
+.I SourcePhysicalVolume
+to one or more other physical volumes (PVs).
+You can optionally specify a source
+.I LogicalVolume
+in which case only extents used by that LV will be moved to 
+free (or specified) extents on
+.IR DestinationPhysicalVolume (s).
+If no
+.I DestinationPhysicalVolume
+is specifed, the normal allocation rules for the volume group are used.
+
+If \fBpvmove\fP gets interrupted for any reason (e.g. the machine crashes)
+then run \fBpvmove\fP again without any PhysicalVolume arguments to
+restart any moves that were in progress from the last checkpoint.
+Alternatively use \fBpvmove --abort\fP at any time to abort them
+at the last checkpoint.
+
+You can run more than one pvmove at once provided they are moving data
+off different SourcePhysicalVolumes, but additional pvmoves will ignore
+any logical volumes already in the process of being changed, so some
+data might not get moved.
+
+\fBpvmove\fP works as follows:
+
+1. A temporary 'pvmove' logical volume is created to store
+details of all the data movements required.
+
+2. Every logical volume in the volume group is searched
+for contiguous data that need moving
+according to the command line arguments.
+For each piece of data found, a new segment is added to the end of the
+pvmove LV.
+This segment takes the form of a temporary mirror to copy the data 
+from the original location to a newly-allocated location. 
+The original LV is updated to use the new temporary mirror segment
+in the pvmove LV instead of accessing the data directly.
+
+3. The volume group metadata is updated on disk.
+
+4. The first segment of the pvmove logical volume is activated and starts
+to mirror the first part of the data.  Only one segment is mirrored at once
+as this is usually more efficient.
+
+5. A daemon repeatedly checks progress at the specified time interval.
+When it detects that the first temporary mirror is in-sync,
+it breaks that mirror so that only the new location for that data gets used 
+and writes a checkpoint into the volume group metadata on disk.
+Then it activates the mirror for the next segment of the pvmove LV.
+
+6. When there are no more segments left to be mirrored, 
+the temporary logical volume is removed and the volume group metadata 
+is updated so that the logical volumes reflect the new data locations.
+
+Note that this new process cannot support the original LVM1
+type of on-disk metadata.  Metadata can be converted using \fBvgconvert\fP(8).
+
+.SH OPTIONS
+.TP
+.I \-\-abort
+Abort any moves in progress.
+.TP
+.I \-b, \-\-background
+Run the daemon in the background.
+.TP
+.I \-i, \-\-interval Seconds
+Report progress as a percentage at regular intervals.
+.TP
+.I \-n, \-\-name " \fILogicalVolume\fR"
+Move only the extents belonging to
+.I LogicalVolume
+from
+.I SourcePhysicalVolume
+instead of all allocated extents to the destination physical volume(s).
+
+.SH EXAMPLES
+To move all logical extents of any logical volumes on
+.B /dev/hda4
+to free physical extents elsewhere in the volume group, giving verbose
+runtime information, use:
+.sp
+\	pvmove -v /dev/hda4
+.sp
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgconvert (8)
/cvs/lvm2/LVM2/man/pvremove.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvremove.8.in
+++ -	2008-10-08 12:50:16.568051000 +0000
@@ -0,0 +1,22 @@
+.TH PVREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvremove \- remove a physical volume
+.SH SYNOPSIS
+.B pvremove
+.RB [ \-d | \-\-debug]
+.RB [ \-f [ f ]| \-\-force " [" \-\-force ]]
+.RB [\-h | \-\-help]
+.RB [ \-t | \-\-test ]
+.RB [ \-v [ v ]| \-\-verbose " [" \-\-verbose ]]
+.RB [ \-y | \-\-yes ]
+.IR PhysicalVolume " [" PhysicalVolume ...]
+.SH DESCRIPTION
+.B pvremove
+wipes the label on a device so that LVM will no longer recognise it
+as a physical volume.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvcreate (8),
+.BR pvdisplay (8)
/cvs/lvm2/LVM2/man/pvresize.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvresize.8.in
+++ -	2008-10-08 12:50:16.646194000 +0000
@@ -0,0 +1,49 @@
+.TH PVRESIZE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvresize \- resize a disk or partition in use by LVM2
+.SH SYNOPSIS
+.B pvresize
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-setphysicalvolumesize size ]
+.IR PhysicalVolume " [" PhysicalVolume ...]
+.SH DESCRIPTION
+.B pvresize
+resizes
+.I PhysicalVolume
+which may already be in a volume group and have active logical volumes
+allocated on it.
+.SH OPTIONS
+See \fBlvm\fP(8) for common options.
+.TP
+.BR \-\-setphysicalvolumesize " size"
+Overrides the automatically-detected size of the PV.  Use with care, or
+prior to reducing the physical size of the device.
+.SH EXAMPLES
+Expand the PV on /dev/sda1 after enlarging the partition with fdisk:
+.sp
+.B pvresize /dev/sda1
+.sp
+Shrink the PV on /dev/sda1 prior to shrinking the partition with fdisk
+(ensure that the PV size is appropriate for your intended new partition
+size):
+.sp
+.B pvresize --setphysicalvolumesize 40G /dev/sda1
+.sp
+.SH RESTRICTIONS
+.B pvresize
+will refuse to shrink
+.I PhysicalVolume
+if it has allocated extents after where its new end would be. In the future,
+it should relocate these elsewhere in the volume group if there is sufficient
+free space, like
+.B pvmove
+does.
+.sp
+.B pvresize
+won't currently work correctly on LVM1 volumes or PVs with extra
+metadata areas.
+.SH SEE ALSO
+.BR lvm "(8), " pvmove "(8), " lvresize "(8), " fdisk "(8)"
/cvs/lvm2/LVM2/man/pvs.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvs.8.in
+++ -	2008-10-08 12:50:16.724805000 +0000
@@ -0,0 +1,64 @@
+.TH PVS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvs \- report information about physical volumes
+.SH SYNOPSIS
+.B pvs
+[\-\-aligned] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-o/\-\-options [+]Field[,Field]]
+[\-O/\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-\-separator Separator] [\-\-unbuffered]
+[\-\-units hsbkmgtHKMGT]
+[\-v/\-\-verbose] 
+[\-\-version] [PhysicalVolume [PhysicalVolume...]]
+.SH DESCRIPTION
+pvs produces formatted output about physical volumes.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-\-aligned
+Use with \-\-separator to align the output columns.
+.TP
+.I \-\-noheadings
+Suppress the headings line that is normally the first line of output.
+Useful if grepping the output.
+.TP
+.I \-\-nosuffix
+Suppress the suffix on output sizes.  Use with \-\-units (except h and H)
+if processing the output.
+.TP
+.I \-o, \-\-options
+Comma-separated ordered list of columns.  Precede the list with '+' to append
+to the default selection of columns.  Column names are: pv_fmt, pv_uuid,
+pv_size, dev_size, pv_free, pv_used, pv_name, pv_attr, pv_pe_count, 
+pv_pe_alloc_count, pv_tags, pvseg_start, pvseg_size, pe_start.
+With --segments, any "pvseg_" prefixes are optional; otherwise any
+"pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
+be chosen. The pv_attr bits are: (a)llocatable and e(x)ported.
+Use \fb-o help\fP to view the full list of fields available.
+.TP
+.I \-\-segments
+Produces one line of output for each contiguous allocation of space on each
+Physical Volume, showing the start (pvseg_start) and length (pvseg_size) in
+units of physical extents.
+.TP
+.I \-O, \-\-sort
+Comma-separated ordered list of columns to sort by.  Replaces the default
+selection. Precede any column with - for a reverse sort on that column.
+.TP
+.I \-\-separator Separator
+String to use to separate each column.  Useful if grepping the output.
+.TP
+.I \-\-unbuffered
+Produce output immediately without sorting or aligning the columns properly.
+.TP
+.I \-\-units hsbkmgtHKMGT
+All sizes are output in these units: (h)uman-readable, (s)ectors, (b)ytes,
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
+of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
+\-\-units 3M
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvdisplay (8),
+.BR lvs (8),
+.BR vgs (8)
/cvs/lvm2/LVM2/man/pvscan.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/pvscan.8.in
+++ -	2008-10-08 12:50:16.804685000 +0000
@@ -0,0 +1,34 @@
+.TH PVSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvscan \- scan all disks for physical volumes
+.SH SYNOPSIS
+.B pvscan
+.RB [ \-d | \-\-debug]
+.RB [\-e | \-\-exported]
+.RB [\-h | \-\-help]
+.RB [\-\-ignorelockingfailure]
+.RB [ \-n | \-\-novolumegroup]
+.RB [\-s | \-\-short]
+.RB [\-u | \-\-uuid]
+.RB [ \-v [ v ]| \-\-verbose " [" \-\-verbose ]]
+.SH DESCRIPTION
+.B pvscan
+scans all supported LVM block devices in the system for physical volumes.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.BR \-e ", " \-\-exported
+Only show physical volumes belonging to exported volume groups.
+.TP
+.BR \-n ", " \-\-novolumegroup
+Only show physical volumes not belonging to any volume group.
+.TP
+.BR \-s ", " \-\-short
+Short listing format.
+.TP
+.BR \-u ", " \-\-uuid
+Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvcreate (8),
+.BR pvdisplay (8)
/cvs/lvm2/LVM2/man/vgcfgbackup.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgcfgbackup.8.in
+++ -	2008-10-08 12:50:16.886180000 +0000
@@ -0,0 +1,32 @@
+.TH VGCFGBACKUP 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgcfgbackup \- backup volume group descriptor area
+.SH SYNOPSIS
+.B vgcfgbackup
+.RB [ \-d | \-\-debug ]
+.RB [ \-f | \-\-file " filename" ]
+.RB [ \-h | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-P | \-\-partial ]
+.RB [ \-v | \-\-verbose ]
+.RI [ VolumeGroupName ...]
+.SH DESCRIPTION
+.B vgcfgbackup
+allows you to backup the metadata 
+of your volume groups.
+If you don't name any volume groups on the command line, all of them 
+will be backed up.
+.sp
+In a default installation, each volume group gets backed up into a separate
+file bearing the name of the volume group in the directory /etc/lvm/backup.
+You can write the backup to an alternative file using -f.  In this case
+if you are backing up more than one volume group the filename is
+treated as a template, and %s gets replaced by the volume group name.
+.sp
+NB. This DOESN'T backup user/system data in logical
+volume(s)!  Backup /etc/lvm regularly too.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcfgrestore (8)
/cvs/lvm2/LVM2/man/vgcfgrestore.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgcfgrestore.8.in
+++ -	2008-10-08 12:50:16.965694000 +0000
@@ -0,0 +1,44 @@
+.TH VGCFGRESTORE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgcfgrestore \- restore volume group descriptor area
+.SH SYNOPSIS
+.B vgcfgrestore
+.RB [ \-d | \-\-debug ]
+.RB [ \-f | \-\-file " filename" ]
+.RB [ \-l[l] | \-\-list ]
+.RB [ \-h | \-\-help ]
+.RB [ \-M | \-\-Metadatatype 1|2]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RI \fIVolumeGroupName\fP
+.SH DESCRIPTION
+.B vgcfgrestore
+allows you to restore the metadata of \fIVolumeGroupName\fP from a text 
+backup file produced by \fBvgcfgbackup\fP.  You can specify a backup file 
+with \fP--file\fP.  If no backup file is specified, the most recent
+one is used.  Use \fB--list\fP for a list of the available
+backup and archive files of \fIVolumeGroupName\fP.
+.SH OPTIONS
+.TP
+\fB-l | --list\fP \(em List files pertaining to \fIVolumeGroupName\fP
+List metadata backup and archive files pertaining to \fIVolumeGroupName\fP.
+May be used with the \fB-f\fP option.  Does not restore \fIVolumeGroupName\fP.
+.TP
+\fB-f | --file\fP filename \(em Name of LVM metadata backup file
+Specifies a metadata backup or archive file to be used for restoring 
+VolumeGroupName.  Often this file has been created with \fBvgcfgbackup\fP.
+.TP
+See \fBlvm\fP for common options.
+.SH REPLACING PHYSICAL VOLUMES
+\fBvgdisplay --partial --verbose\fP will show you the UUIDs and sizes of
+any PVs that are no longer present.
+If a PV in the VG is lost and you wish to substitute 
+another of the same size, use 
+\fBpvcreate --restorefile filename --uuid uuid\fP (plus additional 
+arguments as appropriate) to initialise it with the same UUID as 
+the missing PV.  Repeat for all other missing PVs in the VG. 
+Then use \fBvgcfgrestore --file filename\fP to restore the volume
+group's metadata.
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcreate (8)
/cvs/lvm2/LVM2/man/vgchange.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgchange.8.in
+++ -	2008-10-08 12:50:17.044548000 +0000
@@ -0,0 +1,152 @@
+.TH VGCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgchange \- change attributes of a volume group
+.SH SYNOPSIS
+.B vgchange
+.RB [ \-\-addtag
+.IR Tag ]
+.RB [ \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-A | \-\-autobackup " {" y | n }]
+.RB [ \-a | \-\-available " [e|l] {" y | n }]
+.RB [ \-\-monitor " {" y | n }]
+.RB [ \-c | \-\-clustered " {" y | n }]
+.RB [ \-u | \-\-uuid ]
+.RB [ \-d | \-\-debug]
+.RB [ \-\-deltag
+.IR Tag ]
+.RB [ \-h | \-\-help]
+.RB [ \-\-ignorelockingfailure]
+.RB [ \-\-ignoremonitoring]
+.RB [ \-l | \-\-logicalvolume
+.IR MaxLogicalVolumes ]
+.RB [ -p | \-\-maxphysicalvolumes
+.IR MaxPhysicalVolumes ]
+.RB [ \-P | \-\-partial]
+.RB [ \-s | \-\-physicalextentsize
+.IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.RB [ -t | \-\-test]
+.RB [ \-v | \-\-verbose]
+.RB [ \-\-version ]
+.RB [ \-x | \-\-resizeable " {" y | n }]
+.RI [ VolumeGroupName ...]
+.SH DESCRIPTION
+.B vgchange
+allows you to change the attributes of one or more volume groups.
+Its main purpose is to activate and deactivate
+.IR VolumeGroupName ,
+or all volume groups if none is specified.  Only active volume groups
+are subject to changes and allow access to their logical volumes.
+[Not yet implemented: During volume group activation, if
+.B vgchange
+recognizes snapshot logical volumes which were dropped because they ran
+out of space, it displays a message informing the administrator that such
+snapshots should be removed (see
+.BR lvremove (8)).
+]
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.BR \-A ", " \-\-autobackup " " { y | n }
+Controls automatic backup of metadata after the change.  See
+.B vgcfgbackup (8).
+Default is yes.
+.TP
+.BR \-a ", " \-\-available " " [e|l] { y | n }
+Controls the availability of the logical volumes in the volume 
+group for input/output.
+In other words, makes the logical volumes known/unknown to the kernel.
+.IP
+If clustered locking is enabled, add 'e' to activate/deactivate
+exclusively on one node or 'l' to activate/deactivate only
+on the local node.  
+Logical volumes with single-host snapshots are always activated
+exclusively because they can only be used on one node at once.
+.TP
+.BR \-c ", " \-\-clustered " " { y | n }
+If clustered locking is enabled, this indicates whether this
+Volume Group is shared with other nodes in the cluster or whether
+it contains only local disks that are not visible on the other nodes.
+If the cluster infrastructure is unavailable on a particular node at a
+particular time, you may still be able to use Volume Groups that
+are not marked as clustered.
+.TP
+.BR \-u ", " \-\-uuid
+Generate new random UUID for specified Volume Groups.
+.TP
+.BR \-\-monitor " " { y | n }
+Controls whether or not a mirrored logical volume is monitored by
+dmeventd, if it is installed.
+If a device used by a monitored mirror reports an I/O error,
+the failure is handled according to 
+.BR mirror_image_fault_policy
+and 
+.BR mirror_log_fault_policy
+set in 
+.BR lvm.conf (5).
+.TP
+.BR \-\-ignoremonitoring
+Make no attempt to interact with dmeventd unless 
+.BR \-\-monitor
+is specified.
+Do not use this if dmeventd is already monitoring a device.
+.TP
+.BR \-l ", " \-\-logicalvolume " " \fIMaxLogicalVolumes\fR
+Changes the maximum logical volume number of an existing inactive
+volume group.
+.TP
+.BR \-p ", " \-\-maxphysicalvolumes " " \fIMaxPhysicalVolumes\fR
+Changes the maximum number of physical volumes that can belong
+to this volume group.
+For volume groups with metadata in lvm1 format, the limit is 255.
+If the metadata uses lvm2 format, the value 0
+removes this restriction: there is then no limit.
+If you have a large number of physical volumes in
+a volume group with metadata in lvm2 format,
+for tool performance reasons, you should consider
+some use of \fB--metadatacopies 0\fP
+as described in \fBpvcreate(8)\fP.
+.TP
+.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBkKmMgGtT\fR]
+Changes the physical extent size on physical volumes of this volume group.
+A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
+is the default if no suffix is present.
+The default is 4 MB and it must be at least 1 KB and a power of 2.
+ 
+Before increasing the physical extent size, you might need to use lvresize,
+pvresize and/or pvmove so that everything fits.  For example, every
+contiguous range of extents used in a logical volume must start and 
+end on an extent boundary.
+ 
+If the volume group metadata uses lvm1 format, extents can vary in size from
+8KB to 16GB and there is a limit of 65534 extents in each logical volume.  The
+default of 4 MB leads to a maximum logical volume size of around 256GB.
+ 
+If the volume group metadata uses lvm2 format those restrictions do not apply,
+but having a large number of extents will slow down the tools but have no
+impact on I/O performance to the logical volume.  The smallest PE is 1KB.
+ 
+The 2.4 kernel has a limitation of 2TB per block device.
+.TP
+.BR \-x ", " \-\-resizeable " " { y | n }
+Enables or disables the extension/reduction of this volume group
+with/by physical volumes.
+.SH EXAMPLES
+To activate all known volume groups in the system:
+.nf
+
+\	vgchange -a y
+
+.fi
+To change the maximum number of logical volumes of inactive volume group
+.B vg00
+to 128.
+.nf
+
+\	vgchange -l 128 /dev/vg00
+
+.fi
+.SH SEE ALSO
+.BR lvchange (8),
+.BR lvm (8),
+.BR vgcreate (8)
/cvs/lvm2/LVM2/man/vgck.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgck.8.in
+++ -	2008-10-08 12:50:17.125664000 +0000
@@ -0,0 +1,15 @@
+.TH VGCK 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgck \- check volume group metadata
+.SH SYNOPSIS
+.B vgck
+[\-d/\-\-debug] [\-h/\-?/\-\-help] [\-v/\-\-verbose] [VolumeGroupName...]
+.SH DESCRIPTION
+vgck checks LVM metadata for each named volume group for consistency.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcreate (8),
+.BR vgchange (8),
+.BR vgscan (8)
/cvs/lvm2/LVM2/man/vgconvert.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgconvert.8.in
+++ -	2008-10-08 12:50:17.211501000 +0000
@@ -0,0 +1,39 @@
+.TH VGCONVERT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgconvert \- convert volume group metadata format
+.SH SYNOPSIS
+.B vgconvert
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-labelsector ]
+.RB [ \-M | \-\-metadatatype type ]
+.RB [ \-\-metadatacopies #copies ]
+.RB [ \-\-metadatasize size ]
+.RB [ \-\-version ]
+.IR VolumeGroupName " [" VolumeGroupName ...]
+.SH DESCRIPTION
+.B vgconvert
+converts 
+.I VolumeGroupName
+metadata from one format to another provided that the metadata
+fits into the same space.
+.SH OPTIONS
+See \fBlvm\fP(8) and \fBpvcreate\fP(8) for options.
+.SH EXAMPLE
+Convert volume group vg1 from LVM1 metadata format to the new LVM2 
+metadata format.
+.sp
+.B vgconvert -M2 vg1
+.SH RECOVERY
+Use \fBpvscan\fP(8) to see which PVs lost their metadata.
+Run \fBpvcreate\fP(8) with the --uuid and --restorefile options on each
+such PV to reformat it as it was, using the archive file that
+\fBvgconvert\fP(8) created at the start of the procedure.
+Finally run \fBvgcfgrestore\fP(8) with that archive file to restore
+the original metadata.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvcreate (8),
+.BR vgcfgrestore (8)
/cvs/lvm2/LVM2/man/vgcreate.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgcreate.8.in
+++ -	2008-10-08 12:50:17.299055000 +0000
@@ -0,0 +1,110 @@
+.TH VGCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgcreate \- create a volume group
+.SH SYNOPSIS
+.B vgcreate
+.RB [ \-\-addtag
+.IR Tag ]
+.RB [ \-\-alloc 
+.IR AllocationPolicy ]
+.RB [ \-A | \-\-autobackup " {" y | n }]
+.RB [ \-c | \-\-clustered " {" y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-l | \-\-maxlogicalvolumes
+.IR MaxLogicalVolumes ]
+.RB [ -M | \-\-metadatatype type]
+.RB [ -p | \-\-maxphysicalvolumes
+.IR MaxPhysicalVolumes ]
+.RB [ \-s | \-\-physicalextentsize
+.IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.I VolumeGroupName PhysicalVolumePath
+.RI [ PhysicalVolumePath ...]
+.SH DESCRIPTION
+.B vgcreate
+creates a new volume group called
+.I VolumeGroupName
+using the block special device
+.IR PhysicalVolumePath
+previously configured for LVM with
+.BR pvcreate (8).
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.BR \-c ", " \-\-clustered " " { y | n }
+If clustered locking is enabled, this defaults to \fBy\fP indicating that 
+this Volume Group is shared with other nodes in the cluster.
+
+If the new Volume Group contains only local disks that are not visible 
+on the other nodes, you must specify \fB\-\-clustered\ n\fP.
+If the cluster infrastructure is unavailable on a particular node at a
+particular time, you may still be able to use such Volume Groups.
+.TP
+.BR \-l ", " \-\-maxlogicalvolumes " " \fIMaxLogicalVolumes\fR
+Sets the maximum number of logical volumes allowed in this
+volume group. 
+The setting can be changed with \fBvgchange\fP.
+For volume groups with metadata in lvm1 format, the limit
+and default value is 255.  
+If the metadata uses lvm2 format, the default value is 0
+which removes this restriction: there is then no limit.
+.TP
+.BR \-p ", " \-\-maxphysicalvolumes " " \fIMaxPhysicalVolumes\fR
+Sets the maximum number of physical volumes that can belong
+to this volume group.
+The setting can be changed with \fBvgchange\fP.
+For volume groups with metadata in lvm1 format, the limit
+and default value is 255.  
+If the metadata uses lvm2 format, the default value is 0
+which removes this restriction: there is then no limit.
+If you have a large number of physical volumes in
+a volume group with metadata in lvm2 format, 
+for tool performance reasons, you should consider 
+some use of \fB--metadatacopies 0\fP
+as described in \fBpvcreate(8)\fP.
+.TP
+.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBkKmMgGtT\fR]
+Sets the physical extent size on physical volumes of this volume group.
+A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
+is the default if no suffix is present.  
+The default is 4 MB and it must be at least 1 KB and a power of 2.
+
+Once this value has been set, it is difficult to change it without recreating
+the volume group which would involve backing up and restoring data on any 
+logical volumes.  However, if no extents need moving for the new
+value to apply, it can be altered using vgchange \-s.
+
+If the volume group metadata uses lvm1 format, extents can vary in size from
+8KB to 16GB and there is a limit of 65534 extents in each logical volume.  The
+default of 4 MB leads to a maximum logical volume size of around 256GB.  
+
+If the volume group metadata uses lvm2 format those restrictions do not apply,
+but having a large number of extents will slow down the tools but have no
+impact on I/O performance to the logical volume.  The smallest PE is 1KB.
+
+The 2.4 kernel has a limitation of 2TB per block device.
+.SH EXAMPLES
+To create a volume group named
+.B test_vg 
+using physical volumes
+.BR /dev/hdk1 ", and " /dev/hdl1
+with default physical extent size of 4MB:
+.nf
+
+\	vgcreate test_vg /dev/sdk1 /dev/sdl1
+
+.fi
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvdisplay (8),
+.BR pvcreate (8),
+.BR vgdisplay (8),
+.BR vgextend (8),
+.BR vgreduce (8),
+.BR lvcreate (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8)
/cvs/lvm2/LVM2/man/vgdisplay.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgdisplay.8.in
+++ -	2008-10-08 12:50:17.380750000 +0000
@@ -0,0 +1,73 @@
+.TH VGDISPLAY 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgdisplay \- display attributes of volume groups
+.SH SYNOPSIS
+.B vgdisplay
+.RB [ \-A | \-\-activevolumegroups ]
+.RB [ \-c | \-\-colon ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-P | \-\-partial ]
+.RB [ \-s | \-\-short ]
+.RB [ \-v [ v ]| \-\-verbose " [" \-\-verbose ]]
+.RB [ \-\-version ]
+.RI [ VolumeGroupName ...]
+.SH DESCRIPTION
+.B vgdisplay
+allows you to see the attributes of
+.I VolumeGroupName
+(or all volume groups if none is given) with it's physical and logical
+volumes and their sizes etc.
+.P
+\fBvgs\fP (8) is an alternative that provides the same information 
+in the style of \fBps\fP (1).
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.BR \-A ", " \-\-activevolumegroups
+Only select the active volume groups.
+.TP
+.BR \-c ", " \-\-colon
+Generate colon separated output for easier parsing in scripts or programs.
+N.B. \fBvgs\fP (8) provides considerably more control over the output.
+.nf
+
+The values are:
+
+1  volume group name
+2  volume group access
+3  volume group status
+4  internal volume group number
+5  maximum number of logical volumes
+6  current number of logical volumes
+7  open count of all logical volumes in this volume group
+8  maximum logical volume size
+9  maximum number of physical volumes
+10 current number of physical volumes
+11 actual number of physical volumes
+12 size of volume group in kilobytes
+13 physical extent size
+14 total number of physical extents for this volume group
+15 allocated number of physical extents for this volume group
+16 free number of physical extents for this volume group
+17 uuid of volume group
+
+.fi
+.TP
+.BR \-s ", " \-\-short
+Give a short listing showing the existence of volume groups.
+.TP
+.BR \-v ", " \-\-verbose
+Display verbose information containing long listings of physical
+and logical volumes.  If given twice, also display verbose runtime
+information of vgdisplay's activities.
+.TP
+.BR \-\-version
+Display version and exit successfully.
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgs (8),
+.BR pvcreate (8),
+.BR vgcreate (8),
+.BR lvcreate (8)
/cvs/lvm2/LVM2/man/vgexport.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgexport.8.in
+++ -	2008-10-08 12:50:17.459518000 +0000
@@ -0,0 +1,27 @@
+.TH VGEXPORT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgexport \- make volume groups unknown to the system
+.SH SYNOPSIS
+.B vgexport
+[\-a/\-\-all]
+[\-d/\-\-debug] [\-h/\-?/\-\-help] 
+[\-v/\-\-verbose]
+VolumeGroupName [VolumeGroupName...]
+.SH DESCRIPTION
+vgexport allows you to make the inactive 
+.IR VolumeGroupName (s)
+unknown to the system.
+You can then move all the Physical Volumes in that Volume Group to
+a different system for later
+.BR vgimport (8).
+Most LVM2 tools ignore exported Volume Groups.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-a, \-\-all
+Export all inactive Volume Groups.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvscan (8),
+.BR vgimport (8),
+.BR vgscan (8)
/cvs/lvm2/LVM2/man/vgextend.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgextend.8.in
+++ -	2008-10-08 12:50:17.543497000 +0000
@@ -0,0 +1,25 @@
+.TH VGEXTEND 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgextend \- add physical volumes to a volume group
+.SH SYNOPSIS
+.B vgextend
+[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help] 
+[\-t/\-\-test]
+[\-v/\-\-verbose]
+VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
+.SH DESCRIPTION
+vgextend allows you to add one or more initialized physical volumes ( see
+.B pvcreate(8)
+) to an existing volume group to extend it in size.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH Examples
+"vgextend vg00 /dev/sda4 /dev/sdn1" tries to extend the existing volume
+group "vg00" by the new physical volumes (see
+.B pvcreate(8)
+) "/dev/sdn1" and /dev/sda4".
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcreate (8),
+.BR vgreduce (8),
+.BR pvcreate (8)
/cvs/lvm2/LVM2/man/vgimport.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgimport.8.in
+++ -	2008-10-08 12:50:17.623214000 +0000
@@ -0,0 +1,25 @@
+.TH VGIMPORT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgimport \- make exported volume groups known to the system
+.SH SYNOPSIS
+.B vgimport
+[\-a/\-\-all]
+[\-d/\-\-debug] [\-h/\-?/\-\-help] 
+[\-v/\-\-verbose]
+VolumeGroupName [VolumeGroupName...]
+.SH DESCRIPTION
+.B vgimport
+allows you to make a Volume Group that was previously exported using
+.BR vgexport (8)
+known to the system again, perhaps after moving its Physical Volumes
+from a different machine.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-a, \-\-all
+Import all exported Volume Groups.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvscan (8),
+.BR vgexport (8),
+.BR vgscan (8)
/cvs/lvm2/LVM2/man/vgmerge.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgmerge.8.in
+++ -	2008-10-08 12:50:17.702963000 +0000
@@ -0,0 +1,29 @@
+.TH VGMERGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgmerge \- merge two volume groups
+.SH SYNOPSIS
+.B vgmerge
+[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help] [\-l/\-\-list]
+[\-t/\-\-test] [\-v/\-\-verbose] DestinationVolumeGroupName
+SourceVolumeGroupName
+.SH DESCRIPTION
+vgmerge merges two existing volume groups. The inactive SourceVolumeGroupName
+will be merged into the DestinationVolumeGroupName if physical extent sizes
+are equal and physical and logical volume summaries of both volume groups
+fit into DestinationVolumeGroupName's limits.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.I \-l, \-\-list
+Display merged DestinationVolumeGroupName like "vgdisplay -v".
+.TP 
+.I \-t, \-\-test
+Do a test run WITHOUT making any real changes.
+.SH Examples
+"vgmerge -v databases my_vg" merges the inactive volume group named "my_vg" 
+into the active or inactive volume group named "databases" giving verbose
+runtime information.
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcreate (8),
+.BR vgextend (8),
+.BR vgreduce (8)
/cvs/lvm2/LVM2/man/vgmknodes.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgmknodes.8.in
+++ -	2008-10-08 12:50:17.786241000 +0000
@@ -0,0 +1,17 @@
+.TH VGMKNODES 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgmknodes \- recreate volume group directory and logical volume special files
+.SH SYNOPSIS
+.B vgmknodes
+[\-d/\-\-debug] [\-h/\-?/\-\-help] 
+[\-v/\-\-verbose]
+[[VolumeGroupName | LogicalVolumePath]...]
+.SH DESCRIPTION
+Checks the LVM2 special files in /dev that are needed for active 
+logical volumes and creates any missing ones and removes unused ones.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgscan (8),
+.BR dmsetup (8)
/cvs/lvm2/LVM2/man/vgreduce.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgreduce.8.in
+++ -	2008-10-08 12:50:17.866782000 +0000
@@ -0,0 +1,39 @@
+.TH VGREDUCE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgreduce \- reduce a volume group
+.SH SYNOPSIS
+.B vgreduce
+[\-a/\-\-all] [\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-\-removemissing]
+[\-t/\-\-test]
+[\-v/\-\-verbose] VolumeGroupName
+[PhysicalVolumePath...]
+.SH DESCRIPTION
+vgreduce allows you to remove one or more unused physical volumes
+from a volume group.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-a, \-\-all
+Removes all empty physical volumes if none are given on command line.
+.TP
+.I \-\-removemissing
+Removes all missing physical volumes from the volume group, if there are no
+logical volumes allocated on those. This resumes normal operation of the volume
+group (new logical volumes may again be created, changed and so on).
+
+If this is not possible (there are logical volumes referencing the missing
+physical volumes) and you cannot or do not want to remove them manually, you
+can run this option with --force to have vgreduce remove any partial LVs.
+
+Any logical volumes and dependent snapshots that were partly on the 
+missing disks get removed completely. This includes those parts 
+that lie on disks that are still present.
+
+If your logical volumes spanned several disks including the ones that are
+lost, you might want to try to salvage data first by activating your
+logical volumes with --partial as described in \fBlvm (8)\fP.
+
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgextend (8)
/cvs/lvm2/LVM2/man/vgremove.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgremove.8.in
+++ -	2008-10-08 12:50:17.946920000 +0000
@@ -0,0 +1,28 @@
+.TH VGREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgremove \- remove a volume group
+.SH SYNOPSIS
+.B vgremove
+[\-d/\-\-debug] [\-f/\-\-force] [\-h/\-?/\-\-help]
+[\-t/\-\-test] [\-v/\-\-verbose]
+VolumeGroupName [VolumeGroupName...]
+.SH DESCRIPTION
+vgremove allows you to remove one or more volume groups.
+If one or more physical volumes in the volume group are lost,
+consider \fBvgreduce --removemissing\fP to make the volume group
+metadata consistent again.
+.sp
+If there are logical volumes that exist in the volume group,
+a prompt will be given to confirm removal.  You can override
+the prompt with \fB-f\fP.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.BR \-f ", " \-\-force
+Force the removal of any logical volumes on the volume group
+without confirmation.
+.SH SEE ALSO
+.BR lvm (8),
+.BR lvremove (8),
+.BR vgcreate (8),
+.BR vgreduce (8)
/cvs/lvm2/LVM2/man/vgrename.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgrename.8.in
+++ -	2008-10-08 12:50:18.027491000 +0000
@@ -0,0 +1,49 @@
+.TH VGRENAME 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgrename \- rename a volume group
+.SH SYNOPSIS
+.B vgrename
+[\-A/\-\-autobackup y/n]
+[\-d/\-\-debug]
+[\-h/\-?/\-\-help]
+[\-t/\-\-test]
+[\-v/\-\-verbose]
+.IR OldVolumeGroup { Path | Name | UUID }
+.IR NewVolumeGroup { Path | Name }
+.SH DESCRIPTION
+vgrename renames an existing (see
+.B vgcreate(8)
+) volume group from
+.IR OldVolumeGroup { Name | Path | UUID }
+to
+.IR NewVolumeGroup { Name | Path }.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH Examples
+"vgrename /dev/vg02 /dev/my_volume_group" renames existing
+volume group "vg02" to "my_volume_group".
+.TP
+"vgrename vg02 my_volume_group" does the same.
+.TP
+"vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 VolGroup00_tmp"
+changes the name of the Volume Group with UUID
+Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 to 
+"VolGroup00_tmp".
+
+All the Volume Groups visible to a system need to have different
+names.  Otherwise many LVM2 commands will refuse to run or give
+warning messages.
+
+This situation could arise when disks are moved between machines.  If
+a disk is connected and it contains a Volume Group with the same name
+as the Volume Group containing your root filesystem the machine might
+not even boot correctly.  However, the two Volume Groups should have
+different UUIDs (unless the disk was cloned) so you can rename
+one of the conflicting Volume Groups with
+\fBvgrename\fP.
+.TP
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgchange (8),
+.BR vgcreate (8),
+.BR lvrename (8)
/cvs/lvm2/LVM2/man/vgs.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgs.8.in
+++ -	2008-10-08 12:50:18.107921000 +0000
@@ -0,0 +1,77 @@
+.TH VGS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgs \- report information about volume groups
+.SH SYNOPSIS
+.B vgs
+[\-\-aligned] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-o/\-\-options [+]Field[,Field]]
+[\-O/\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-P/\-\-partial]
+[\-\-separator Separator] [\-\-unbuffered]
+[\-\-units hsbkmgtHKMGT]
+[\-v/\-\-verbose] 
+[\-\-version] [VolumeGroupName [VolumeGroupName...]]
+.SH DESCRIPTION
+vgs produces formatted output about volume groups.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-\-aligned
+Use with \-\-separator to align the output columns.
+.TP
+.I \-\-noheadings
+Suppress the headings line that is normally the first line of output.
+Useful if grepping the output.
+.TP
+.I \-\-nosuffix
+Suppress the suffix on output sizes.  Use with \-\-units (except h and H)
+if processing the output.
+.TP
+.I \-o, \-\-options
+Comma-separated ordered list of columns.  Precede the list with '+' to append
+to the default selection of columns.  Column names are: vg_fmt, vg_uuid,
+vg_name, vg_attr, vg_size, vg_free, vg_sysid, vg_extent_size, vg_extent_count,
+vg_free_count, max_lv, max_pv, pv_count, lv_count, snap_count, vg_seqno,
+vg_tags.
+Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs (8)\fP 
+or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both
+at the same time.  
+Use \fb-o help\fP to view the full list of fields available.
+.IP
+The vg_attr bits are:
+.RS
+.IP 1 3
+Permissions: (w)riteable, (r)ead-only
+.IP 2 3
+Resi(z)eable
+.IP 3 3
+E(x)ported
+.IP 4 3
+(p)artial
+.IP 5 3
+Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
+.IP 6 3
+(c)lustered
+.RE
+.TP
+.I \-O, \-\-sort
+Comma-separated ordered list of columns to sort by.  Replaces the default
+selection. Precede any column with - for a reverse sort on that column.
+.TP
+.I \-\-separator Separator
+String to use to separate each column.  Useful if grepping the output.
+.TP
+.I \-\-unbuffered
+Produce output immediately without sorting or aligning the columns properly.
+.TP
+.I \-\-units hsbkmgtHKMGT
+All sizes are output in these units: (h)uman-readable, (s)ectors, (b)ytes,
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
+of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
+\-\-units 3M
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgdisplay (8),
+.BR pvs (8),
+.BR lvs (8)
/cvs/lvm2/LVM2/man/vgscan.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgscan.8.in
+++ -	2008-10-08 12:50:18.193070000 +0000
@@ -0,0 +1,28 @@
+.TH VGSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgscan \- scan all disks for volume groups and rebuild caches
+.SH SYNOPSIS
+.B vgscan
+[\-d/\-\-debug] [\-h/\-?/\-\-help] 
+[\-\-ignorelockingfailure]
+[\-\-mknodes]
+[\-P/\-\-partial]
+[\-v/\-\-verbose]
+.SH DESCRIPTION
+vgscan scans all SCSI, (E)IDE disks, multiple devices and a bunch
+of other disk devices in the system looking for LVM physical volumes
+and volume groups.  Define a filter in \fBlvm.conf\fP(5) to restrict 
+the scan to avoid a CD ROM, for example.
+.LP
+In LVM2, vgscans take place automatically; but you might still need to
+run one explicitly after changing hardware.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-\-mknodes
+Also checks the LVM special files in /dev that are needed for active 
+logical volumes and creates any missing ones and removes unused ones.
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcreate (8),
+.BR vgchange (8)
/cvs/lvm2/LVM2/man/vgsplit.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/vgsplit.8.in
+++ -	2008-10-08 12:50:18.289951000 +0000
@@ -0,0 +1,66 @@
+.TH VGSPLIT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+vgsplit \- split a volume group into two
+.SH SYNOPSIS
+.B vgsplit
+.RB [ \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-A | \-\-autobackup " {" y | n }]
+.RB [ \-c | \-\-clustered " {" y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-l | \-\-maxlogicalvolumes
+.IR MaxLogicalVolumes ]
+.RB [ -M | \-\-metadatatype
+.IR type ]
+.RB [ -p | \-\-maxphysicalvolumes
+.IR MaxPhysicalVolumes ]
+.RB [ \-n | \-\-name 
+.IR LogicalVolumeName ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+SourceVolumeGroupName DestinationVolumeGroupName
+[ PhysicalVolumePath ...]
+.SH DESCRIPTION
+.B vgsplit 
+moves one or more physical volumes from
+.I SourceVolumeGroupName
+into
+.I DestinationVolumeGroupName\fP.  The physical volumes moved can be
+specified either explicitly via \fIPhysicalVolumePath\fP, or implicitly by
+\fB-n\fP \fILogicalVolumeName\fP, in which case only physical volumes
+underlying the specified logical volume will be moved.
+
+If
+.I DestinationVolumeGroupName
+does not exist, a new volume group will be created.  The default attributes
+for the new volume group can be specified with \fB\-\-alloc\fR,
+\fB\-\-clustered\fR, \fB\-\-maxlogicalvolumes\fR, \fB\-\-metadatatype\fR,
+and \fB\-\-maxphysicalvolumes\fR (see \fBvgcreate(8)\fR for a description
+of these options).  If any of these options are not given, default
+attribute(s) are taken from
+.I SourceVolumeGroupName\fP.
+
+If
+.I DestinationVolumeGroupName
+does exist, it will be checked for compatibility with
+.I SourceVolumeGroupName
+before the physical volumes are moved. Specifying any of the above default
+volume group attributes with an existing destination volume group is an error,
+and no split will occur.
+
+Logical volumes cannot be split between volume groups. \fBVgsplit(8)\fP only
+moves complete physical volumes: To move part of a physical volume, use
+\fBpvmove(8)\fP.  Each existing logical volume must be entirely on the physical
+volumes forming either the source or the destination volume group.  For this
+reason, \fBvgsplit(8)\fP may fail with an error if a split would result in a
+logical volume being split across volume groups.
+
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH SEE ALSO
+.BR lvm (8),
+.BR vgcreate (8),
+.BR vgextend (8),
+.BR vgreduce (8),
+.BR vgmerge (8)
--- LVM2/man/Makefile.in	2008/01/09 14:17:58	1.22
+++ LVM2/man/Makefile.in	2008/10/08 12:50:13	1.23
@@ -35,12 +35,25 @@
 MAN5DIR=${mandir}/man5
 MAN8DIR=${mandir}/man8
 
+CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN)
+
 include $(top_srcdir)/make.tmpl
 
 ifneq ("@CLVMD@", "none")
   install: install_cluster
 endif
 
+all: man
+
+.PHONY: man
+
+man: $(MAN5) $(MAN8) $(MAN8CLUSTER)
+
+$(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
+
+%: %.in
+	$(SED) -e "s/#VERSION#/$(LVM_VERSION)/" $< > $@
+
 install:
 	@echo "Installing $(MAN8) in $(MAN8DIR)"
 	@for f in $(MAN8); \


