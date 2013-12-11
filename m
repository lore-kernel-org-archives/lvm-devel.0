From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Dec 2013 12:53:01 +0000 (UTC)
Subject: master - udev: fix SYSTEMD_READY assignment for foreign devices in lvmetad rules
Message-ID: <20131211125301.A8199603D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c267c7286145165dfe078f77d18d194a21a2e1c
Commit:        4c267c7286145165dfe078f77d18d194a21a2e1c
Parent:        c9fe05eee26596feb7ed7e83e3da96b8efcbdb20
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 11 13:13:21 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 11 13:46:15 2013 +0100

udev: fix SYSTEMD_READY assignment for foreign devices in lvmetad rules

Some devices, similarly to us, are not prepared after ADD event, but
after an extra CHANGE event when the device is properly set up.
This includes MD and loop devices. This patch fixes the
SYSTEMD_READY assignment that is crucial for proper functionality
of SYSTEMD_WANTS that we use to instantiate a lvm2-pvscan at .service
systemd service to activate the VG/LVs (see also bug
info).

All that extra handling of foreign devices should eventually be moved
to rules which process those devices primarily (MD and loop)! We should
only check a dedicated variable whether the device is usable or not.
---
 udev/69-dm-lvm-metad.rules.in |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 5b15b6f..d0b7b2a 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -39,6 +39,8 @@ ACTION=="remove", GOTO="lvm_scan"
 # but they require an extra setup and they are ready after a CHANGE event.
 # Also support coldplugging with ADD event but only if the device is already
 # properly activated.
+# This logic should be eventually moved to rules where those particular
+# devices are processed primarily (MD and loop).
 
 # DM device:
 KERNEL!="dm-[0-9]*", GOTO="next"
@@ -52,6 +54,7 @@ IMPORT{db}="LVM_MD_PV_ACTIVATED"
 ACTION=="add", ENV{LVM_MD_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_MD_PV_ACTIVATED}!="1", TEST=="md/array_state", ENV{LVM_MD_PV_ACTIVATED}="1", GOTO="lvm_scan"
 ACTION=="add", KERNEL=="md[0-9]*p[0-9]*", GOTO="lvm_scan"
+ENV{SYSTEMD_READY}="0"
 GOTO="lvm_end"
 
 # Loop device:
@@ -59,6 +62,7 @@ LABEL="next"
 KERNEL!="loop[0-9]*", GOTO="next"
 ACTION=="add", ENV{LVM_LOOP_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_LOOP_PV_ACTIVATED}!="1", TEST=="loop/backing_file", ENV{LVM_LOOP_PV_ACTIVATED}="1", GOTO="lvm_scan"
+ENV{SYSTEMD_READY}="0"
 GOTO="lvm_end"
 
 # If the PV is not a special device listed above, scan only after device addition (ADD event)
@@ -80,6 +84,7 @@ LABEL="lvm_scan"
 #  MD    |          |      X      |       X*       |                   |
 #  loop  |          |      X      |       X*       |                   |
 #  other |    X     |             |       X        |                   |   X
+ENV{SYSTEMD_READY}="1"
 (PVSCAN_RULE)
 
 LABEL="lvm_end"


