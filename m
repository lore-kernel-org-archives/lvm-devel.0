From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:55 +0100
Subject: [PATCH 09/15] Readline linking update
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <18eb10c598aadedb47a6733764435b4135a88bf1.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Modify linking of readline library. Create new  substituted varible
READLINE_LIBS - readline library is linked ONLY with tools that really use
it - i.e. lvm. (Static lvm does not use readlin).
Previous behaviour put this library into the variable LIBS and thus
linked it with all created object files of lvm project (i.e. plugins...).

READLINE detection is simplified.
AC_SEARCH_LIBS needs to save/restore LIBS

Extra checking for termcap should not be really needed as the readline
library should have the proper dependencies compiled into the library.
Do we have some cases where we have to figure and link this termcap
library explicitly?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in      |   65 ++++++++++++++++++++++++++++------------------------
 make.tmpl.in      |    1 +
 tools/Makefile.in |    2 +-
 3 files changed, 37 insertions(+), 31 deletions(-)

diff --git a/configure.in b/configure.in
index a973590..aeac331 100644
--- a/configure.in
+++ b/configure.in
@@ -788,24 +788,6 @@ if [[ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ]];
 fi;
 
 ################################################################################
-dnl -- Check for termcap (Shamelessly copied from parted 1.4.17)
-if test x$READLINE != xno; then
-	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
-	  [tg_found=yes], [tg_found=no])
-	test x$READLINE:$tg_found = xyes:no &&
-	  AC_MSG_ERROR(
-termcap could not be found which is required for the
---enable-readline option (which is enabled by default).  Either disable readline
-support with --disable-readline or download and install termcap from:
-	ftp.gnu.org/gnu/termcap
-Note: if you are using precompiled packages you will also need the development
-  package as well (which may be called termcap-devel or something similar).
-Note: (n)curses also seems to work as a substitute for termcap.  This was
-  not found either - but you could try installing that as well.
-)
-fi
-
-################################################################################
 dnl -- Check for dlopen
 AC_CHECK_LIB(dl, dlopen, HAVE_LIBDL=yes, HAVE_LIBDL=no)
 
@@ -887,22 +869,44 @@ AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getop
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
 if test x$READLINE != xno; then
-	rl_found=yes
-	AC_CHECK_LIB([readline], [readline], , [rl_found=no])
-	test x$READLINE:$rl_found = xyes:no &&
-	  AC_MSG_ERROR(
-GNU Readline could not be found which is required for the
+	lvm_saved_libs=$LIBS
+	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
+		READLINE_LIBS=$ac_cv_search_tgetent, [
+		if test "$READLINE" = yes; then
+			AC_MSG_ERROR(
+[termcap could not be found which is required for the
+--enable-readline option (which is enabled by default).  Either disable readline
+support with --disable-readline or download and install termcap from:
+	ftp.gnu.org/gnu/termcap
+Note: if you are using precompiled packages you will also need the development
+  package as well (which may be called termcap-devel or something similar).
+Note: (n)curses also seems to work as a substitute for termcap.  This was
+  not found either - but you could try installing that as well.])
+		fi])
+	dnl -- Old systems may need extra termcap dependency explicitly in LIBS
+	AC_CHECK_LIB([readline], [readline], [
+		AC_DEFINE([READLINE_SUPPORT], 1,
+			[Define to 1 to include the LVM readline shell.])
+		dnl -- Try only with -lreadline and check for different symbol
+		LIBS=$lvm_saved_libs
+		AC_CHECK_LIB([readline], [rl_line_buffer],
+			[ READLINE_LIBS="-lreadline" ], [
+			  AC_MSG_RESULT([linking -lreadline with $READLINE_LIBS needed])
+			  READLINE_LIBS="-lreadline $READLINE_LIBS"
+			]) ], [
+		READLINE_LIBS=
+		if test "$READLINE" = yes; then
+			AC_MSG_ERROR(
+[GNU Readline could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install readline from:
 	ftp.gnu.org/gnu/readline
 Note: if you are using precompiled packages you will also need the development
-package as well (which may be called readline-devel or something similar).
-)
-	if test $rl_found = yes; then
-		AC_CHECK_FUNCS([rl_completion_matches])
-		AC_DEFINE([READLINE_SUPPORT], 1,
-		  [Define to 1 to include the LVM readline shell.])
-	fi
+package as well (which may be called readline-devel or something similar).])
+		fi ])
+	LIBS="$READLINE_LIBS $lvm_saved_libs"
+	AC_CHECK_FUNCS([rl_completion_matches])
+	LIBS=$lvm_saved_libs
 fi
 
 ################################################################################
@@ -1123,6 +1127,7 @@ AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
+AC_SUBST(READLINE_LIBS)
 AC_SUBST(SACKPT_CFLAGS)
 AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
diff --git a/make.tmpl.in b/make.tmpl.in
index 4b3ac17..88be259 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -37,6 +37,7 @@ LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
 LVMINTERNAL_LIBS = -llvm-internal
+READLINE_LIBS = @READLINE_LIBS@
 
 # Setup directory variables
 prefix = @prefix@
diff --git a/tools/Makefile.in b/tools/Makefile.in
index efdf699..236fb4e 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -123,7 +123,7 @@ all: device-mapper
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
-		$(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-- 
1.7.0


