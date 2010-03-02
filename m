From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:23 +0100
Subject: [PATCH 5/9] Readline linking update
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com>
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <bdb08db9e0a69fca22366f1fb7936fd75e5110fc.1267529065.git.zkabelac@redhat.com>
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
 configure.in      |   39 +++++++++++++++++++++------------------
 tools/Makefile.in |    2 +-
 2 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/configure.in b/configure.in
index 4053f7f..a9850a2 100644
--- a/configure.in
+++ b/configure.in
@@ -790,19 +790,21 @@ fi;
 ################################################################################
 dnl -- Check for termcap (Shamelessly copied from parted 1.4.17)
 if test x$READLINE != xno; then
+	lvm_saved_libs=$LIBS
 	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
-	  [tg_found=yes], [tg_found=no])
-	test x$READLINE:$tg_found = xyes:no &&
-	  AC_MSG_ERROR(
-termcap could not be found which is required for the
+		READLINE_LIBS=$ac_cv_search_tgetent, [
+		if test "$READLINE" = yes; then
+			AC_MSG_ERROR(
+[termcap could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install termcap from:
 	ftp.gnu.org/gnu/termcap
 Note: if you are using precompiled packages you will also need the development
   package as well (which may be called termcap-devel or something similar).
 Note: (n)curses also seems to work as a substitute for termcap.  This was
-  not found either - but you could try installing that as well.
-)
+  not found either - but you could try installing that as well.])
+		fi])
+	LIBS=$lvm_saved_libs
 fi
 
 ################################################################################
@@ -887,22 +889,22 @@ AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getop
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
 if test x$READLINE != xno; then
-	rl_found=yes
-	AC_CHECK_LIB([readline], [readline], , [rl_found=no])
-	test x$READLINE:$rl_found = xyes:no &&
-	  AC_MSG_ERROR(
-GNU Readline could not be found which is required for the
+	AC_CHECK_LIB([readline], [readline], [
+		READLINE_LIBS="-lreadline $READLINE_LIBS"
+		lvm_save_LIBS=$LIBS
+		LIBS="$READLINE_LIBS $LIBS"
+		AC_CHECK_FUNCS([rl_completion_matches])
+		LIBS=$lvm_save_LIBS
+		AC_DEFINE([READLINE_SUPPORT], 1, [Define to 1 to include the LVM readline shell.])],[
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
+                fi])
 fi
 
 ################################################################################
@@ -1123,6 +1125,7 @@ AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
+AC_SUBST(READLINE_LIBS)
 AC_SUBST(SACKPT_CFLAGS)
 AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
diff --git a/tools/Makefile.in b/tools/Makefile.in
index b650c67..07fd4a6 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -123,7 +123,7 @@ all: device-mapper
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
-		$(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+		$(LVMLIBS) @READLINE_LIBS@ $(LIBS) $(LIB_PTHREAD) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-- 
1.7.0


