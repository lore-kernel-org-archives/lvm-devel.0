From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 20 Sep 2013 07:45:40 +0000 (UTC)
Subject: master - udev: remove unused line in 69-dm-lvm-metad.rules
Message-ID: <20130920074540.353B86113B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f393a5c15631f883883df41e85b3209b33005cd6
Commit:        f393a5c15631f883883df41e85b3209b33005cd6
Parent:        2c41c8b88610bff6a3352b93f6b5c70a3744c817
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 20 09:42:27 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 20 09:45:34 2013 +0200

udev: remove unused line in 69-dm-lvm-metad.rules

The explicit check for *_raid_member is not actually needed as
this gets filtered out by the ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member" rule.
---
 udev/69-dm-lvm-metad.rules.in |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 6363a79..ba43396 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -27,6 +27,7 @@ ENV{LVM_PV_GONE}=="1", GOTO="lvm_scan"
 
 # Only process devices already marked as a PV - this requires blkid to be called before.
 ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"
+ENV{DM_MULTIPATH_DEVICE_PATH}=="1", GOTO="lvm_end"
 
 # Inform lvmetad about any PV that is gone.
 ACTION=="remove", GOTO="lvm_scan"
@@ -76,11 +77,6 @@ LABEL="lvm_scan"
 #  MD    |          |      X      |       X*       |                   |
 #  loop  |          |      X      |       X*       |                   |
 #  other |    X     |             |       X        |                   |   X
-
-# Skip device that is a multipath or RAID component
-ENV{DM_MULTIPATH_DEVICE_PATH}=="1", GOTO="lvm_end"
-ENV{ID_FS_TYPE}=="*_raid_member", GOTO="lvm_end"
-
 RUN+="(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major $major --minor $minor", ENV{LVM_SCANNED}="1"
 
 LABEL="lvm_end"


