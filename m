From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 20 Sep 2022 14:34:32 +0000 (GMT)
Subject: master - make: Fix build in chroot
Message-ID: <20220920143432.87E5138582A2@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0fc61177e1fc39a312c623c4fa3639f8b96f7b2
Commit:        a0fc61177e1fc39a312c623c4fa3639f8b96f7b2
Parent:        178564317a7c47d025ce268abe1bba01d1b4a519
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Sep 20 15:56:13 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Sep 20 15:56:13 2022 +0200

make: Fix build in chroot

When building in a buildroot, must create libexec directory explicitly.
---
 scripts/Makefile.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 9fcff37b0..47b24a2b0 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -57,6 +57,7 @@ install_device-mapper: $(DM_SCRIPTS:.sh=_install)
 install_ocf: $(OCF_SCRIPTS:.ocf=_install)
 
 install_libexec:
+	$(Q) $(INSTALL_DIR) $(libexecdir)
 	$(Q) $(INSTALL_SCRIPT) lvresize_fs_helper.sh $(libexecdir)/lvresize_fs_helper
 
 install: install_lvm2 install_ocf install_device-mapper install_libexec

