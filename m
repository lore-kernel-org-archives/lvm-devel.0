From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 26 Jun 2015 20:17:43 +0000 (UTC)
Subject: master - makefiles: avoid bash == operator syntax, use = instead
Message-ID: <20150626201743.A4953600C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a62cd64db6c65637f2f2125222962696a7c7c5ee
Commit:        a62cd64db6c65637f2f2125222962696a7c7c5ee
Parent:        844707067b5aef9bbcdf169b66a25bb79690d325
Author:        Ferenc W??gner <wferi@niif.hu>
AuthorDate:    Fri Jun 26 09:00:16 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 26 22:11:45 2015 +0200

makefiles: avoid bash == operator syntax, use = instead

Commit e587b0677b705786a78f21bac1966621f70b2752 broke the build on
systems where /bin/sh is Dash, for example.

Origin patch by Ferenc W??gner <wferi@niif.hu>  changed later to
avoid using shell call, so makefile add 'server' target when
one of  metad or polld daemon is requested.
---
 WHATS_NEW             |    1 +
 libdaemon/Makefile.in |    7 +++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8f14bef..813eb5e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.123 - 
 =================================
+  Fix makefile shell compare == when building lvmetad lvmpolld (2.02.120).
   Add --type full to lvmconfig for full configuration tree view.
   Add undocumented environment variables to lvm man page. (2.02.119)
   Add device synchronization point before activating a new snapshot.
diff --git a/libdaemon/Makefile.in b/libdaemon/Makefile.in
index c0379a4..0a085db 100644
--- a/libdaemon/Makefile.in
+++ b/libdaemon/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -19,7 +19,10 @@ top_builddir = @top_builddir@
 
 SUBDIRS += client
 
-ifeq (yes, $(shell test @BUILD_LVMETAD@ == yes -o @BUILD_LVMPOLLD@ == yes && echo yes))
+ifeq (@BUILD_LVMETAD@,yes)
+  SUBDIRS += server
+server: client
+else ifeq (@BUILD_LVMPOLLD@,yes)
   SUBDIRS += server
 server: client
 endif


