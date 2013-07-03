From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Jul 2013 12:48:57 +0000 (UTC)
Subject: master - configure: fix install location of profile dir
Message-ID: <20130703124857.54FDD60FAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ffa11ed35688243a4546d4a35a97fc0339916651
Commit:        ffa11ed35688243a4546d4a35a97fc0339916651
Parent:        eeb164b50f9e5e5ce39f7851fced7c29e1fc0202
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 3 13:07:39 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 3 14:44:51 2013 +0200

configure: fix install location of profile dir

Seems like we have a bit overcomplicated set of options
for deducing individual install dirs.

This patch fixes installation issues with DESTDIR,
but the whole set of configure options should be simplified.
---
 conf/Makefile.in |    4 ++--
 configure        |    4 ++--
 configure.in     |    6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index c148ac2..f9947b1 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -30,8 +30,8 @@ install_conf: $(CONFSRC)
 	fi
 
 install_profiles: $(PROFILES)
-	$(INSTALL) -d $(DEFAULT_PROFILE_DIR)
-	$(INSTALL_DATA) $(PROFILES) $(DEFAULT_PROFILE_DIR)/
+	$(INSTALL_DIR) $(DESTDIR)$(DEFAULT_PROFILE_DIR)
+	$(INSTALL_DATA) $(PROFILES) $(DESTDIR)$(DEFAULT_PROFILE_DIR)/
 
 install_lvm2: install_conf install_profiles
 
diff --git a/configure b/configure
index 212bd80..aae8165 100755
--- a/configure
+++ b/configure
@@ -10066,7 +10066,7 @@ fi
 if test "${with_confdir+set}" = set; then :
   withval=$with_confdir; CONFDIR=$withval
 else
-  CONFDIR="/etc"
+  CONFDIR='${exec_prefix}/etc'
 fi
 
 
@@ -10549,7 +10549,7 @@ fi
 if test "${with_default_system_dir+set}" = set; then :
   withval=$with_default_system_dir; DEFAULT_SYS_DIR=$withval
 else
-  DEFAULT_SYS_DIR="/etc/lvm"
+  DEFAULT_SYS_DIR='${exec_prefix}/etc/lvm'
 fi
 
 
diff --git a/configure.in b/configure.in
index 6d417e3..1d62fee 100644
--- a/configure.in
+++ b/configure.in
@@ -1279,7 +1279,7 @@ fi
 AC_ARG_WITH(confdir,
 	    AC_HELP_STRING([--with-confdir=DIR],
 			   [configuration files in DIR [[/etc]]]),
-	    CONFDIR=$withval, CONFDIR="/etc")
+	    CONFDIR=$withval, CONFDIR='${exec_prefix}/etc')
 
 AC_ARG_WITH(staticdir,
 	    AC_HELP_STRING([--with-staticdir=DIR],
@@ -1416,8 +1416,8 @@ fi
 dnl -- various defaults
 AC_ARG_WITH(default-system-dir,
 	    AC_HELP_STRING([--with-default-system-dir=DIR],
-			   [default LVM system directory [[/etc/lvm]]]),
-	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR="/etc/lvm")
+			   [default LVM system directory [[EPREFIX/etc/lvm]]]),
+	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR='${exec_prefix}/etc/lvm')
 AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
 		   [Path to LVM system directory.])
 


