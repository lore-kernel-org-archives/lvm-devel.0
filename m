From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:51 +0000 (GMT)
Subject: main - configure.ac: fix incorrect check for valid configuration
Message-ID: <20230216231051.DEE743858C78@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb4ed5c23d73ac5cfd2cba28147c1dc7df1de47d
Commit:        bb4ed5c23d73ac5cfd2cba28147c1dc7df1de47d
Parent:        c23d09bbcea15d5c639b8347bdf30106dee12660
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 23:35:26 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:00:12 2023 +0100

configure.ac: fix incorrect check for valid configuration

---
 configure.ac | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 78663b5bf..7ce4b8f6a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1251,7 +1251,7 @@ AC_ARG_ENABLE(dbus-service,
 	      AS_HELP_STRING([--enable-dbus-service], [install D-Bus support]),
 	      BUILD_LVMDBUSD=$enableval, BUILD_LVMDBUSD="no")
 AC_MSG_RESULT([$BUILD_LVMDBUSD])
-AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" && test "BUILD_LVMDBUSD" = "yes"],
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = "no" && test "$BUILD_LVMDBUSD" = "yes"],
       [AC_MSG_WARN([Building D-Bus support without D-Bus notifications.])])
 
 ################################################################################

