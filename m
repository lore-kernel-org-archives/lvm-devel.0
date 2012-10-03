From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:35 +0000 (UTC)
Subject: master - configure: fix --enable-testing
Message-ID: <20121003131435.B87A92319@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=98bcfdca837c8b56cc355e74672c932c1e8ed735
Commit:        98bcfdca837c8b56cc355e74672c932c1e8ed735
Parent:        886656e4ac5e5c932d9fbe60d18c063136288a38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 1 14:34:07 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 14:59:59 2012 +0200

configure: fix --enable-testing

Add missing pkg init for configure --enable-testing.
---
 WHATS_NEW    |    1 +
 configure    |    3 +++
 configure.in |    3 +++
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dc62d77..1868f99 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Add missing pkg init with --enable-testing in configure.in (2.02.71).
   Fix inability to create, extend or convert to a large (> 1TiB) RAID LV.
   Add (p)artial attribute to lvs.
   Don't try to issue discards to a missing PV to avoid segfault.
diff --git a/configure b/configure
index 52f0e36..13fb6d6 100755
--- a/configure
+++ b/configure
@@ -8704,6 +8704,9 @@ fi
 $as_echo "$TESTING" >&6; }
 
 if test "$TESTING" = yes; then
+	if  test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for CUNIT" >&5
diff --git a/configure.in b/configure.in
index 1c908f9..2bdffca 100644
--- a/configure.in
+++ b/configure.in
@@ -856,6 +856,9 @@ AC_ARG_ENABLE(testing,
 AC_MSG_RESULT($TESTING)
 
 if test "$TESTING" = yes; then
+	if  test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
 	PKG_CHECK_MODULES(CUNIT, cunit >= 2.0)
 fi
 


