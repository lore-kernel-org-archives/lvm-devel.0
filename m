From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 18:49:17 -0400
Subject: master - man: stop installing clvmd man page
Message-ID: <201806142249.w5EMnHfJ023442@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d2b9e5bc6a5a887ab4423caabb4ec43031de662
Commit:        9d2b9e5bc6a5a887ab4423caabb4ec43031de662
Parent:        52e7270e23858509fd0da419ecbc4e42e22f04ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 15 00:46:08 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 15 00:46:08 2018 +0200

man: stop installing clvmd man page

---
 man/Makefile.in |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 844b0ca..aefda2d 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -29,7 +29,6 @@ DMFILEMAPDMAN = dmfilemapd.8
 LVMETADMAN = lvmetad.8
 LVMPOLLDMAN = lvmpolld.8
 LVMLOCKDMAN = lvmlockd.8 lvmlockctl.8
-CLVMDMAN = clvmd.8
 CMIRRORDMAN = cmirrord.8
 LVMCACHEMAN = lvmcache.7
 LVMTHINMAN = lvmthin.7
@@ -63,7 +62,7 @@ endif
 ifeq ($(MAN_ALL),"yes")
   MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(DMFILEMAPDMAN)
-  MAN8CLUSTER+=$(CLVMDMAN) $(CMIRRORDMAN)
+  MAN8CLUSTER+=$(CMIRRORDMAN)
 else
   ifeq ("@FSADM@", "yes")
     MAN8+=$(FSADMMAN)
@@ -97,10 +96,6 @@ else
     MAN8DM+=$(DMFILEMAPDMAN)
   endif
 
-  ifneq ("@CLVMD@", "none")
-    MAN8CLUSTER+=$(CLVMDMAN)
-  endif
-
   ifeq ("@BUILD_CMIRRORD@", "yes")
     MAN8CLUSTER+=$(CMIRRORDMAN)
   endif
@@ -119,7 +114,7 @@ include $(top_builddir)/make.tmpl
 CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8:%.8=%.8_gen) $(MAN8CLUSTER) \
 	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(TESTMAN)
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
-	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
+	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CMIRRORDMAN) \
 	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN) $(LVMRAIDMAN) \
 	$(DMFILEMAPDMAN)
 


