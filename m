From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 6 Dec 2018 04:53:02 -0500
Subject: master - udev: 69-dm-lvm-metad.rules is still needed
Message-ID: <201812060953.wB69r2rO027908@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21784e94d6f4308931fa497679f1a4e5e1966578
Commit:        21784e94d6f4308931fa497679f1a4e5e1966578
Parent:        92b0d014aab12eee3fe1f757a5fb9ecfe9f4b58c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Dec 6 10:50:42 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 6 10:50:42 2018 +0100

udev: 69-dm-lvm-metad.rules is still needed

---
 spec/packages.inc |    1 +
 udev/Makefile.in  |    5 +----
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 0be4f2e..81ef539 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -150,6 +150,7 @@ fi
 %endif
 %if %{enable_udev}
  %{_udevdir}/11-dm-lvm.rules
+ %{_udevdir}/69-dm-lvm-metad.rules
 %endif
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 81c2c7b..e32cba9 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -18,10 +18,7 @@ top_builddir = @top_builddir@
 include $(top_builddir)/make.tmpl
 
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
-LVM_RULES=11-dm-lvm.rules
-ifeq ("@BUILD_LVMETAD@", "yes")
-LVM_RULES+=69-dm-lvm-metad.rules
-endif
+LVM_RULES=11-dm-lvm.rules 69-dm-lvm-metad.rules
 
 DM_DIR=$(shell $(GREP) "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
 


