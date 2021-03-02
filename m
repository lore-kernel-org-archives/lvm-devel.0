From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:17 +0000 (GMT)
Subject: main - makefiles: simplify and cleanup
Message-ID: <20210302215817.AFB753950405@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=520bd9356e9ecccfa824ca639c468fdcaf3b34c8
Commit:        520bd9356e9ecccfa824ca639c468fdcaf3b34c8
Parent:        da29afe028c9709b5590a58bd727d1150df6a5ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 28 01:21:12 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: simplify and cleanup

Print all installed man pages with INSTALL
Simplify distclean handling.
---
 man/Makefile.in | 46 +++++++++++++++-------------------------------
 1 file changed, 15 insertions(+), 31 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 3d4569673..6bca8cabc 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -29,14 +29,11 @@ DMFILEMAPDMAN = dmfilemapd.8
 LVMPOLLDMAN = lvmpolld.8
 LVMLOCKDMAN = lvmlockd.8 lvmlockctl.8
 CMIRRORDMAN = cmirrord.8
-LVMCACHEMAN = lvmcache.7
-LVMTHINMAN = lvmthin.7
 LVMDBUSDMAN = lvmdbusd.8
-LVMRAIDMAN = lvmraid.7
-LVMVDOMAN = lvmvdo.7
 
 MAN5=lvm.conf.5
-MAN7=lvmsystemid.7 lvmreport.7 
+MAN7=lvmsystemid.7 lvmreport.7 \
+     lvmcache.7 lvmraid.7 lvmthin.7 lvmvdo.7
 MAN8=lvm.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
      lvcreate.8 lvchange.8 lvmconfig.8 lvconvert.8 lvdisplay.8 \
      lvextend.8 lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
@@ -51,15 +48,7 @@ MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
-ifeq ($(MAKECMDGOALS),all_man)
-  MAN_ALL="yes"
-endif
-
-ifeq ($(MAKECMDGOALS),install_all_man)
-  MAN_ALL="yes"
-endif
-
-ifeq ($(MAN_ALL),"yes")
+ifeq (,$(findstring $(MAKECMDGOALS), distclean all_man install_all_man))
   MAN8+=$(FSADMMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(DMFILEMAPDMAN)
   MAN8CLUSTER+=$(CMIRRORDMAN)
@@ -97,7 +86,6 @@ else
   endif
 endif
 
-MAN7+=$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMRAIDMAN) $(LVMVDOMAN)
 MAN5DIR=$(mandir)/man5
 MAN7DIR=$(mandir)/man7
 MAN8DIR=$(mandir)/man8
@@ -109,10 +97,6 @@ include $(top_builddir)/make.tmpl
 
 CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8:%.8=%.8_gen) $(MAN8CLUSTER) \
 	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(TESTMAN)
-DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
-	$(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CMIRRORDMAN) \
-	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN) $(LVMRAIDMAN) \
-	$(DMFILEMAPDMAN)
 
 all: man device-mapper
 
@@ -223,38 +207,38 @@ $(MAN8SO): lvmconfig.8
 	$(Q) echo ".so $<" > $@
 
 install_man5: $(MAN5)
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] $^"
 	$(Q) $(INSTALL) -d $(MAN5DIR)
-	$(Q) $(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
+	$(Q) $(INSTALL_DATA) $^ $(MAN5DIR)/
 
 install_man7: $(MAN7)
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] $^"
 	$(Q) $(INSTALL) -d $(MAN7DIR)
-	$(Q) $(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
+	$(Q) $(INSTALL_DATA) $^ $(MAN7DIR)/
 
 install_man8: $(MAN8) $(MAN8SO)
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] $^"
 	$(Q) $(INSTALL) -d $(MAN8DIR)
-	$(Q) $(INSTALL_DATA) $(MAN8) $(MAN8SO) $(MAN8DIR)/
+	$(Q) $(INSTALL_DATA) $^ $(MAN8DIR)/
 
 install_lvm2: install_man5 install_man7 install_man8
 
 install_cluster: $(MAN8CLUSTER)
 ifdef MAN8CLUSTER
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] $^"
 	$(Q) $(INSTALL) -d $(MAN8DIR)
-	$(Q) $(INSTALL_DATA) $(MAN8CLUSTER) $(MAN8DIR)/
+	$(Q) $(INSTALL_DATA) $^ $(MAN8DIR)/
 endif
 
 install_device-mapper: $(MAN8DM)
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] $^"
 	$(Q) $(INSTALL) -d $(MAN8DIR)
-	$(Q) $(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
+	$(Q) $(INSTALL_DATA) $^ $(MAN8DIR)/
 
 install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] $^"
 	$(Q) $(INSTALL) -d $(MAN8DIR)
-	$(Q) $(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
+	$(Q) $(INSTALL_DATA) $^ $(MAN8DIR)/
 
 install: install_lvm2 install_device-mapper install_cluster
 


