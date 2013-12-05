From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Dec 2013 11:41:15 +0000 (UTC)
Subject: master - tests: do not run lvmetad tests without lvmetad
Message-ID: <20131205114115.7C25C60D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7b733cd6cbc69e4a681b17ca4e89eb9fcd6d31f
Commit:        c7b733cd6cbc69e4a681b17ca4e89eb9fcd6d31f
Parent:        6f0300de9653063222c536b7cb04784d94787dd0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 5 12:31:49 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 5 12:40:47 2013 +0100

tests: do not run lvmetad tests without lvmetad

Skip tests when lvmetad is not compiled.
---
 test/Makefile.in |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 943a4ce..96c4fdb 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -42,6 +42,11 @@ comma = ,
 RUN = $(shell find $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | sort)
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+LVMETAD_RUN_BASE = $(RUN_BASE)
+endif
+
+
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 
@@ -83,7 +88,7 @@ check: .tests-stamp
 	lvmetad_LVM_TEST_LVMETAD=1 \
 	./lib/harness $(patsubst %,normal:%,$(RUN_BASE)) \
 		      $(patsubst %,cluster:%,$(RUN_BASE)) \
-		      $(patsubst %,lvmetad:%,$(RUN_BASE))
+		      $(patsubst %,lvmetad:%,$(LVMETAD_RUN_BASE))
 
 check_full: .tests-stamp
 	VERBOSE=$(VERBOSE) \
@@ -96,10 +101,10 @@ check_full: .tests-stamp
 	slvmetad_LVM_TEST_DEVDIR=/dev \
 	./lib/harness $(patsubst %,normal:%,$(RUN_BASE)) \
 		      $(patsubst %,cluster:%,$(RUN_BASE)) \
-		      $(patsubst %,lvmetad:%,$(RUN_BASE)) \
+		      $(patsubst %,lvmetad:%,$(LVMETAD_RUN_BASE)) \
 		      $(patsubst %,snormal:%,$(RUN_BASE)) \
 		      $(patsubst %,scluster:%,$(RUN_BASE)) \
-		      $(patsubst %,slvmetad:%,$(RUN_BASE))
+		      $(patsubst %,slvmetad:%,$(LVMETAD_RUN_BASE))
 
 check_cluster: .tests-stamp
 	@echo Testing with locking_type 3
@@ -109,9 +114,11 @@ check_local: .tests-stamp
 	@echo Testing with locking_type 1
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./lib/harness $(RUN_BASE)
 
+ifeq ("@BUILD_LVMETAD@", "yes")
 check_lvmetad: .tests-stamp
 	@echo Testing with lvmetad on
 	VERBOSE=$(VERBOSE) LVM_TEST_LVMETAD=1 ./lib/harness $(RUN_BASE)
+endif
 
 lib/should: lib/not
 	ln -sf not lib/should


