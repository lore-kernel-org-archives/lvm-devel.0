From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 13 Mar 2014 12:03:09 +0000 (UTC)
Subject: master - man: add man page for lvm2-activation-generator
Message-ID: <20140313120309.6E56060DF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=031666ef66bf7b17ded4afcaa9bb97587fca0749
Commit:        031666ef66bf7b17ded4afcaa9bb97587fca0749
Parent:        c0f1eb5f0f8f0a790d1d9e6d9d3e1323c85e4144
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 13 13:01:06 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 13 13:01:06 2014 +0100

man: add man page for lvm2-activation-generator

---
 Makefile.in                                        |    1 +
 WHATS_NEW                                          |    1 +
 man/Makefile.in                                    |   11 +++-
 man/lvm2-activation-generator.8.in                 |   55 ++++++++++++++++++++
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 5 files changed, 67 insertions(+), 3 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index ce61957..d248a0e 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -108,6 +108,7 @@ install_initscripts:
 
 install_systemd_generators:
 	$(MAKE) -C scripts install_systemd_generators
+	$(MAKE) -C man install_systemd_generators
 
 install_systemd_units:
 	$(MAKE) -C scripts install_systemd_units
diff --git a/WHATS_NEW b/WHATS_NEW
index c625e5d..ed15f33 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add man page for lvm2-activation-generator.
   Don't print an error and accept empty value for global/thin_disabled_features.
   Update API for internal function build_dm_uuid().
   Do not try to check empty pool with scheduled messages.
diff --git a/man/Makefile.in b/man/Makefile.in
index 8c2ff13..12a0560 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -48,7 +48,8 @@ MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(BLKDEACTIVATEMAN) $(LVMETAD)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 lvm2-activation-generator.8 \
+	$(FSADMMAN) $(BLKDEACTIVATEMAN) $(LVMETAD)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
@@ -63,6 +64,8 @@ MAN8DM=dmsetup.8 $(DMEVENTDMAN)
 MAN5DIR=$(mandir)/man5
 MAN8DIR=$(mandir)/man8
 
+MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
+
 CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(MAN8DM)
 DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8
 
@@ -85,7 +88,7 @@ $(MAN5) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(systemd_generator_dir)+;" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)
@@ -106,4 +109,8 @@ install_device-mapper: $(MAN8DM)
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
 
+install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
+	$(INSTALL) -d $(MAN8DIR)
+	$(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
+
 install: install_lvm2 install_device-mapper
diff --git a/man/lvm2-activation-generator.8.in b/man/lvm2-activation-generator.8.in
new file mode 100644
index 0000000..bd47397
--- /dev/null
+++ b/man/lvm2-activation-generator.8.in
@@ -0,0 +1,55 @@
+.TH "LVM2-ACTIVATION-GENERATOR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.SH "NAME"
+lvm2-activation-generator \- generator for systemd units to activate LVM2 volumes on boot
+.SH SYNOPSIS
+.B #SYSTEMD_GENERATOR_DIR#/lvm2-activation-generator
+.sp
+.SH DESCRIPTION
+The lvm2-activation-generator is called by \fBsystemd\fP(1) on boot
+to generate systemd units at runtime to activate LVM2 volumes if
+\fBlvmetad\fP(8) is disabled (global/use_lvmetad=0 \fBlvm.conf\fP(5)
+option is used). Otherwise, if \fBlvmetad\fP(8) is enabled,
+the lvm2-activation-generator exits immediately without generating
+any systemd units and LVM2 fully relies on event-based activation
+to activate the LVM2 volumes instead using the \fBpvscan\fP(8)
+(pvscan --cache -aay) call that is a part of \fBudev\fP(8) rules.
+
+These systemd units are generated by lvm2-activation-generator:
+.sp
+\fIlvm2-activation-early.service\fP
+used for activation of LVM2 volumes that is ordered before systemd's
+special \fBcryptsetup.target\fP to support LVM2 volumes which are not
+layered on top of encrypted devices.
+
+\fIlvm2-activation.service\fP
+used for activation of LVM2 volumes that is ordered after systemd's
+special \fBcryptsetup.target\fP to support LVM2 volumes which are
+layered on top of encrypted devices.
+
+\fIlvm2-activation-net.service\fP
+used for activation of LVM2 volumes that is ordered after systemd's
+special \fBremote-fs.target\fP to support LVM2 volumes which are layered
+on attached remote devices.
+
+Note that all the underlying devices (Physical Volumes) need to be present
+when the service is run. If the there are any devices presented in the system
+anytime later, any LVM2 volumes on top of such devices need to be activated
+directly by \fBlvchange\fP(8) or \fBvgchange\fP(8). This limitation does
+not exist when using \fBlvmetad\fP(8) and accompanying event-based activation
+since such LVM volumes are activated automatically as soon as the Volume Group
+is ready (all the Physical Volumes making up the Volume Group are present
+in the system).
+
+The lvm2-activation-generator implements the \fBGenerator Specification\fP
+as referenced in \fBsystemd\fP(1).
+.sp
+.SH SEE ALSO
+.BR lvm.conf (5)
+.BR vgchange (8)
+.BR lvchange (8)
+.BR lvmetad (8)
+.BR pvscan (8)
+.BR udev (7)
+.BR systemd (1)
+.BR systemd.target (5)
+.BR systemd.special (7)
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 07a2563..e39f901 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -129,7 +129,7 @@ static int generate_unit(const char *dir, int unit)
 	      "# Direct LVM2 activation requires udev to be settled!\n\n"
 	      "[Unit]\n"
 	      "Description=Activation of LVM2 logical volumes\n"
-	      "Documentation=man:lvm(8) man:vgchange(8)\n"
+	      "Documentation=man:lvm2-activation-generator(8)\n"
 	      "SourcePath=/etc/lvm/lvm.conf\n"
 	      "DefaultDependencies=no\n", f);
 


