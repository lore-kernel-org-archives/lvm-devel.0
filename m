From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu,  2 Feb 2023 14:42:48 +0000 (GMT)
Subject: main - udev: remove rule for explicit creation of /dev/mapper/control
Message-ID: <20230202144248.3AE853858C53@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8498874147c886032817c24d11231947a041bc2e
Commit:        8498874147c886032817c24d11231947a041bc2e
Parent:        e7c8a825061d57efaffad80667873fa8d68d31ab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 2 15:30:30 2023 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 2 15:41:47 2023 +0100

udev: remove rule for explicit creation of /dev/mapper/control

We used KERNEL=="device-mapper", NAME="/dev/mapper/control" udev rule to
create the /dev/mapper/control file. The "NAME" rule should be only used
to rename network devices, otherwise udev issues a warning message. The
device-mapper driver has proper DEVNAME=/dev/mapper/control propagated
in the uevent environment when it is loaded so we don't need further
instruction on where to create the node - udev knows already.

Also, these days, it is created directly by kernel inside devtmpfs.
This makes the NAME="/dev/mapper/control" rule completely obsolete.
---
 WHATS_NEW_DM        | 1 +
 udev/10-dm.rules.in | 2 --
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 052fb9daf..43bf62a29 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.191 - 
 =====================================
+  Remove NAME="mapper/control" rule from 10-dm.rules to avoid udev warnings.
 
 Version 1.02.189 - 22nd December 2022
 =====================================
diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index b4fa52ab7..4ffd3e265 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -28,8 +28,6 @@
 # Also, keep in mind that recent rules may also require recent
 # subsystem-specific binaries.
 
-KERNEL=="device-mapper", NAME="(DM_DIR)/control"
-
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
 (DM_EXEC_RULE)

