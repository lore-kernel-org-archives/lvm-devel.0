From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 18 Dec 2018 03:55:10 -0500
Subject: master - build: Remove reference to undefined @BUILD_LVMETAD@
Message-ID: <201812180855.wBI8tAA3020945@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e0c2d374aeeb77258c3bcdf2bb3ec5a0fca95a97
Commit:        e0c2d374aeeb77258c3bcdf2bb3ec5a0fca95a97
Parent:        07fc4866f040a382c39577fb739e010734d83e42
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Dec 18 09:36:48 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Dec 18 09:54:45 2018 +0100

build: Remove reference to undefined @BUILD_LVMETAD@

---
 libdaemon/Makefile.in |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/libdaemon/Makefile.in b/libdaemon/Makefile.in
index c7fe1d3..4b0a0ad 100644
--- a/libdaemon/Makefile.in
+++ b/libdaemon/Makefile.in
@@ -19,10 +19,7 @@ top_builddir = @top_builddir@
 
 SUBDIRS += client
 
-ifeq (@BUILD_LVMETAD@,yes)
-  SUBDIRS += server
-server: client
-else ifeq (@BUILD_LVMPOLLD@,yes)
+ifeq (@BUILD_LVMPOLLD@,yes)
   SUBDIRS += server
 server: client
 endif


