From: Bastian Germann <bastiangermann@fishpost.de>
Date: Sat, 26 Sep 2020 21:32:55 +0200
Subject: [PATCH] Add readline alternative editline
Message-ID: <20200926193255.3708-1-bastiangermann@fishpost.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

LVM2 is distributed under GPLv2 only. The readline library changed its
license long ago to GPLv3. Given that those licenses are incompatible
and you follow the FSF in their interpretation that dynamically linking
creates a derivative work, distributing LVM2 linked against a current
readline version might be legally problematic.

Add support for the BSD licensed editline library as an alternative for
readline.

Link: https://thrysoee.dk/editline
---
 configure.ac           | 23 +++++++++++++++++++++++
 include/configure.h.in |  9 +++++++++
 lib/mm/memlock.c       |  1 +
 libdm/make.tmpl.in     |  1 +
 make.tmpl.in           |  1 +
 tools/Makefile.in      |  2 +-
 tools/lvm.c            | 21 +++++++++++++--------
 tools/lvmcmdline.c     |  2 +-
 8 files changed, 50 insertions(+), 10 deletions(-)

diff --git a/configure.ac b/configure.ac
index c2a72abf2..3b06e472b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -691,6 +691,12 @@ AC_ARG_ENABLE([readline],
 	      AC_HELP_STRING([--disable-readline], [disable readline support]),
 	      READLINE=$enableval, READLINE=maybe)
 
+################################################################################
+dnl -- Disable editline
+AC_ARG_ENABLE([editline],
+	      AC_HELP_STRING([--enable-editline], [enable editline support]),
+	      EDITLINE=$enableval, EDITLINE=no)
+
 ################################################################################
 dnl -- Disable realtime clock support
 AC_MSG_CHECKING(whether to enable realtime support)
@@ -1378,6 +1384,16 @@ AC_IF_YES(ac_cv_stat_st_ctim,
 dnl -- Check for getopt
 AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getopt_long is available.]))
 
+################################################################################
+dnl -- Check for editline
+if test "$EDITLINE" == yes; then
+	PKG_CHECK_MODULES([EDITLINE], [libedit], [
+		AC_DEFINE([EDITLINE_SUPPORT], 1,
+			[Define to 1 to include the LVM editline shell.])], AC_MSG_ERROR(
+[libedit could not be found which is required for the --enable-readline option.])
+	)
+fi
+
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
 if test "$READLINE" != no; then
@@ -1510,6 +1526,12 @@ fi
 AC_MSG_CHECKING(whether to enable readline)
 AC_MSG_RESULT($READLINE)
 
+if test "$EDITLINE" = yes; then
+	AC_CHECK_HEADERS(editline/readline.h editline/history.h,,hard_bailout)
+fi
+AC_MSG_CHECKING(whether to enable editline)
+AC_MSG_RESULT($EDITLINE)
+
 if test "$BUILD_CMIRRORD" = yes; then
 	AC_CHECK_FUNCS(atexit,,hard_bailout)
 fi
@@ -1765,6 +1787,7 @@ AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RT_LIBS)
 AC_SUBST(READLINE_LIBS)
+AC_SUBST(EDITLINE_LIBS)
 AC_SUBST(REPLICATORS)
 AC_SUBST(SACKPT_CFLAGS)
 AC_SUBST(SACKPT_LIBS)
diff --git a/include/configure.h.in b/include/configure.h.in
index 540cee7cf..46d5aef20 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -126,6 +126,9 @@
 /* Library version */
 #undef DM_LIB_VERSION
 
+/* Define to 1 to include the LVM editline shell. */
+#undef EDITLINE_SUPPORT
+
 /* Path to fsadm binary. */
 #undef FSADM_PATH
 
@@ -176,6 +179,12 @@
 /* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
 #undef HAVE_DOPRNT
 
+/* Define to 1 if you have the <editline/history.h> header file. */
+#undef HAVE_EDITLINE_HISTORY_H
+
+/* Define to 1 if you have the <editline/readline.h> header file. */
+#undef HAVE_EDITLINE_READLINE_H
+
 /* Define to 1 if you have the <errno.h> header file. */
 #undef HAVE_ERRNO_H
 
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index b06bbc82c..883795d28 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -122,6 +122,7 @@ static const char * const _blacklist_maps[] = {
 	"/libpcre.so.",		/* not using pcre during mlock (selinux) */
 	"/libpcre2-",		/* not using pcre during mlock (selinux) */
 	"/libreadline.so.",	/* not using readline during mlock */
+	"/libedit.so.",		/* not using editline during mlock */
 	"/libresolv-",		/* not using during mlock (udev) */
 	"/libselinux.so.",	/* not using selinux during mlock */
 	"/libsepol.so.",	/* not using sepol during mlock */
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 9041da52e..aaf8a5e77 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -71,6 +71,7 @@ RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
+EDITLINE_LIBS = @EDITLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
 UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
diff --git a/make.tmpl.in b/make.tmpl.in
index 8a2081897..4549746ab 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -77,6 +77,7 @@ RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
+EDITLINE_LIBS = @EDITLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
 UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 2620daa17..11160e655 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -122,7 +122,7 @@ CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
 lvm: $(OBJECTS) lvm.o $(LVMINTERNAL_LIBS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $+ \
-		$(DMEVENT_LIBS) $(READLINE_LIBS) $(LVMLIBS)
+		$(DMEVENT_LIBS) $(READLINE_LIBS) $(EDITLINE_LIBS) $(LVMLIBS)
 
 DEFS_man-generator.o += -DMAN_PAGE_GENERATOR
 
diff --git a/tools/lvm.c b/tools/lvm.c
index 4bfa6f5c2..79b1210af 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -22,13 +22,18 @@ int main(int argc, char **argv)
 	return lvm2_main(argc, argv);
 }
 
-#ifdef READLINE_SUPPORT
-
-#  include <readline/readline.h>
-#  include <readline/history.h>
-#  ifndef HAVE_RL_COMPLETION_MATCHES
-#    define rl_completion_matches(a, b) completion_matches((char *)a, b)
-#    define rl_completion_func_t CPPFunction
+#if defined(READLINE_SUPPORT) || defined(EDITLINE_SUPPORT)
+
+#  ifdef READLINE_SUPPORT
+#    include <readline/readline.h>
+#    include <readline/history.h>
+#    ifndef HAVE_RL_COMPLETION_MATCHES
+#      define rl_completion_matches(a, b) completion_matches((char *)a, b)
+#      define rl_completion_func_t CPPFunction
+#    endif
+#  elif defined(EDITLINE_SUPPORT)
+#    include <editline/readline.h>
+#    include <editline/history.h>
 #  endif
 
 static struct cmdline_context *_cmdline;
@@ -348,4 +353,4 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	return 0;
 }
 
-#endif	/* READLINE_SUPPORT */
+#endif	/* READLINE_SUPPORT || EDITLINE_SUPPORT */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 8dd38e51d..e8d732878 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3646,7 +3646,7 @@ int lvm2_main(int argc, char **argv)
 	}
 
 	if (run_shell) {
-#ifdef READLINE_SUPPORT
+#if defined(READLINE_SUPPORT) || defined(EDITLINE_SUPPORT)
 		_nonroot_warning();
 		if (!_prepare_profiles(cmd)) {
 			ret = ECMD_FAILED;
-- 
2.28.0


