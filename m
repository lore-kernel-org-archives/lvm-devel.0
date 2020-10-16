From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:52 +0000 (GMT)
Subject: stable-2.02 - makefiles: document supported var in make help
Message-ID: <20201016191152.21B97396EC82@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4d3ff352f7d6bef57ffd724f1714c49b8811b66
Commit:        d4d3ff352f7d6bef57ffd724f1714c49b8811b66
Parent:        8a0f9537f14267bae4153deb9160ae2d75623829
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 24 15:14:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

makefiles: document supported var in make help

---
 test/Makefile.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/Makefile.in b/test/Makefile.in
index 2b115b478..97e680020 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -126,6 +126,7 @@ help:
 	@echo "  LVM_VALGRIND_CLVMD	Enable valgrind testing of clvmd (1)."
 	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
 	@echo "  LVM_VALGRIND_LVMETAD	Enable valgrind testing of lvmetad (1)."
+	@echo "  LVM_VALGRIND_LVMPOLLD	Enable valgrind testing of lvmpolld (1)."
 	@echo "  LVM_STRACE		Enable strace logging."
 	@echo "  LVM_DEBUG_LEVEL	Sets debuging level for valgrind/strace (use > 0)."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."


