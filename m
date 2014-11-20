From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 20 Nov 2014 07:24:41 +0000 (UTC)
Subject: master - revert: 7639eae and 4a52a92
Message-ID: <20141120072441.9939360262@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a61c5c5b3a88716697fcebe49c822ad6d5f4f66a
Commit:        a61c5c5b3a88716697fcebe49c822ad6d5f4f66a
Parent:        8d8c1b66241bea0b6b67bde7ebd04b9db10d3208
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 20 08:22:34 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 20 08:22:34 2014 +0100

revert: 7639eae and 4a52a92

Revert 7639eae8919e5872143562db8118d039f5a41225 and
4a52a9212cc5d3ae90196776f28dbfb319002c74. We need a better fix here.
---
 configure                                        |   14 +++++++-------
 configure.in                                     |   14 +++++++-------
 scripts/lvm2_clvmd_systemd_red_hat.service.in    |    2 +-
 scripts/lvm2_cmirrord_systemd_red_hat.service.in |    2 +-
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/configure b/configure
index 42adc6c..a2a094c 100755
--- a/configure
+++ b/configure
@@ -8441,7 +8441,7 @@ $as_echo "$OCF" >&6; }
 if test "${with_ocfdir+set}" = set; then :
   withval=$with_ocfdir; OCFDIR=$withval
 else
-  OCFDIR="${prefix}/lib/ocf/resource.d/lvm2"
+  OCFDIR='${prefix}/lib/ocf/resource.d/lvm2'
 fi
 
 
@@ -11935,7 +11935,7 @@ fi
 if test "${with_localedir+set}" = set; then :
   withval=$with_localedir; LOCALEDIR=$withval
 else
-  LOCALEDIR="${prefix}/share/locale"
+  LOCALEDIR='${prefix}/share/locale'
 fi
 
 fi
@@ -11955,7 +11955,7 @@ fi
 if test "${with_staticdir+set}" = set; then :
   withval=$with_staticdir; STATICDIR=$withval
 else
-  STATICDIR="${exec_prefix}/sbin"
+  STATICDIR='${exec_prefix}/sbin'
 fi
 
 
@@ -11964,7 +11964,7 @@ fi
 if test "${with_usrlibdir+set}" = set; then :
   withval=$with_usrlibdir; usrlibdir=$withval
 else
-  usrlibdir="${prefix}/lib"
+  usrlibdir='${prefix}/lib'
 fi
 
 
@@ -11973,7 +11973,7 @@ fi
 if test "${with_usrsbindir+set}" = set; then :
   withval=$with_usrsbindir; usrsbindir=$withval
 else
-  usrsbindir="${prefix}/sbin"
+  usrsbindir='${prefix}/sbin'
 fi
 
 
@@ -11983,7 +11983,7 @@ fi
 if test "${with_udev_prefix+set}" = set; then :
   withval=$with_udev_prefix; udev_prefix=$withval
 else
-  udev_prefix="${exec_prefix}"
+  udev_prefix='${exec_prefix}'
 fi
 
 
@@ -12019,7 +12019,7 @@ test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
 if test "${with_tmpfilesdir+set}" = set; then :
   withval=$with_tmpfilesdir; tmpfilesdir=$withval
 else
-  tmpfilesdir="${prefix}/lib/tmpfiles.d"
+  tmpfilesdir='${prefix}/lib/tmpfiles.d'
 fi
 
 ################################################################################
diff --git a/configure.in b/configure.in
index 952aef9..d4e367d 100644
--- a/configure.in
+++ b/configure.in
@@ -628,7 +628,7 @@ AC_MSG_RESULT($OCF)
 AC_ARG_WITH(ocfdir,
 	    AC_HELP_STRING([--with-ocfdir=DIR],
 			   [install OCF files in [PREFIX/lib/ocf/resource.d/lvm2]]),
-	    OCFDIR=$withval, OCFDIR="${prefix}/lib/ocf/resource.d/lvm2")
+	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
 
 ################################################################################
 dnl -- Init pkg-config with dummy invokation:
