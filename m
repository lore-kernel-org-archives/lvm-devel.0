From: Martin Wilck <mwilck@suse.com>
Date: Mon, 16 Apr 2018 20:53:41 +0200
Subject: [PATCH RESEND 2/2] lvm2: 69-dm-lvm-metad.rules: set systemd vars on "change"
In-Reply-To: <20180416185341.8588-1-mwilck@suse.com>
References: <20180416185341.8588-1-mwilck@suse.com>
Message-ID: <20180416185341.8588-3-mwilck@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The current logic that avoids setting SYSTEMD_ALIAS and SYSTEMD_WANTS
on "change" events is flawed in the default "systemd background job"
configuration. For systemd, it's important that device properties don't
change spuriously.

If an "add" event starts lvm2-pvscan at .service for a device, and a
"change" event follows, removing SYSTEMD_ALIAS and SYSTEMD_WANTS from the
udev db, information about unit dependencies between the device and the
pvscan service can be lost in systemd, in particular if the daemon
configuration is reloaded.

Steps to reproduce problem:

- create a device with an LVM PV
- remove device
- add device (generates "add" and "change" uevents for the device)
  (at this point SYSTEMD_ALIAS and SYSTEMD_WANTS are clear in udev db)
- systemctl daemon-reload
  (systemd reloads udev db)
- vgchange -a n
- remove device

=> the lvm2-pvscan at .service for the device is still active although the
device is gone.

- add device again

=> the PV is not detected, because systemd sees the lvm2-pvscan at .service
as active and thus doesn't restart it.

The original purpose of this logic was to avoid volumes being scanned
over and over again. With systemd background jobs, that isn't necessary,
because systemd will not restart the job as long as it's active.

Signed-off-by: Martin Wilck <mwilck@suse.com>
---
 udev/69-dm-lvm-metad.rules.in | 56 +++++++++++++++++++++++++++++++------------
 udev/Makefile.in              |  4 +++-
 2 files changed, 44 insertions(+), 16 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 38687f4..2ff8ddc 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -68,25 +68,15 @@ ACTION=="change", ENV{LVM_LOOP_PV_ACTIVATED}!="1", TEST=="loop/backing_file", EN
 ENV{LVM_LOOP_PV_ACTIVATED}!="1", ENV{SYSTEMD_READY}="0"
 GOTO="lvm_end"
 
-# If the PV is not a special device listed above, scan only after device addition (ADD event)
+# If the PV is not a special device listed above, scan only if necessary.
+# For "direct_pvscan" mode (see below), this means run rules only an ADD events.
+# For "systemd_background" mode, systemd takes care of this by activating
+# the lvm2-pvscan at .service only once.
 LABEL="next"
-ACTION!="add", GOTO="lvm_end"
+ACTION!="(PVSCAN_ACTION)", GOTO="lvm_end"
 
 LABEL="lvm_scan"
 
-# The table below summarises the situations in which we reach the LABEL="lvm_scan".
-# Marked by X, X* means only if the special dev is properly set up.
-# The artificial ADD is supported for coldplugging. We avoid running the pvscan
-# on artificial CHANGE so there's no unexpected autoactivation when WATCH rule fires.
-# N.B. MD and loop never actually  reaches lvm_scan on REMOVE as the PV label is gone
-# within a CHANGE event (these are caught by the "LVM_PV_GONE" rule at the beginning).
-#
-#        | real ADD | real CHANGE | artificial ADD | artificial CHANGE | REMOVE
-# =============================================================================
-#  DM    |          |      X      |       X*       |                   |   X
-#  MD    |          |      X      |       X*       |                   |
-#  loop  |          |      X      |       X*       |                   |
-#  other |    X     |             |       X        |                   |   X
 ENV{SYSTEMD_READY}="1"
 
 # The method for invoking pvscan is selected at build time with the option
@@ -97,6 +87,27 @@ GOTO="(PVSCAN_RULE)"
 
 LABEL="systemd_background"
 
+# The table below summarises the situations in which we reach the LABEL="lvm_scan"
+# in the "systemd_background" case.
+# Marked by X, X* means only if the special dev is properly set up.
+# The artificial ADD is supported for coldplugging. We avoid running the pvscan
+# on artificial CHANGE so there's no unexpected autoactivation when WATCH rule fires.
+# N.B. MD and loop never actually  reaches lvm_scan on REMOVE as the PV label is gone
+# within a CHANGE event (these are caught by the "LVM_PV_GONE" rule at the beginning).
+#
+# In this case, we simply set up the dependency between the device and the pvscan
+# job using SYSTEMD_ALIAS (which sets up a simplified device identifier that
+# allows using "BindsTo" in the sytemd unit file) and SYSTEMD_WANTS (which tells
+# systemd to start the pvscan job once the device is ready).
+# We need to set these variables for both "add" and "change" events, otherwise
+# systemd may loose information about the device/unit dependencies.
+#
+#        | real ADD | real CHANGE | artificial ADD | artificial CHANGE | REMOVE
+# =============================================================================
+#  DM    |          |      X      |       X*       |                   |   X
+#  MD    |          |      X      |       X*       |                   |
+#  loop  |          |      X      |       X*       |                   |
+#  other |    X     |      X      |       X        |                   |   X
 ACTION!="remove", ENV{LVM_PV_GONE}=="1", RUN+="(BINDIR)/systemd-run (LVM_EXEC)/lvm pvscan --cache $major:$minor", GOTO="lvm_end"
 ENV{SYSTEMD_ALIAS}="/dev/block/$major:$minor"
 ENV{ID_MODEL}="LVM PV $env{ID_FS_UUID_ENC} on /dev/$name"
@@ -105,6 +116,21 @@ GOTO="lvm_end"
 
 LABEL="direct_pvscan"
 
+# The table below summarises the situations in which we reach the LABEL="lvm_scan"
+# for the "direct_pvscan" case.
+# Marked by X, X* means only if the special dev is properly set up.
+# The artificial ADD is supported for coldplugging. We avoid running the pvscan
+# on artificial CHANGE so there's no unexpected autoactivation when WATCH rule fires.
+#
+# In this case, we need to make sure that pvscan is not invoked spuriously, therefore
+# we invoke it only for "add" events for "other" devices.
+#
+#        | real ADD | real CHANGE | artificial ADD | artificial CHANGE | REMOVE
+# =============================================================================
+#  DM    |          |      X      |       X*       |                   |   X
+#  MD    |          |      X      |       X*       |                   |
+#  loop  |          |      X      |       X*       |                   |
+#  other |    X     |             |       X        |                   |   X
 RUN+="(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major $major --minor $minor", ENV{LVM_SCANNED}="1"
 
 LABEL="lvm_end"
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 9b2e2c3..6f57d46 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -48,12 +48,14 @@ endif
 
 ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
 PVSCAN_RULE=systemd_background
+PVSCAN_ACTION=add|change
 else
 PVSCAN_RULE=direct_pvscan
+PVSCAN_ACTION=add
 endif
 
 %.rules: $(srcdir)/%.rules.in
-	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BINDIR)+$(BINDIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
+	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BINDIR)+$(BINDIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(PVSCAN_ACTION)+$(PVSCAN_ACTION)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
 
 %_install: %.rules
 	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)
-- 
2.16.1


