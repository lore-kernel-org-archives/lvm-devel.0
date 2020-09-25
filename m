From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:08 +0000 (GMT)
Subject: master - makefiles: document supported var in make help
Message-ID: <20200925210708.591923971C47@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2577c037da84442d5afa125772882c6d5caf8de
Commit:        e2577c037da84442d5afa125772882c6d5caf8de
Parent:        e414ebef6ece7c89f539f3ca01ad45a0c021575f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 24 15:14:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:59:35 2020 +0200

makefiles: document supported var in make help

---
 test/Makefile.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/Makefile.in b/test/Makefile.in
index 9fa908e52..bbdde7196 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -111,6 +111,7 @@ help:
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
 	@echo "  LVM_VALGRIND		Enable valgrind testing, execs $$"VALGRIND.
 	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
+	@echo "  LVM_VALGRIND_LVMPOLLD	Enable valgrind testing of lvmpolld (1)."
 	@echo "  LVM_STRACE		Enable strace logging."
 	@echo "  LVM_DEBUG_LEVEL	Sets debuging level for valgrind/strace (use > 0)."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."


