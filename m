From: Leo Yan <leo.yan@linaro.org>
Date: Wed, 16 Jun 2021 21:44:27 +0800
Subject: [PATCH] tests: Fix building for IDM program
Message-ID: <20210616134427.337332-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When execute IDM testing, the command reports error:

  /usr/bin/install: cannot stat ?lib/idm_inject_failure?: No such file
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
-- 
2.25.1


