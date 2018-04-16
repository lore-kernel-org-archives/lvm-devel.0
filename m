From: Martin Wilck <mwilck@suse.com>
Date: Mon, 16 Apr 2018 20:53:40 +0200
Subject: [PATCH RESEND 1/2] lvm2: 69-dm-lvm-metad.rules: explicit pvscan rule
In-Reply-To: <20180416185341.8588-1-mwilck@suse.com>
References: <20180416185341.8588-1-mwilck@suse.com>
Message-ID: <20180416185341.8588-2-mwilck@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Make the distinction between the cases with and without systemd
background jobs explicit in 69-dm-lvm-metad.rules rather than
substituting the rule from the Makefile. At this stage,
this improves only readibility, at the cost of one GOTO statement.

The next patch will add more differences between the two cases (mostly
comments), which are practically impossible to generate with the current
string subsitution approach.

This patch introduces no functional change to the udev rules.

Signed-off-by: Martin Wilck <mwilck@suse.com>
---
 udev/69-dm-lvm-metad.rules.in | 19 ++++++++++++++++++-
 udev/Makefile.in              |  7 ++++---
 2 files changed, 22 insertions(+), 4 deletions(-)

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
-- 
2.16.1


