From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 May 2015 07:36:12 +0000 (UTC)
Subject: master - configure: fix missing [
Message-ID: <20150520073612.5D6C160EFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=682e0c898e7fd96ff936b7113738f773335e0fff
Commit:        682e0c898e7fd96ff936b7113738f773335e0fff
Parent:        788e4c54232372db6551d9a1323e1b59892900c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 20 09:07:49 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 20 09:32:03 2015 +0200

configure: fix missing [

---
 configure    |    2 +-
 configure.in |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 6d5abc4..534948f 100755
--- a/configure
+++ b/configure
@@ -12425,7 +12425,7 @@ else
 fi
 
 
-	if test -z "$MSGFMT"]; then :
+	if test -z "$MSGFMT"; then :
   as_fn_error $? "msgfmt not found in path $PATH" "$LINENO" 5
 fi
 
diff --git a/configure.in b/configure.in
index 75af936..86ab98a 100644
--- a/configure.in
+++ b/configure.in
@@ -1512,7 +1512,7 @@ if test "$INTL" = yes; then
 	INTL_PACKAGE="lvm2"
 	AC_PATH_TOOL(MSGFMT, msgfmt)
 
-	AS_IF(test -z "$MSGFMT"], [AC_MSG_ERROR([msgfmt not found in path $PATH])])
+	AS_IF([test -z "$MSGFMT"], [AC_MSG_ERROR([msgfmt not found in path $PATH])])
 
 	AC_ARG_WITH(localedir,
 		    AC_HELP_STRING([--with-localedir=DIR],


