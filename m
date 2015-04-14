From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 14 Apr 2015 13:25:52 +0000 (UTC)
Subject: master - make: move blkdeactivate script and blkdeactivate.8 man page installation from install_lvm2 to install_device-mapper target
Message-ID: <20150414132552.79C156052E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=375ed98ae99be868613a603bae6ba9f701c837c8
Commit:        375ed98ae99be868613a603bae6ba9f701c837c8
Parent:        7a4e27eee51e89a550bc55f78daea6d943293202
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 14 15:21:22 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 14 15:24:37 2015 +0200

make: move blkdeactivate script and blkdeactivate.8 man page installation from install_lvm2 to install_device-mapper target

This completes commit 7a4e27eee51e89a550bc55f78daea6d943293202.
---
 man/Makefile.in     |    4 ++--
 scripts/Makefile.in |   12 +++++++-----
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 09d02ae..a2e19fc 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -50,7 +50,7 @@ MAN8=lvm-dumpconfig.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(BLKDEACTIVATEMAN) $(LVMETAD)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(LVMETAD)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
@@ -70,7 +70,7 @@ ifneq ("@THIN@", "none")
   MAN7+=lvmthin.7
 endif
 
-MAN8DM=dmsetup.8 $(DMEVENTDMAN)
+MAN8DM=dmsetup.8 $(DMEVENTDMAN) $(BLKDEACTIVATEMAN)
 MAN5DIR=$(mandir)/man5
 MAN7DIR=$(mandir)/man7
 MAN8DIR=$(mandir)/man8
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 19fd5d8..60797ef 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -33,14 +33,15 @@ ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event
 endif
 
-SCRIPTS = lvmdump.sh lvmconf.sh vgimportclone.sh
+LVM_SCRIPTS = lvmdump.sh lvmconf.sh vgimportclone.sh
+DM_SCRIPTS =
 
 ifeq ("@FSADM@", "yes")
-	SCRIPTS += fsadm.sh
+	LVM_SCRIPTS += fsadm.sh
 endif
 
 ifeq ("@BLKDEACTIVATE@", "yes")
-	SCRIPTS += blkdeactivate.sh
+	DM_SCRIPTS += blkdeactivate.sh
 endif
 
 OCF_SCRIPTS =
@@ -58,11 +59,12 @@ vpath %.ocf $(srcdir)
 	$(INSTALL_DIR) $(ocf_scriptdir)
 	$(INSTALL_SCRIPT) $< $(ocf_scriptdir)/$(basename $(<F))
 
-install_lvm2: $(SCRIPTS:.sh=_install)
+install_lvm2: $(LVM_SCRIPTS:.sh=_install)
+install_device-mapper: $(DM_SCRIPTS:.sh=_install)
 
 install_ocf: $(OCF_SCRIPTS:.ocf=_install)
 
-install: install_lvm2 install_ocf
+install: install_lvm2 install_ocf install_device-mapper
 
 # FIXME Customise for other distributions
 install_initscripts:


