From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 Dec 2010 11:03:12 -0000
Subject: LVM2 ./configure lib/misc/configure.h.in
Message-ID: <20101213110312.3680.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-12-13 11:03:11

Modified files:
	.              : configure 
	lib/misc       : configure.h.in 

Log message:
	Update configure.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/configure	2010/11/09 11:14:06	1.142
+++ LVM2/configure	2010/12/13 11:03:10	1.143
@@ -15440,6 +15440,152 @@
 done
 
 
+for ac_header in selinux/label.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+fi
+
+done
+
+
 cat >>confdefs.h <<\_ACEOF
 #define HAVE_SELINUX 1
 _ACEOF
--- LVM2/lib/misc/configure.h.in	2010/10/13 12:18:53	1.29
+++ LVM2/lib/misc/configure.h.in	2010/12/13 11:03:11	1.30
@@ -252,6 +252,9 @@
 /* Define to 1 to include support for selinux. */
 #undef HAVE_SELINUX
 
+/* Define to 1 if you have the <selinux/label.h> header file. */
+#undef HAVE_SELINUX_LABEL_H
+
 /* Define to 1 if you have the <selinux/selinux.h> header file. */
 #undef HAVE_SELINUX_SELINUX_H
 


