From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Jul 2013 14:34:06 +0000 (UTC)
Subject: master - configure: more tweaks
Message-ID: <20130703143406.BC89560FB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21cd275b37cafa7605451aeeef3f1f7fae98447a
Commit:        21cd275b37cafa7605451aeeef3f1f7fae98447a
Parent:        6f335ffa35552ed9d002d8a6884c707b2942750c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 3 16:32:23 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 3 16:33:29 2013 +0200

configure: more tweaks

We have to use  lvm_exec_prefix for proper values.
DEFAULT vars needs to be already evaluated.
---
 conf/example.conf.in |    2 +-
 configure            |    4 ++--
 configure.in         |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 3bc8c3c..cb4d3e5 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -25,7 +25,7 @@ config {
     abort_on_errors = 0
 
     # Directory where LVM looks for configuration profiles.
-    profile_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR"
+    profile_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR@"
 }
 
 # This section allows you to configure which block devices should
diff --git a/configure b/configure
index aae8165..fbe92a5 100755
--- a/configure
+++ b/configure
@@ -1639,7 +1639,7 @@ Optional Packages:
   --with-dmeventd-path=PATH
                           dmeventd path [[EPREFIX/sbin/dmeventd]]
   --with-default-system-dir=DIR
-                          default LVM system directory [[/etc/lvm]]
+                          default LVM system directory [[EPREFIX/etc/lvm]]
   --with-default-profile-subdir=SUBDIR
                           default configuration profile subdir [[profile]]
   --with-default-archive-subdir=SUBDIR
@@ -10549,7 +10549,7 @@ fi
 if test "${with_default_system_dir+set}" = set; then :
   withval=$with_default_system_dir; DEFAULT_SYS_DIR=$withval
 else
-  DEFAULT_SYS_DIR='${exec_prefix}/etc/lvm'
+  DEFAULT_SYS_DIR="$lvm_exec_prefix/etc/lvm"
 fi
 
 
diff --git a/configure.in b/configure.in
index 1d62fee..fa31b18 100644
--- a/configure.in
+++ b/configure.in
@@ -1417,7 +1417,7 @@ dnl -- various defaults
 AC_ARG_WITH(default-system-dir,
 	    AC_HELP_STRING([--with-default-system-dir=DIR],
 			   [default LVM system directory [[EPREFIX/etc/lvm]]]),
-	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR='${exec_prefix}/etc/lvm')
+	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR="$lvm_exec_prefix/etc/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
 		   [Path to LVM system directory.])
 