@@ -1438,7 +1438,7 @@ if test "$INTL" = yes; then
 	AC_ARG_WITH(localedir,
 		    AC_HELP_STRING([--with-localedir=DIR],
 				   [translation files in DIR [PREFIX/share/locale]]),
-		    LOCALEDIR=$withval, LOCALEDIR="${prefix}/share/locale")
+		    LOCALEDIR=$withval, LOCALEDIR='${prefix}/share/locale')
 fi
 
 ################################################################################
@@ -1451,23 +1451,23 @@ AC_ARG_WITH(confdir,
 AC_ARG_WITH(staticdir,
 	    AC_HELP_STRING([--with-staticdir=DIR],
 			   [static binaries in DIR [EPREFIX/sbin]]),
-	    STATICDIR=$withval, STATICDIR="${exec_prefix}/sbin")
+	    STATICDIR=$withval, STATICDIR='${exec_prefix}/sbin')
 
 AC_ARG_WITH(usrlibdir,
 	    AC_HELP_STRING([--with-usrlibdir=DIR],
 			   [usrlib in DIR [PREFIX/lib]]),
-	    usrlibdir=$withval, usrlibdir="${prefix}/lib")
+	    usrlibdir=$withval, usrlibdir='${prefix}/lib')
 
 AC_ARG_WITH(usrsbindir,
 	    AC_HELP_STRING([--with-usrsbindir=DIR],
 			   [usrsbin executables in DIR [PREFIX/sbin]]),
-	    usrsbindir=$withval, usrsbindir="${prefix}/sbin")
+	    usrsbindir=$withval, usrsbindir='${prefix}/sbin')
 
 ################################################################################
 AC_ARG_WITH(udev_prefix,
 	    AC_HELP_STRING([--with-udev-prefix=UPREFIX],
 			   [install udev rule files in UPREFIX [EPREFIX]]),
-	    udev_prefix=$withval, udev_prefix="${exec_prefix}")
+	    udev_prefix=$withval, udev_prefix='${exec_prefix}')
 
 AC_ARG_WITH(udevdir,
 	    AC_HELP_STRING([--with-udevdir=DIR],
@@ -1494,7 +1494,7 @@ test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
 AC_ARG_WITH(tmpfilesdir,
 	    AC_HELP_STRING([--with-tmpfilesdir=DIR],
 			   [install configuration files for management of volatile files and directories in DIR [PREFIX/lib/tmpfiles.d]]),
-			   tmpfilesdir=$withval, tmpfilesdir="${prefix}/lib/tmpfiles.d")
+			   tmpfilesdir=$withval, tmpfilesdir='${prefix}/lib/tmpfiles.d')
 ################################################################################
 dnl -- Ensure additional headers required
 if test "$READLINE" = yes; then
diff --git a/scripts/lvm2_clvmd_systemd_red_hat.service.in b/scripts/lvm2_clvmd_systemd_red_hat.service.in
index 2da5114..2978d21 100644
--- a/scripts/lvm2_clvmd_systemd_red_hat.service.in
+++ b/scripts/lvm2_clvmd_systemd_red_hat.service.in
@@ -14,7 +14,7 @@ Conflicts=shutdown.target
 Type=forking
 Environment=CLVMD_OPTS=-T30
 EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
-ExecStart=@usrsbindir@/clvmd $CLVMD_OPTS
+ExecStart=@sbindir@/clvmd $CLVMD_OPTS
 SuccessExitStatus=5
 TimeoutStartSec=30
 TimeoutStopSec=10
diff --git a/scripts/lvm2_cmirrord_systemd_red_hat.service.in b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
index e3bf62d..16d38ce 100644
--- a/scripts/lvm2_cmirrord_systemd_red_hat.service.in
+++ b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
@@ -9,7 +9,7 @@ Conflicts=shutdown.target
 
 [Service]
 Type=forking
-ExecStart=@usrsbindir@/cmirrord
+ExecStart=@sbindir@/cmirrord
 PIDFile=@CMIRRORD_PIDFILE@
 Restart=on-abort
 


