From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 21 Mar 2012 21:40:24 -0400 (EDT)
Subject: [PATCH] fix an error message when running configure
Message-ID: <Pine.LNX.4.64.1203212139410.18255@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix an error reported by configure

This code path calls "$PKG_CONFIG" without initializing the PKG_CONFIG
variable. It results in this error when running ./configure:

"./configure: line 9757: --variable=systemdsystemunitdir: command not found"

The patch changes it so that we try to find pkg_config and initialize
$PKG_CONFIG. If pkg-config isn't found and the variable is still empty,
we don't try to run "$PKG_CONFIG"

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 configure.in |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Index: LVM2.2.02.95/configure.in
===================================================================
--- LVM2.2.02.95.orig/configure.in	2012-03-21 20:02:36.000000000 +0100
+++ LVM2.2.02.95/configure.in	2012-03-21 20:17:38.000000000 +0100
@@ -1208,7 +1208,13 @@ AC_ARG_WITH(systemdsystemunitdir,
 	    AC_HELP_STRING([--with-systemdsystemunitdir=DIR],
 			   [systemd service files in DIR]),
 	    systemdsystemunitdir=$withval,
-	    pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd))
+	    if test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	    fi
+	    if test -n "$PKG_CONFIG"; then
+		pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)
+	    fi
+	    )
 
 if test -n "$pkg_systemdsystemunitdir"; then
 	    systemdsystemunitdir=$pkg_systemdsystemunitdir;


