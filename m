From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:44 +0000 (UTC)
Subject: dev-peter-config-profiles - configure: add configure --with-default-profile-subdir
Message-ID: <20130626145544.1A0C360F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f15a403a256f033d18bd53f8d155cb2686e02a1c
Commit:        f15a403a256f033d18bd53f8d155cb2686e02a1c
Parent:        6c2bda4b433c55e0af05124f5157977621b93f50
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:26:40 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:49 2013 +0200

configure: add configure --with-default-profile-subdir

Configuration profiles are selected configuration items that can
be loaded dynamically on demand and overlayed over existing
configuration on demand (either on cmd line by selecting the profile
name to be used globally or retrieved from metadata and used per
VG/LV basis only).

The default directory where profiles are stored is configurable
at compile time with --with-default-profile-subdir.
---
 configure               |   17 +++++++++++++++++
 configure.in            |    7 +++++++
 lib/misc/configure.h.in |    3 +++
 3 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index e8ef786..01cde6b 100755
--- a/configure
+++ b/configure
@@ -873,6 +873,7 @@ with_tmpfilesdir
 with_dmeventd_pidfile
 with_dmeventd_path
 with_default_system_dir
+with_default_profile_subdir
 with_default_archive_subdir
 with_default_backup_subdir
 with_default_cache_subdir
@@ -1638,6 +1639,8 @@ Optional Packages:
                           dmeventd path [[EPREFIX/sbin/dmeventd]]
   --with-default-system-dir=DIR
                           default LVM system directory [[/etc/lvm]]
+  --with-default-profile-subdir=SUBDIR
+                          default configuration profile subdir [[profile]]
   --with-default-archive-subdir=SUBDIR
                           default metadata archive subdir [[archive]]
   --with-default-backup-subdir=SUBDIR
@@ -10555,6 +10558,20 @@ _ACEOF
 
 
 
+# Check whether --with-default-profile-subdir was given.
+if test "${with_default_profile_subdir+set}" = set; then :
+  withval=$with_default_profile_subdir; DEFAULT_PROFILE_SUBDIR=$withval
+else
+  DEFAULT_PROFILE_SUBDIR=profile
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_PROFILE_SUBDIR "$DEFAULT_PROFILE_SUBDIR"
+_ACEOF
+
+
+
 # Check whether --with-default-archive-subdir was given.
 if test "${with_default_archive_subdir+set}" = set; then :
   withval=$with_default_archive_subdir; DEFAULT_ARCHIVE_SUBDIR=$withval
diff --git a/configure.in b/configure.in
index b286358..0ad28a6 100644
--- a/configure.in
+++ b/configure.in
@@ -1421,6 +1421,13 @@ AC_ARG_WITH(default-system-dir,
 AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
 		   [Path to LVM system directory.])
 
+AC_ARG_WITH(default-profile-subdir,
+	    AC_HELP_STRING([--with-default-profile-subdir=SUBDIR],
+			   [default configuration profile subdir [[profile]]]),
+	    DEFAULT_PROFILE_SUBDIR=$withval, DEFAULT_PROFILE_SUBDIR=profile)
+AC_DEFINE_UNQUOTED(DEFAULT_PROFILE_SUBDIR, ["$DEFAILT_PROFILE_SUBDIR"],
+		   [Name of default configuration profile subdirectory.])
+
 AC_ARG_WITH(default-archive-subdir,
 	    AC_HELP_STRING([--with-default-archive-subdir=SUBDIR],
 			   [default metadata archive subdir [[archive]]]),
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index fdc5a26..aae4f24 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -53,6 +53,9 @@
 /* Default directory to keep PID files in. */
 #undef DEFAULT_PID_DIR
 
+/* Name of default configuration profile subdirectory. */
+#undef DEFAULT_PROFILE_SUBDIR
+
 /* Default LVM run directory. */
 #undef DEFAULT_RUN_DIR
 


