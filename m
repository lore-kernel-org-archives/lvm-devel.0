From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 16 Jul 2012 09:22:20 +0000 (UTC)
Subject: master - configure: default tmpfile dir in PREFIX/lib/tmpfiles.d
Message-ID: <20120716092220.2E65914E8@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f5cdf20cd65173cc36f765ebe68134299c9cbc8
Commit:        3f5cdf20cd65173cc36f765ebe68134299c9cbc8
Parent:        35ebc5d343e2e01b719ce15c801d522a36e54ac4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 16 11:13:32 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 16 11:17:02 2012 +0200

configure: default tmpfile dir in PREFIX/lib/tmpfiles.d

SYSCONFDIR (the /etc) contains overrides to system-wide settings.
System-wide settings are in PREFIX/lib/tmpfiles.d by default
---
 configure    |    4 ++--
 configure.in |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index e54efd3..ca71fdb 100755
--- a/configure
+++ b/configure
@@ -1613,7 +1613,7 @@ Optional Packages:
                           systemd service files in DIR
   --with-tmpfilesdir=DIR  install configuration files for management of
                           volatile files and directories in DIR
-                          [[SYSCONFDIR/tmpfiles.d]]
+                          [[PREFIX/lib/tmpfiles.d]]
   --with-dmeventd-pidfile=PATH
                           dmeventd pidfile [[PID_DIR/dmeventd.pid]]
   --with-dmeventd-path=PATH
@@ -9925,7 +9925,7 @@ fi
 if test "${with_tmpfilesdir+set}" = set; then :
   withval=$with_tmpfilesdir; tmpfilesdir=$withval
 else
-  tmpfilesdir='${sysconfdir}/tmpfiles.d'
+  tmpfilesdir='${prefix}/lib/tmpfiles.d'
 fi
 
 ################################################################################
diff --git a/configure.in b/configure.in
index 6c27324..8bf0c4e 100644
--- a/configure.in
+++ b/configure.in
@@ -1280,8 +1280,8 @@ fi
 ################################################################################
 AC_ARG_WITH(tmpfilesdir,
 	    AC_HELP_STRING([--with-tmpfilesdir=DIR],
-			   [install configuration files for management of volatile files and directories in DIR [[SYSCONFDIR/tmpfiles.d]]]),
-			   tmpfilesdir=$withval, tmpfilesdir='${sysconfdir}/tmpfiles.d')
+			   [install configuration files for management of volatile files and directories in DIR [[PREFIX/lib/tmpfiles.d]]]),
+			   tmpfilesdir=$withval, tmpfilesdir='${prefix}/lib/tmpfiles.d')
 ################################################################################
 dnl -- Ensure additional headers required
 if test x$READLINE = xyes; then


