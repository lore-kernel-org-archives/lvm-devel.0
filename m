From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 16 Mar 2017 07:37:33 -0400
Subject: master - man: Make dmfilemapd.8 optional
Message-ID: <201703161137.v2GBbXwE004045@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4a6a7a526e1ef43a710fef8330242f95c8e5e34
Commit:        a4a6a7a526e1ef43a710fef8330242f95c8e5e34
Parent:        2fd5c8e908cbb18885d3ddd6ae0e9a3ce5a476d5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Mar 16 12:26:51 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 16 12:26:51 2017 +0100

man: Make dmfilemapd.8 optional

---
 man/Makefile.in |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 6e4c846..e9c7d3d 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -19,6 +19,7 @@ top_builddir = @top_builddir@
 FSADMMAN = fsadm.8
 BLKDEACTIVATEMAN = blkdeactivate.8
 DMEVENTDMAN = dmeventd.8
+DMFILEMAPDMAN = dmfilemapd.8
 LVMETADMAN = lvmetad.8
 LVMPOLLDMAN = lvmpolld.8
 LVMLOCKDMAN = lvmlockd.8 lvmlockctl.8
@@ -40,7 +41,7 @@ MAN8=lvm.8 lvmconf.8 lvmdump.8 lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 \
      vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
      vgrename.8 vgs.8 vgscan.8 vgsplit.8 \
      lvmsar.8 lvmsadc.8 lvmdiskscan.8
-MAN8DM=dmsetup.8 dmstats.8 dmfilemapd.8
+MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
@@ -55,7 +56,7 @@ endif
 
 ifeq ($(MAN_ALL),"yes")
   MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
-  MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN)
+  MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(DMFILEMAPDMAN)
   MAN8CLUSTER+=$(CLVMDMAN) $(CMIRRORDMAN)
   MAN7+=$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMRAIDMAN)
 else
@@ -87,6 +88,10 @@ else
     MAN8DM+=$(DMEVENTDMAN)
   endif
 
+  ifeq ("@DMFILEMAPD@", "yes")
+    MAN8DM+=$(DMFILEMAPDMAN)
+  endif
+
   ifneq ("@CLVMD@", "none")
     MAN8CLUSTER+=$(CLVMDMAN)
   endif
@@ -121,7 +126,8 @@ CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8:%.8_gen=%.8) $(MAN8CLUSTER) \
 	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(MANGENERATOR) $(TESTMAN)
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
 	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
-	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN) $(LVMRAIDMAN)
+	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN) $(LVMRAIDMAN) \
+	$(DMFILEMAPDMAN)
 
 all: man device-mapper
 


