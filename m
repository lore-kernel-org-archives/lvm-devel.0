From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:54 +0000 (GMT)
Subject: main - makefiles: add pthread to libdevmapper pkgconfig
Message-ID: <20230223154854.977563858C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d91bc6904dce256b06687217ec66caba15b33a7a
Commit:        d91bc6904dce256b06687217ec66caba15b33a7a
Parent:        e0c95f15a7a859ee41a6561cae1e53c17a23a0c3
Author:        David Seifert <soap@gentoo.org>
AuthorDate:    Wed Feb 22 13:10:16 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

makefiles: add pthread to libdevmapper pkgconfig

Add pthread to pkg_config file.
---
 libdm/libdevmapper.pc.in | 2 +-
 make.tmpl.in             | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.pc.in b/libdm/libdevmapper.pc.in
index a325aeb9e..aa0980378 100644
--- a/libdm/libdevmapper.pc.in
+++ b/libdm/libdevmapper.pc.in
@@ -9,4 +9,4 @@ Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
 Requires.private: @SELINUX_PC@ @UDEV_PC@
-Libs.private: -lm @RT_LIBS@
+Libs.private: -lm @RT_LIBS@ @PTHREAD_LIBS@
diff --git a/make.tmpl.in b/make.tmpl.in
index b73176f5a..df4c5850d 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -59,7 +59,7 @@ PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 LIBS += @LIBS@ $(SELINUX_LIBS) $(UDEV_LIBS) $(RT_LIBS) $(M_LIBS)
 LVMLIBS = $(DMEVENT_LIBS) $(READLINE_LIBS) $(EDITLINE_LIBS) $(LIBSYSTEMD_LIBS) $(BLKID_LIBS) $(AIO_LIBS) $(LIBS)
 # Extra libraries always linked with static binaries
-STATIC_LIBS = $(PTHREAD_LIBS)
+STATIC_LIBS = $(PTHREAD_LIBS) $(SELINUX_STATIC_LIBS) $(UDEV_STATIC_LIBS) $(BLKID_STATIC_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@

