From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 11:07:29 +0000 (UTC)
Subject: master - configure: LOCALEDIR needs evaluated value
Message-ID: <20150518110729.0FADD60408@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa2d39c2ca720d9443c2682311945d56ab9a0559
Commit:        aa2d39c2ca720d9443c2682311945d56ab9a0559
Parent:        0cb9df3cec424c7c4e7ea5b198f419f3ef8a8c5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 13:04:07 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 13:06:34 2015 +0200

configure: LOCALEDIR needs evaluated value

Also fix typo.
---
 aclocal.m4              |    4 ++--
 configure               |    2 +-
 configure.in            |    4 ++--
 lib/misc/configure.h.in |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 2325191..05e0ad5 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -1,6 +1,6 @@
-# generated automatically by aclocal 1.14.1 -*- Autoconf -*-
+# generated automatically by aclocal 1.15 -*- Autoconf -*-
 
-# Copyright (C) 1996-2013 Free Software Foundation, Inc.
+# Copyright (C) 1996-2014 Free Software Foundation, Inc.
 
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
diff --git a/configure b/configure
index 3b2b7ba..9cd225a 100755
--- a/configure
+++ b/configure
@@ -12434,7 +12434,7 @@ fi
 if test "${with_localedir+set}" = set; then :
   withval=$with_localedir; LOCALEDIR=$withval
 else
-  LOCALEDIR='${prefix}/share/locale'
+  LOCALEDIR="${prefix}/share/locale"
 fi
 
 
diff --git a/configure.in b/configure.in
index ba0b236..d31c431 100644
--- a/configure.in
+++ b/configure.in
@@ -1517,9 +1517,9 @@ if test "$INTL" = yes; then
 	AC_ARG_WITH(localedir,
 		    AC_HELP_STRING([--with-localedir=DIR],
 				   [translation files in DIR [PREFIX/share/locale]]),
-		    LOCALEDIR=$withval, LOCALEDIR='${prefix}/share/locale')
+		    LOCALEDIR=$withval, LOCALEDIR="${prefix}/share/locale")
 	AC_DEFINE_UNQUOTED([INTL_PACKAGE], ["$INTL_PACKAGE"], [Internalization package])
-	AC_DEFINE_UNQUOTED([LOCALEDIR], ["$LOCALEDIR"], [Location of transaltion files])
+	AC_DEFINE_UNQUOTED([LOCALEDIR], ["$LOCALEDIR"], [Location of translation files])
 fi
 
 ################################################################################
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 2f17190..986b2bc 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -507,7 +507,7 @@
 /* Internalization package */
 #undef INTL_PACKAGE
 
-/* Location of transaltion files */
+/* Location of translation files */
 #undef LOCALEDIR
 
 /* Define to 1 if `lstat' dereferences a symlink specified with a trailing


