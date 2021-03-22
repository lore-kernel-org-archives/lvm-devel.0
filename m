From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:58 +0000 (GMT)
Subject: main - configure: use rawhide version
Message-ID: <20210322215358.AB42F3857015@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0993355300fa8490163579a320d1b289c7db59af
Commit:        0993355300fa8490163579a320d1b289c7db59af
Parent:        077040199d98e939446d4b51597eeeae84ae28d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 18:51:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:51:24 2021 +0100

configure: use rawhide version

---
 configure              | 25 ++++++++++++++++++-------
 include/configure.h.in |  3 ---
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/configure b/configure
index 0be9f136c..ff363b046 100755
--- a/configure
+++ b/configure
@@ -868,6 +868,7 @@ infodir
 docdir
 oldincludedir
 includedir
+runstatedir
 localstatedir
 sharedstatedir
 sysconfdir
@@ -1060,6 +1061,7 @@ datadir='${datarootdir}'
 sysconfdir='${prefix}/etc'
 sharedstatedir='${prefix}/com'
 localstatedir='${prefix}/var'
+runstatedir='${localstatedir}/run'
 includedir='${prefix}/include'
 oldincludedir='/usr/include'
 docdir='${datarootdir}/doc/${PACKAGE}'
@@ -1312,6 +1314,15 @@ do
   | -silent | --silent | --silen | --sile | --sil)
     silent=yes ;;
 
+  -runstatedir | --runstatedir | --runstatedi | --runstated \
+  | --runstate | --runstat | --runsta | --runst | --runs \
+  | --run | --ru | --r)
+    ac_prev=runstatedir ;;
+  -runstatedir=* | --runstatedir=* | --runstatedi=* | --runstated=* \
+  | --runstate=* | --runstat=* | --runsta=* | --runst=* | --runs=* \
+  | --run=* | --ru=* | --r=*)
+    runstatedir=$ac_optarg ;;
+
   -sbindir | --sbindir | --sbindi | --sbind | --sbin | --sbi | --sb)
     ac_prev=sbindir ;;
   -sbindir=* | --sbindir=* | --sbindi=* | --sbind=* | --sbin=* \
@@ -1449,7 +1460,7 @@ fi
 for ac_var in	exec_prefix prefix bindir sbindir libexecdir datarootdir \
 		datadir sysconfdir sharedstatedir localstatedir includedir \
 		oldincludedir docdir infodir htmldir dvidir pdfdir psdir \
-		libdir localedir mandir
+		libdir localedir mandir runstatedir
 do
   eval ac_val=\$$ac_var
   # Remove trailing slashes.
@@ -1602,6 +1613,7 @@ Fine tuning of the installation directories:
   --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
   --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
   --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
+  --runstatedir=DIR       modifiable per-process data [LOCALSTATEDIR/run]
   --libdir=DIR            object code libraries [EPREFIX/lib]
   --includedir=DIR        C header files [PREFIX/include]
   --oldincludedir=DIR     C header files for non-gcc [/usr/include]
@@ -12946,12 +12958,12 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$EDITLINE_PKG_ERRORS" >&5
 
-	as_fn_error $? "libedit could not be found which is required for the --enable-readline option." "$LINENO" 5
+	as_fn_error $? "libedit could not be found which is required for the --enable-editline option." "$LINENO" 5
 
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
-	as_fn_error $? "libedit could not be found which is required for the --enable-readline option." "$LINENO" 5
+	as_fn_error $? "libedit could not be found which is required for the --enable-editline option." "$LINENO" 5
 
 else
 	EDITLINE_CFLAGS=$pkg_cv_EDITLINE_CFLAGS
@@ -13406,11 +13418,10 @@ $as_echo "$READLINE" >&6; }
 if test "$EDITLINE" = yes; then
 	for ac_header in editline/readline.h
 do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
+  ac_fn_c_check_header_mongrel "$LINENO" "editline/readline.h" "ac_cv_header_editline_readline_h" "$ac_includes_default"
+if test "x$ac_cv_header_editline_readline_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+#define HAVE_EDITLINE_READLINE_H 1
 _ACEOF
 
 else
diff --git a/include/configure.h.in b/include/configure.h.in
index 59b4da86f..b8d95833a 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -182,9 +182,6 @@
 /* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
 #undef HAVE_DOPRNT
 
-/* Define to 1 if you have the <editline/history.h> header file. */
-#undef HAVE_EDITLINE_HISTORY_H
-
 /* Define to 1 if you have the <editline/readline.h> header file. */
 #undef HAVE_EDITLINE_READLINE_H
 


