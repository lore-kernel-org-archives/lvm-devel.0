From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 00:14:49 +0000 (UTC)
Subject: master - man: Add lvmthin(7).
Message-ID: <20140404001449.1A7C960FBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d2a26f6b6031f275b89a0210a9c5436e006a544
Commit:        6d2a26f6b6031f275b89a0210a9c5436e006a544
Parent:        6c6468f91d9b7a93a85726dfb1b397b555502c1c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 01:14:25 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 01:14:25 2014 +0100

man: Add lvmthin(7).

---
 WHATS_NEW       |    1 +
 man/Makefile.in |   24 ++++++++++++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0a95f3d..70b39c1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add lvmthin man page to section 7.
   Extend internal validation of lv names size is less then 128 chars.
   Fail in resume for lvrename will result in failing command.
   Validate length of new LV name in lvrename to not exceed 127 characters.
diff --git a/man/Makefile.in b/man/Makefile.in
index 72098e6..6c59c8e 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -56,18 +56,26 @@ ifneq ("@CLVMD@", "none")
 else
   MAN8CLUSTER=
 endif
+
 ifeq ("@BUILD_CMIRRORD@", "yes")
   MAN8CLUSTER+=cmirrord.8
 endif
 
+ifneq ("@THIN@", "none")
+  MAN7=lvmthin.7
+else
+  MAN7=
+endif
+
 MAN8DM=dmsetup.8 $(DMEVENTDMAN)
 MAN5DIR=$(mandir)/man5
+MAN7DIR=$(mandir)/man7
 MAN8DIR=$(mandir)/man8
 
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
-CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(MAN8DM)
-DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8
+CLEAN_TARGETS=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(MAN8DM)
+DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8 lvmthin.7 blkdeactivate.8
 
 include $(top_builddir)/make.tmpl
 
@@ -77,13 +85,13 @@ endif
 
 all: man device-mapper
 
-.PHONY: man install_man5 install_man8
+.PHONY: man install_man5 install_man7 install_man8
 
 device-mapper: $(MAN8DM)
 
-man: $(MAN5) $(MAN8) $(MAN8CLUSTER)
+man: $(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER)
 
-$(MAN5) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
+$(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 
 %: %.in
 	@case "$@" in \
@@ -95,11 +103,15 @@ install_man5: $(MAN5)
 	$(INSTALL) -d $(MAN5DIR)
 	$(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
 
+install_man7: $(MAN8)
+	$(INSTALL) -d $(MAN7DIR)
+	$(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
+
 install_man8: $(MAN8)
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8) $(MAN8DIR)/
 
-install_lvm2: install_man5 install_man8
+install_lvm2: install_man5 install_man7 install_man8
 
 install_cluster: $(MAN8CLUSTER)
 	$(INSTALL) -d $(MAN8DIR)


