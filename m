From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  9 Sep 2013 11:49:24 +0000 (UTC)
Subject: master - udev: also inform lvmetad about lost LVM1 PV label
Message-ID: <20130909114924.06AE46120F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f2fc2471cd39effccd549d73c2fc9c0e6419f94
Commit:        9f2fc2471cd39effccd549d73c2fc9c0e6419f94
Parent:        d89b514e06eb3431052d3dee4758103bf5f08963
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 9 13:47:25 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 9 13:48:27 2013 +0200

udev: also inform lvmetad about lost LVM1 PV label

Addendum to 4d3b5724e0b51782000a45027de00e0fed1c9833
which covered only LVM2 PV labels.
---
 udev/69-dm-lvm-metad.rules.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 6162e26..b4be582 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -18,7 +18,7 @@ SUBSYSTEM!="block", GOTO="lvm_end"
 (LVM_EXEC_RULE)
 
 # If the PV label got lost, inform lvmetad about it.
-ENV{DM_ID_FS_TYPE_OLD}=="LVM2_member", ENV{DM_ID_FS_TYPE}!="LVM2_member", GOTO="lvm_scan"
+ENV{DM_ID_FS_TYPE_OLD}=="LVM2_member|LVM1_member", ENV{DM_ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_scan"
 
 # Only process devices already marked as a PV - this requires blkid to be called before.
 ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"


