From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 8 Jul 2018 18:26:18 -0400
Subject: master - build: libdm preload dir is no longer needed
Message-ID: <201807082226.w68MQInn015986@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a55d4b6051ed2edecf14549b8fef437023e1e272
Commit:        a55d4b6051ed2edecf14549b8fef437023e1e272
Parent:        c8b4f9414cf1f7dde8b73c7085e8c3628205b0eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 3 11:12:04 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 00:23:32 2018 +0200

build: libdm preload dir is no longer needed

Since we do not build lvm code with libdm, drop preload.
---
 WHATS_NEW        |    2 ++
 conf/Makefile.in |    4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4919f24..54d6790 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 3.0.0
 =============
+  Never send any discard ioctl with test mode.
+  Fix thin-pool alloc which needs same PV for data and metadata.
   Extend list of non-memlocked areas with newly linked libs.
   Enhance vgcfgrestore to check for active LVs in restored VG.
   Configure supports --disable-silent-rules for verbose builds.
diff --git a/conf/Makefile.in b/conf/Makefile.in
index 5330c07..d47c759 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -32,8 +32,8 @@ include $(top_builddir)/make.tmpl
 .PHONY: install_conf install_localconf install_profiles
 
 generate:
-	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withgeneralpreamble --withcomments --ignorelocal --withspaces > example.conf.in
-	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withlocalpreamble --withcomments --withspaces local > lvmlocal.conf.in
+	$(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withgeneralpreamble --withcomments --ignorelocal --withspaces > example.conf.in
+	$(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withlocalpreamble --withcomments --withspaces local > lvmlocal.conf.in
 
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \


