From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 28 Mar 2017 19:43:23 -0400
Subject: master - man: simplify by avoiding different headers on de-duplication of lvmconfig, lvm-config and lvm-dumpcong
Message-ID: <201703282343.v2SNhNqA016556@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=258817a01e0940776e45243da97bddef564f0613
Commit:        258817a01e0940776e45243da97bddef564f0613
Parent:        6742137964757356ec25b8daad86d71ea0dbe357
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 29 01:36:39 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 29 01:36:39 2017 +0200

man: simplify by avoiding different headers on de-duplication of lvmconfig, lvm-config and lvm-dumpcong

---
 man/Makefile.in     |   36 ++++++------------------------------
 man/lvmconfig.8_des |    2 +-
 2 files changed, 7 insertions(+), 31 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 105512c..e357d86 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -41,7 +41,7 @@ MAN8=lvm.8 lvmconf.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
      vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
      vgrename.8 vgs.8 vgscan.8 vgsplit.8 \
      lvmsar.8 lvmsadc.8 lvmdiskscan.8
-MAN8SO=lvmconfig-common.8 lvmconfig.8.tmp lvm-config.8 lvm-dumpconfig.8
+MAN8SO=lvm-config.8 lvm-dumpconfig.8
 MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
@@ -208,17 +208,6 @@ $(SED) -i -e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([0-9]\)-\([0-9]\)+\1\\\-\2+g" \
 	  -e "s+\(\\\f.\)-\([^-]\)+\1\\\-\2+g" \
 	  -e "s+\([[:digit:]]\{4\}\)\\\-\([[:digit:]]\{2\}\)\\\-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
-
-endef
-
-define LVMCONFIGHEADER
-	echo ".TH $(1) 8 \"LVM TOOLS #VERSION#\" \"Red Hat, Inc.\"" | $(SED) -e "s+#VERSION#+$(LVM_VERSION)+" > $@
-	echo ".SH NAME\n" >> $@
-	echo "$(2) \\- Display and manipulate configuration information\n" >> $@
-	echo ".\n" >> $@
-	echo ".SH SYNOPSIS\n" >> $@
-	echo "\\fB$(2)\\fP\n" >> $@
-	echo ".so $<" >> $@
 endef
 
 %.5: $(srcdir)/%.5_main
@@ -237,21 +226,8 @@ endef
 	$(SUBSTVARS)
 	$(ESCAPEHYPHENS)
 
-# Create lvmconfig-common.8 to be shared by lvmconfig.8, lvm-config.8 and lvm.dumpconfig.8
-lvmconfig-common.8: lvmconfig.8
-	$(SED) -e "1,6d" $< > $@
-
-# Create headers for lvmconfig, lvm-config and lvm.dumpconfig and share lvmconfig-common.8
-# Needs temporary target to avoid conflict with %8: target above
-lvmconfig.8.tmp: lvmconfig-common.8
-	$(call LVMCONFIGHEADER,LVMCONFIG,lvmconfig)
-	mv $@ $(@:%.8.tmp=%.8)
-
-lvm-config.8: lvmconfig-common.8
-	$(call LVMCONFIGHEADER,LVM-CONFIG,lvm config)
-
-lvm-dumpconfig.8: lvmconfig-common.8
-	$(call LVMCONFIGHEADER,LVM-DUMPCONFIG,lvm dumpconfig)
+lvm-config.8 lvm-dumpconfig.8: lvmconfig.8
+	echo ".so $<" > $@
 
 install_man5: $(MAN5)
 	$(INSTALL) -d $(MAN5DIR)
@@ -261,9 +237,9 @@ install_man7: $(MAN7)
 	$(INSTALL) -d $(MAN7DIR)
 	$(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
 
-install_man8: $(MAN8) $(MAN8GENERATED)
+install_man8: $(MAN8) $(MAN8SO)
 	$(INSTALL) -d $(MAN8DIR)
-	$(INSTALL_DATA) $(MAN8) $(MAN8GENERATED) $(MAN8DIR)/
+	$(INSTALL_DATA) $(MAN8) $(MAN8SO) $(MAN8DIR)/
 
 install_lvm2: install_man5 install_man7 install_man8
 
@@ -277,7 +253,7 @@ install_device-mapper: $(MAN8DM)
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
 
-install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
+install_systemdgenerators: $(MAN8SYSTEMD_GENERATORS)
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
 
diff --git a/man/lvmconfig.8_des b/man/lvmconfig.8_des
index 2398759..826888d 100644
--- a/man/lvmconfig.8_des
+++ b/man/lvmconfig.8_des
@@ -1,4 +1,4 @@
-lvmconfig, lvm dumpconfig, lvm config produce
+lvmconfig, lvm config, lvm dumpconfig (for compatibility reasons, to be phased out) produce
 formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
 line settings from --config.


