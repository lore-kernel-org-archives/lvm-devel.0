From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:41 +0000 (UTC)
Subject: master - test: Build the new test runner.
Message-ID: <20150205134041.6B092602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ec2023cbfe40d285a9da55f029fcf173c763b88
Commit:        1ec2023cbfe40d285a9da55f029fcf173c763b88
Parent:        9d6a92b4d08827c2d3e6c7f57570830ef0b44e8d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 8 18:24:33 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:16 2015 +0100

test: Build the new test runner.

---
 test/Makefile.in |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 1aec88b..e2f2cb8 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -37,6 +37,8 @@ export LVM_TEST_CACHE_RESTORE_CMD?=@CACHE_RESTORE_CMD@
 
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
+CXXSOURCES = lib/runner.cpp
+CXXFLAGS = -std=c++11
 
 include $(top_builddir)/make.tmpl
 
@@ -141,6 +143,9 @@ lib/fail: lib/not
 	ln -sf not lib/fail
 
 
+lib/runner: lib/runner.o .lib-dir-stamp
+	$(CXX) $(LDFLAGS) -o $@ $<
+
 lib/%: lib/%.o .lib-dir-stamp
 	$(CC) $(LDFLAGS) -o $@ $<
 
@@ -174,7 +179,7 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 
 LIB = lib/not lib/invalid lib/fail lib/should lib/harness \
       lib/check lib/aux lib/inittest lib/utils lib/get lib/lvm-wrapper \
-      lib/paths
+      lib/paths lib/runner
 
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 


