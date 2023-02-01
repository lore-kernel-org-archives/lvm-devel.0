From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed,  1 Feb 2023 13:49:26 +0000 (GMT)
Subject: main - udev: don't reset SYSTEMD_READY in udev for PVs on MD and loop
Message-ID: <20230201134926.2198E3858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7c8a825061d57efaffad80667873fa8d68d31ab
Commit:        e7c8a825061d57efaffad80667873fa8d68d31ab
Parent:        94eda42e7ad7c2dbd7fedfdfbf38032857318fec
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 1 14:33:25 2023 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 1 14:46:52 2023 +0100

udev: don't reset SYSTEMD_READY in udev for PVs on MD and loop

Since 67722b312390cdab29c076c912e14bd739c5c0f6, we have a new mechanism
to run the autoactivation from udev. With this change, we also replaced
the way the LVM autoactivation service is instantiatiated - instead of
setting the SYSTEM_WANTS udev variable (which systemd read and then
instantiated the service), we're now directly instantiating the
transient 'lvm-activate-<vgname>' service by calling systemd-run.

As such, we don't need to bother with setting the SYSTEMD_READY variable
for foreign devices anymore (in this case, MD and loop devices on top of
which there's a PV).

Before, we set the SYSTEMD_READY variable to make sure that the SYSTEMD_WANTS
is applied correctly - the service instantiation was edge-triggered by
flipping the SYSTEMD_READY from 0 to 1 and at the same time having the
SYSTEMD_WANTS variable set to the service name to instantiate. We're
using systemd-run now so this condition does not apply anymore.

Also, it was not completely correct to set SYSTEMD_READY for foreign
devices because there might be cases where this could cause issues,
see also https://github.com/lvmteam/lvm2/issues/94.
---
 WHATS_NEW               | 1 +
 udev/69-dm-lvm.rules.in | 4 ----
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7dbb669a1..1a0812df8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 version 2.03.19 - 
 ====================================
+  Do not reset SYSTEMD_READY variable in udev for PVs on MD and loop devices.
   Ensure udev is processing origin LV before its thick snapshots LVs.
   Fix and improve runtime memory size detection for VDO volumes.
 
diff --git a/udev/69-dm-lvm.rules.in b/udev/69-dm-lvm.rules.in
index 14e7dd26d..3cda30023 100644
--- a/udev/69-dm-lvm.rules.in
+++ b/udev/69-dm-lvm.rules.in
@@ -38,7 +38,6 @@ IMPORT{db}="LVM_MD_PV_ACTIVATED"
 ACTION=="add", ENV{LVM_MD_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_MD_PV_ACTIVATED}!="1", TEST=="md/array_state", ENV{LVM_MD_PV_ACTIVATED}="1", GOTO="lvm_scan"
 ACTION=="add", KERNEL=="md[0-9]*p[0-9]*", GOTO="lvm_scan"
-ENV{LVM_MD_PV_ACTIVATED}!="1", ENV{SYSTEMD_READY}="0"
 GOTO="lvm_end"
 
 # Loop device:
@@ -46,7 +45,6 @@ LABEL="next"
 KERNEL!="loop[0-9]*", GOTO="next"
 ACTION=="add", ENV{LVM_LOOP_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_LOOP_PV_ACTIVATED}!="1", TEST=="loop/backing_file", ENV{LVM_LOOP_PV_ACTIVATED}="1", GOTO="lvm_scan"
-ENV{LVM_LOOP_PV_ACTIVATED}!="1", ENV{SYSTEMD_READY}="0"
 GOTO="lvm_end"
 
 LABEL="next"
@@ -54,8 +52,6 @@ ACTION!="add", GOTO="lvm_end"
 
 LABEL="lvm_scan"
 
-ENV{SYSTEMD_READY}="1"
-
 # pvscan will check if this device completes a VG,
 # i.e. all PVs in the VG are now present with the
 # arrival of this PV.  If so, it prints to stdout:

