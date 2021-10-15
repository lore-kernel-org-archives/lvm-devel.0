From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 08:12:13 +0000 (GMT)
Subject: main - makefile: enhance run-unit-test target
Message-ID: <20211015081213.EFFE13857C6E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e2d67378007ee850792396f933900e71f0ea80d
Commit:        2e2d67378007ee850792396f933900e71f0ea80d
Parent:        037165300ea1f6d9c9f8587360792505b2f3988d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 09:45:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 09:55:54 2021 +0200

makefile: enhance run-unit-test target

Use TMPDIR for executing test and also ensure
all libraries linked to the test are from builddir.
---
 test/unit/Makefile | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/test/unit/Makefile b/test/unit/Makefile
index 455c18d2a..5826f41c2 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -54,7 +54,12 @@ $(UNIT_TARGET): $(UNIT_OBJECTS) $(LVMINTERNAL_LIBS)
 unit-test: $(UNIT_TARGET)
 run-unit-test: $(UNIT_TARGET)
 	@echo "Running unit tests"
-	LD_LIBRARY_PATH=$(top_builddir)/libdm $(UNIT_TARGET) run
+	test -n "$$LVM_TEST_DIR" || LVM_TEST_DIR=$${TMPDIR:-/tmp} ;\
+		TESTDIR=$$(mktemp -d -t -p "$$LVM_TEST_DIR" "LVMTEST.XXXXXXXXXX") ;\
+		cd "$$TESTDIR" ;\
+		LD_LIBRARY_PATH=$(abs_top_builddir)/libdm:$(abs_top_builddir)/daemons/dmeventd $(abs_top_builddir)/$(UNIT_TARGET) run ;\
+		cd $$OLDPWD ;\
+		$(RM) -r "$${TESTDIR:?}"
 
 ifeq ("$(DEPENDS)","yes")
 -include $(UNIT_SOURCE:%.c=%.d)


