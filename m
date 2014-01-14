From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 14 Jan 2014 17:00:52 +0000 (UTC)
Subject: master - udev: do not drop SYSTEMD_READY for non-activating events
Message-ID: <20140114170052.27AAA61229@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b662f3c8dd52f489a8f5b5eeb69bc37ea40ff768
Commit:        b662f3c8dd52f489a8f5b5eeb69bc37ea40ff768
Parent:        3813cd7a3c3e763c346405664fba97edf7110d13
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 14 17:49:39 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 14 17:59:56 2014 +0100

udev: do not drop SYSTEMD_READY for non-activating events

Do not drop device's flag to report readiness for systemd
processing if there's any event that follows the activatiion
event itself. Otherwise, systemd would lost track of this device
on any other event that follows the activating event (IOW, we
need to make SYSTEMD_READY variable change level-based, not edge-based).

This patch applies for MD and loop devices used as PVs.

(intra-release fix for commit 4c267c7286145165dfe078f77d18d194a21a2e1c)
---
 udev/69-dm-lvm-metad.rules.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index d0b7b2a..e8304b5 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -54,7 +54,7 @@ IMPORT{db}="LVM_MD_PV_ACTIVATED"
 ACTION=="add", ENV{LVM_MD_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_MD_PV_ACTIVATED}!="1", TEST=="md/array_state", ENV{LVM_MD_PV_ACTIVATED}="1", GOTO="lvm_scan"
 ACTION=="add", KERNEL=="md[0-9]*p[0-9]*", GOTO="lvm_scan"
-ENV{SYSTEMD_READY}="0"
+ENV{LVM_MD_PV_ACTIVATED}!="1", ENV{SYSTEMD_READY}="0"
 GOTO="lvm_end"
 
 # Loop device:
@@ -62,7 +62,7 @@ LABEL="next"
 KERNEL!="loop[0-9]*", GOTO="next"
 ACTION=="add", ENV{LVM_LOOP_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_LOOP_PV_ACTIVATED}!="1", TEST=="loop/backing_file", ENV{LVM_LOOP_PV_ACTIVATED}="1", GOTO="lvm_scan"
-ENV{SYSTEMD_READY}="0"
+ENV{LVM_LOOP_PV_ACTIVATED}!="1", ENV{SYSTEMD_READY}="0"
 GOTO="lvm_end"
 
 # If the PV is not a special device listed above, scan only after device addition (ADD event)


