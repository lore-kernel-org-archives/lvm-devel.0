From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 17:38:45 -0400
Subject: master - build: support --disable-silent-rules
Message-ID: <201806222138.w5MLcjWL018653@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa58fc32576a08bf11fa98623473f5e6ec5b6d68
Commit:        fa58fc32576a08bf11fa98623473f5e6ec5b6d68
Parent:        c728d88e11ffed97f8a5b96e1c0595a2462c5edc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 22 23:30:42 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 23:36:19 2018 +0200

build: support --disable-silent-rules

Add support for standardized option for have verbose builds.
Useful for distro builds where more details can be useful.
---
 WHATS_NEW    |    1 +
 configure    |   17 +++++++++++++++++
 configure.ac |   10 ++++++++++
 make.tmpl.in |    4 ++++
 4 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a875553..70fb76a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Configure supports --disable-silent-rules for verbose builds.
   Fix unmonitoring of merging snapshots.
   Cache can uses metadata format 2 with cleaner policy.
   Fix check if resized PV can also fit metadata area.
diff --git a/configure b/configure
index 4536b03..7dee110 100755
--- a/configure
+++ b/configure
@@ -643,6 +643,7 @@ DMEVENTD_PIDFILE
 WRITE_INSTALL
 VALGRIND_POOL
 USRSBINDIR
+SILENT_RULES
 USE_TRACKING
 UDEV_HAS_BUILTIN_BLKID
 UDEV_RULE_EXEC_DETECTION
@@ -885,6 +886,7 @@ ac_subst_files=''
 ac_user_opts='
 enable_option_checking
 enable_dependency_tracking
+enable_silent_rules
 enable_static_link
 with_user
 with_group
@@ -1622,6 +1624,7 @@ Optional Features:
   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
   --disable-dependency-tracking
                           speeds up one-time build.
+  --disable-silent-rules  disable silent building
   --enable-static_link    use this to link the tools to their libraries
                           statically (default is dynamic linking
   --disable-thin_check_needs_check
@@ -8044,6 +8047,20 @@ fi
 $as_echo "$USE_TRACKING" >&6; }
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build silently" >&5
+$as_echo_n "checking whether to build silently... " >&6; }
+# Check whether --enable-silent-rules was given.
+if test "${enable_silent_rules+set}" = set; then :
+  enableval=$enable_silent_rules; SILENT_RULES=$enableval
+else
+  SILENT_RULES=yes
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $SILENT_RULES" >&5
+$as_echo "$SILENT_RULES" >&6; }
+
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use static linking" >&5
 $as_echo_n "checking whether to use static linking... " >&6; }
 # Check whether --enable-static_link was given.
diff --git a/configure.ac b/configure.ac
index 05b13e0..c3197b7 100644
--- a/configure.ac
+++ b/configure.ac
@@ -171,6 +171,15 @@ AC_ARG_ENABLE(dependency-tracking,
 AC_MSG_RESULT($USE_TRACKING)
 
 ################################################################################
+dnl -- Disable silence rules
+AC_MSG_CHECKING(whether to build silently)
+AC_ARG_ENABLE(silent-rules,
+	      AC_HELP_STRING([--disable-silent-rules], [disable silent building]),
+	      SILENT_RULES=$enableval, SILENT_RULES=yes)
+AC_MSG_RESULT($SILENT_RULES)
+
+
+################################################################################
 dnl -- Enables statically-linked tools
 AC_MSG_CHECKING(whether to use static linking)
 AC_ARG_ENABLE(static_link,
@@ -1726,6 +1735,7 @@ AC_SUBST(UDEV_SYSTEMD_BACKGROUND_JOBS)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(USE_TRACKING)
+AC_SUBST(SILENT_RULES)
 AC_SUBST(USRSBINDIR)
 AC_SUBST(VALGRIND_POOL)
 AC_SUBST(WRITE_INSTALL)
diff --git a/make.tmpl.in b/make.tmpl.in
index 07cb18a..38fdc73 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -13,6 +13,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+ifneq ("@SILENT_RULES@","yes")
+	V ?= 1
+endif
+
 ifeq ($(V),1)
 	Q=
 else


