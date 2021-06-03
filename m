From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 14:39:59 +0000 (GMT)
Subject: main - tests: Support idm failure injection
Message-ID: <20210603143959.976FB3838032@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c7b2df41fdddcd1b1c504522ab79300882eb72f
Commit:        8c7b2df41fdddcd1b1c504522ab79300882eb72f
Parent:        f83e11ff4332ce7ca24f6bfede4fe60c48123700
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Thu Jun 3 17:59:16 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 09:39:32 2021 -0500

tests: Support idm failure injection

When the drive failure occurs, the IDM lock manager and lvmlockd should
handle this case properly.  E.g. when the IDM lock manager detects the
lease renewal failure caused by I/O errors, it should invoke the kill
path which is predefined by lvmlockd, so that the kill path program
(like lvmlockctl) can send requests to lvmlockd to stop and drop lock
for the relevant VG/LVs.

To verify the failure handling flow, this patch introduces an idm
failure injection program, it can input the "percentage" for drive
failures so that can emulate different failure cases.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/Makefile.in              |  5 ++++
 test/lib/idm_inject_failure.c | 55 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/test/Makefile.in b/test/Makefile.in
index 662974be6..573df77a7 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -171,6 +171,7 @@ endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_idm: .tests-stamp
+	$(INSTALL_PROGRAM) lib/idm_inject_failure $(EXECDIR)
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-lvmlockd-idm --only shell/aa-lvmlockd-idm-prepare.sh,$(T),shell/zz-lvmlockd-idm-remove.sh --skip $(S)
@@ -269,6 +270,10 @@ lib/securetest: lib/dmsecuretest.o .lib-dir-stamp
 	@echo "    [CC] $@"
 	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(interfacebuilddir) -ldevmapper $(LIBS)
 
+lib/idm_inject_failure: lib/idm_inject_failure.o .lib-dir-stamp
+	@echo "    [CC] $@"
+	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(LIBS) -lseagate_ilm
+
 lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
 
 CFLAGS_runner.o += $(EXTRA_EXEC_CFLAGS)
diff --git a/test/lib/idm_inject_failure.c b/test/lib/idm_inject_failure.c
new file mode 100644
index 000000000..4998b585a
--- /dev/null
+++ b/test/lib/idm_inject_failure.c
@@ -0,0 +1,55 @@
+/*
+ * Copyright (C) 2020-2021 Seagate Ltd.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#include <errno.h>
+#include <limits.h>
+#include <signal.h>
+#include <stddef.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/inotify.h>
+#include <uuid/uuid.h>
+#include <unistd.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+
+#include <ilm.h>
+
+int main(int argc, char *argv[])
+{
+	int pecent = atoi(argv[1]);
+	int ret, s;
+
+	ret = ilm_connect(&s);
+	if (ret == 0) {
+		printf("ilm_connect: SUCCESS\n");
+	} else {
+		printf("ilm_connect: FAIL\n");
+		exit(-1);
+	}
+
+	ret = ilm_inject_fault(s, pecent);
+	if (ret == 0) {
+		printf("ilm_inject_fault (100): SUCCESS\n");
+	} else {
+		printf("ilm_inject_fault (100): FAIL\n");
+		exit(-1);
+	}
+
+	ret = ilm_disconnect(s);
+	if (ret == 0) {
+		printf("ilm_disconnect: SUCCESS\n");
+	} else {
+		printf("ilm_disconnect: FAIL\n");
+		exit(-1);
+	}
+
+	return 0;
+}


