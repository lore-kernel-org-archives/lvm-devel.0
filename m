From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Oct 2015 22:58:32 +0000 (UTC)
Subject: master - tests: extend timer for 4 hours
Message-ID: <20151026225832.A65CA610E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c301cc5d3840e1badd015164e0dcabfacc8f9599
Commit:        c301cc5d3840e1badd015164e0dcabfacc8f9599
Parent:        ba41ee1dc94264f7ac8e61f8b1d56b10225b0d2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 26 11:04:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 23:57:47 2015 +0100

tests: extend timer for 4 hours

Extend max time for test suite to 4 hours.
Also replace some 'non-ascii' chars from source files
and keep them plain ascii.
---
 aclocal.m4                 |    2 +-
 test/lib/brick-shelltest.h |    9 ++++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 05e0ad5..67b2d59 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -15,7 +15,7 @@ m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun
 # pkg.m4 - Macros to locate and utilise pkg-config.            -*- Autoconf -*-
 # serial 1 (pkg-config-0.24)
 # 
-# Copyright ?? 2004 Scott James Remnant <scott@netsplit.com>.
+# Copyright (c) 2004 Scott James Remnant <scott@netsplit.com>.
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 0659d8e..ccb4fb4 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -17,7 +17,7 @@
  */
 
 /*
- * (c) 2014 Petr Ro??kai <me@mornfall.net>
+ * (c) 2014 Petr Rockai <me@mornfall.net>
  * (c) 2014 Red Hat, Inc.
  */
 
@@ -81,6 +81,9 @@
 
 #include "configure.h"
 
+/*  Timeout for the whole test suite in hours */
+static const unsigned TEST_SUITE_TIMEOUT = 4;
+
 #ifndef BRICK_SHELLTEST_H
 #define BRICK_SHELLTEST_H
 
@@ -1034,8 +1037,8 @@ struct Main {
                 die = 1;
             }
 
-            if ( time(0) - start > 3 * 3600 ) {
-                std::cerr << "3 hours passed, giving up..." << std::endl;
+            if ( time(0) - start > (TEST_SUITE_TIMEOUT * 3600) ) {
+                std::cerr << TEST_SUITE_TIMEOUT << " hours passed, giving up..." << std::endl;
                 die = 1;
             }
 


