From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue, 17 Apr 2018 05:43:57 -0400
Subject: master - udev: explicit pvscan rule in 69-dm-lvm-metad.rules
Message-ID: <201804170943.w3H9hvUY005962@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99bfbbf229acf4548f1ffc06625f464dc0ae4ca4
Commit:        99bfbbf229acf4548f1ffc06625f464dc0ae4ca4
Parent:        bc286910ecb9a1a5962b93618852d1ed4a7ca7dc
Author:        Martin Wilck <mwilck@suse.com>
AuthorDate:    Tue Apr 17 11:32:52 2018 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 17 11:32:52 2018 +0200

udev: explicit pvscan rule in 69-dm-lvm-metad.rules

Make the distinction between the cases with and without systemd
background jobs explicit in 69-dm-lvm-metad.rules rather than
substituting the rule from the Makefile. At this stage,
this improves only readibility, at the cost of one GOTO statement.

This patch introduces no functional change to the udev rules.

Signed-off-by: Martin Wilck <mwilck@suse.com>
---
 WHATS_NEW                     |    1 +
 udev/69-dm-lvm-metad.rules.in |   19 ++++++++++++++++++-
 udev/Makefile.in              |    7 ++++---
 3 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5d34dc..e0e9c51 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Write systemd and non-systemd rule in 69-dm-lvm-metad.rules, GOTO active one.
   Add test for activation/volume_list (Sub)LV remnants.
   Disallow usage of cache format 2 with mq cache policy.
   Again accept striped LV as COW LV with lvconvert -s (2.02.169).
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index bd75fc8..38687f4 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -88,6 +88,23 @@ LABEL="lvm_scan"
 #  loop  |          |      X      |       X*       |                   |
 #  other |    X     |             |       X        |                   |   X
 ENV{SYSTEMD_READY}="1"
-(PVSCAN_RULE)
+
+# The method for invoking pvscan is selected at build time with the option
+# --(enable|disable)-udev-systemd-background-jobs to "configure".
+# On modern distributions with recent systemd, it's "systemd_background";
+# on others, "direct_pvscan".
+GOTO="(PVSCAN_RULE)"
+
+LABEL="systemd_background"
+
+ACTION!="remove", ENV{LVM_PV_GONE}=="1", RUN+="(BINDIR)/systemd-run (LVM_EXEC)/lvm pvscan --cache $major:$minor", GOTO="lvm_end"
+ENV{SYSTEMD_ALIAS}="/dev/block/$major:$minor"
+ENV{ID_MODEL}="LVM PV $env{ID_FS_UUID_ENC} on /dev/$name"
+ENV{SYSTEMD_WANTS}+="lvm2-pvscan@$major:$minor.service"
+GOTO="lvm_end"
+
+LABEL="direct_pvscan"
+
+RUN+="(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major $major --minor $minor", ENV{LVM_SCANNED}="1"
 
 LABEL="lvm_end"
diff --git a/udev/Makefile.in b/udev/Makefile.in
index c498aa8..9b2e2c3 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -25,6 +25,7 @@ endif
 
 DM_DIR=$(shell $(GREP) "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
 
+BINDIR=@bindir@
 ifeq ("@UDEV_RULE_EXEC_DETECTION@", "yes")
 SBIN=\$$env{DM_SBIN_PATH}
 DM_EXEC_RULE=ENV{DM_SBIN_PATH}=\"\/sbin\"\\nTEST!=\"\$$env{DM_SBIN_PATH}\/dmsetup\", ENV{DM_SBIN_PATH}=\"\/usr\/sbin\"
@@ -46,13 +47,13 @@ BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
 ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
-PVSCAN_RULE=ACTION\!=\"remove\", ENV{LVM_PV_GONE}==\"1\", RUN\+=\"@bindir@/systemd-run $(LVM_EXEC)\/lvm pvscan --cache \$$major\:\$$minor\", GOTO=\"lvm_end\"\nENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}\+=\"lvm2-pvscan@\$$major:\$$minor.service\"
+PVSCAN_RULE=systemd_background
 else
-PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
+PVSCAN_RULE=direct_pvscan
 endif
 
 %.rules: $(srcdir)/%.rules.in
-	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
+	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BINDIR)+$(BINDIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
 
 %_install: %.rules
 	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)


