From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  4 Jul 2013 11:34:22 +0000 (UTC)
Subject: master - configure: revert /etc changes
Message-ID: <20130704113422.BFD3460EA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f88497079778b00fe5ed9a43d890af64d272c325
Commit:        f88497079778b00fe5ed9a43d890af64d272c325
Parent:        2c4f81634f2c53a0ca7a589dbba054ca0c2a4e75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 4 11:52:25 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 4 13:33:41 2013 +0200

configure: revert /etc changes

The idea of using 'eprefix' unfortunatelly fails on /usr moved distros.
But there is also default --sysconfdir which is normaly set to /etc.
If unset it's PREFIX/etc.

For now revert.

FIXME: replace lvm vars with standard ones everyone is using.
---
 configure    |    6 +++---
 configure.in |    8 +++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/configure b/configure
index fbe92a5..12272d1 100755
--- a/configure
+++ b/configure
@@ -1639,7 +1639,7 @@ Optional Packages:
   --with-dmeventd-path=PATH
                           dmeventd path [[EPREFIX/sbin/dmeventd]]
   --with-default-system-dir=DIR
-                          default LVM system directory [[EPREFIX/etc/lvm]]
+                          default LVM system directory [[/etc/lvm]]
   --with-default-profile-subdir=SUBDIR
                           default configuration profile subdir [[profile]]
   --with-default-archive-subdir=SUBDIR
@@ -10066,7 +10066,7 @@ fi
 if test "${with_confdir+set}" = set; then :
   withval=$with_confdir; CONFDIR=$withval
 else
-  CONFDIR='${exec_prefix}/etc'
+  CONFDIR='/etc'
 fi
 
 
@@ -10549,7 +10549,7 @@ fi
 if test "${with_default_system_dir+set}" = set; then :
   withval=$with_default_system_dir; DEFAULT_SYS_DIR=$withval
 else
-  DEFAULT_SYS_DIR="$lvm_exec_prefix/etc/lvm"
+  DEFAULT_SYS_DIR="/etc/lvm"
 fi
 
 
diff --git a/configure.in b/configure.in
index fa31b18..97ddc1d 100644
--- a/configure.in
+++ b/configure.in
@@ -1276,10 +1276,11 @@ if test x$INTL = xyes; then
 fi
 
 ################################################################################
+dnl -- FIXME: need to switch to regular option here  --sysconfdir
 AC_ARG_WITH(confdir,
 	    AC_HELP_STRING([--with-confdir=DIR],
 			   [configuration files in DIR [[/etc]]]),
-	    CONFDIR=$withval, CONFDIR='${exec_prefix}/etc')
+	    CONFDIR=$withval, CONFDIR='/etc')
 
 AC_ARG_WITH(staticdir,
 	    AC_HELP_STRING([--with-staticdir=DIR],
@@ -1414,10 +1415,11 @@ fi
 
 ################################################################################
 dnl -- various defaults
+dnl -- FIXME: need to switch to regular option here  --sysconfdir
 AC_ARG_WITH(default-system-dir,
 	    AC_HELP_STRING([--with-default-system-dir=DIR],
-			   [default LVM system directory [[EPREFIX/etc/lvm]]]),
-	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR="$lvm_exec_prefix/etc/lvm")
+			   [default LVM system directory [[/etc/lvm]]]),
+	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR="/etc/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
 		   [Path to LVM system directory.])
 


