From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Fri, 17 Jul 2015 18:38:13 +0000 (UTC)
Subject: master - test: Fix hardcoded /usr/share in testsuite
Message-ID: <20150717183813.6899C6017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2bc0525e939ea38c74a814bd51683955599824a3
Commit:        2bc0525e939ea38c74a814bd51683955599824a3
Parent:        85b42d7c9551993f2d9cb48bb84e555ba0af5197
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 14 20:27:31 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jul 17 20:36:50 2015 +0200

test: Fix hardcoded /usr/share in testsuite

---
 configure                  |   14 ++++++++++++++
 configure.in               |   11 +++++++++++
 lib/misc/configure.h.in    |    3 +++
 test/lib/brick-shelltest.h |    2 +-
 4 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 48f5381..139f332 100755
--- a/configure
+++ b/configure
@@ -649,6 +649,7 @@ UDEV_SYNC
 UDEV_RULES
 UDEV_PC
 THIN
+TESTSUITE_DATA
 TESTING
 STATIC_LINK
 STATICDIR
@@ -7351,6 +7352,9 @@ $as_echo "$ac_cv_flag_HAVE_FULL_RELRO" >&6; }
 
 ################################################################################
 
+if test "$prefix" = NONE; then
+  datarootdir=${ac_default_prefix}/share
+fi
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking file owner" >&5
@@ -10813,6 +10817,16 @@ fi
 fi
 
 ################################################################################
+TESTSUITE_DATA='${datarootdir}/lvm2-testsuite'
+# double eval needed ${datarootdir} -> ${prefix}/share -> real path
+
+cat >>confdefs.h <<_ACEOF
+#define TESTSUITE_DATA "$(eval echo $(eval echo $TESTSUITE_DATA))"
+_ACEOF
+
+
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable valgrind awareness of pools" >&5
 $as_echo_n "checking whether to enable valgrind awareness of pools... " >&6; }
 # Check whether --enable-valgrind_pool was given.
diff --git a/configure.in b/configure.in
index ca461af..7bb18a4 100644
--- a/configure.in
+++ b/configure.in
@@ -174,6 +174,9 @@ AC_SUBST(HAVE_FULL_RELRO)
 ################################################################################
 dnl -- Prefix is /usr by default, the exec_prefix default is setup later
 AC_PREFIX_DEFAULT(/usr)
+if test "$prefix" = NONE; then
+  datarootdir=${ac_default_prefix}/share
+fi
 
 ################################################################################
 dnl -- Setup the ownership of the files
@@ -1062,6 +1065,13 @@ if test "$TESTING" = yes; then
 fi
 
 ################################################################################
+dnl -- Set LVM2 testsuite data
+TESTSUITE_DATA='${datarootdir}/lvm2-testsuite'
+# double eval needed ${datarootdir} -> ${prefix}/share -> real path
+AC_DEFINE_UNQUOTED(TESTSUITE_DATA, ["$(eval echo $(eval echo $TESTSUITE_DATA))"], [Path to testsuite data])
+
+
+################################################################################
 dnl -- Enable valgrind awareness of memory pools
 AC_MSG_CHECKING(whether to enable valgrind awareness of pools)
 AC_ARG_ENABLE(valgrind_pool,
@@ -1971,6 +1981,7 @@ AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
 AC_SUBST(TESTING)
+AC_SUBST(TESTSUITE_DATA)
 AC_SUBST(THIN)
 AC_SUBST(THIN_CHECK_CMD)
 AC_SUBST(THIN_DUMP_CMD)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index d9f5a7d..13e8a2d 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -632,6 +632,9 @@
 /* Define to 1 if you have the ANSI C header files. */
 #undef STDC_HEADERS
 
+/* Path to testsuite data */
+#undef TESTSUITE_DATA
+
 /* The path to 'thin_check', if available. */
 #undef THIN_CHECK_CMD
 
diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index e64a166..21e1eec 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -1173,7 +1173,7 @@ static int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVO
     opt.workdir = args.opt( "--workdir" );
 
     if ( opt.testdir.empty() )
-        opt.testdir = "/usr/share/lvm2-testsuite";
+        opt.testdir = TESTSUITE_DATA;
 
     if ( opt.workdir.empty() )
         opt.workdir = opt.testdir;


