From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Jun 2021 15:35:24 +0000 (GMT)
Subject: main - tests: Fix building for IDM program
Message-ID: <20210616153524.E633D393BC27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27abb03a0d5fb8342741c306b0ce187f41f8e3c1
Commit:        27abb03a0d5fb8342741c306b0ce187f41f8e3c1
Parent:        f25df0386edf6cd80fb577b477069a1705cf4869
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Wed Jun 16 21:44:27 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 16 10:35:12 2021 -0500

tests: Fix building for IDM program

When execute IDM testing, the command reports error:

  /usr/bin/install: cannot stat ???lib/idm_inject_failure???: No such file
  or directory

Since there have a stale program in my local environment, thus Makefile
always uses the stale program and doesn't report any issue.  In the
brand new repository, it doesn't contain an idm_inject_failure program,
and Makefile doesn't build it without specifying the dependency, thus
the test command complaints the file 'idm_inject_failure' is not found.

This patch adds the dependency 'lib/idm_inject_failure' for IDM testing,
so it can firstly build the injection program and dismiss the error.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index cd134129b..5f35c30b8 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -171,7 +171,7 @@ check_lvmlockd_dlm: .tests-stamp
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
-check_lvmlockd_idm: .tests-stamp
+check_lvmlockd_idm: .tests-stamp lib/idm_inject_failure
 	$(INSTALL_PROGRAM) lib/idm_inject_failure $(EXECDIR)
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \


