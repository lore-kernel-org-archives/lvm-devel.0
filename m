From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 30 Jul 2015 14:15:55 +0000 (UTC)
Subject: dev-bmr-dmstats-test - tools: add 'dmstats' to install targets in Makefile.in
Message-ID: <20150730141555.12CEB610E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5847d21bbe6b6328e7c921c08b6d6f6cffc5c7a
Commit:        d5847d21bbe6b6328e7c921c08b6d6f6cffc5c7a
Parent:        8ffc93139ee301919bb77df7386f7fa88ee29143
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 30 15:15:33 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Jul 30 15:15:33 2015 +0100

tools: add 'dmstats' to install targets in Makefile.in

---
 tools/Makefile.in |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index cec74a9..0a6069e 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -79,9 +79,10 @@ TARGETS =\
 	lvm
 
 TARGETS_DM = dmsetup
+TARGETS_DM += dmstats
 
 INSTALL_LVM_TARGETS = install_tools_dynamic
-INSTALL_DMSETUP_TARGETS = install_dmsetup_dynamic
+INSTALL_DMSETUP_TARGETS = install_dmsetup_dynamic install_dmstats_dynamic
 INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic install_cmdlib_include 
 
 ifeq ("@STATIC_LINK@", "yes")
@@ -89,6 +90,7 @@ ifeq ("@STATIC_LINK@", "yes")
   TARGETS_DM += dmsetup.static
   INSTALL_LVM_TARGETS += install_tools_static
   INSTALL_DMSETUP_TARGETS += install_dmsetup_static
+  INSTALL_DMSETUP_TARGETS += install_dmstats_static
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
@@ -205,9 +207,15 @@ install_tools_static: lvm.static
 install_dmsetup_dynamic: dmsetup
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
+install_dmstats_dynamic: dmstats
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+
 install_dmsetup_static: dmsetup.static
 	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
+install_dmstats_static: dmstats.static
+	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
+
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 
 install_lvm2: $(INSTALL_LVM_TARGETS)


