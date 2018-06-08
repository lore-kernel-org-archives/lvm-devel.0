From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:39:10 -0400
Subject: master - tests: drop unit subdir
Message-ID: <201806081239.w58CdAaU006123@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f20e828ec2c6ef6fbd6a271ecbf904a8e7943958
Commit:        f20e828ec2c6ef6fbd6a271ecbf904a8e7943958
Parent:        bb7c064b23c90e32ab4e8da610fca2c4e7bac73e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 8 12:37:57 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:37:31 2018 +0200

tests: drop unit subdir

Until we resolve top-level making, drop inclusion of subdir Makefile
written for top-level usage so at least integrational tests are running.
---
 test/Makefile.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 2b115b4..65ba900 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -27,7 +27,8 @@ datarootdir = @datarootdir@
 
 LVM_TEST_RESULTS ?= results
 
-SUBDIRS = api unit
+SUBDIRS = api
+# FIXME: resolve testing of: unit
 SOURCES = lib/not.c lib/harness.c
 CXXSOURCES = lib/runner.cpp
 CXXFLAGS += $(EXTRA_EXEC_CFLAGS)


