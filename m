From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Sep 2013 10:39:34 +0000 (UTC)
Subject: master - udev: DM_ID_FS_TYPE should be ID_FS_TYPE when comparing with old value
Message-ID: <20130910103934.BB2BF60E66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ba40da7ae908fb36cb9927cde60a1a45cacce80
Commit:        9ba40da7ae908fb36cb9927cde60a1a45cacce80
Parent:        ca514351536c2dd8929944bb6b01a64587cb0a46
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 10 12:38:18 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 10 12:39:23 2013 +0200

udev: DM_ID_FS_TYPE should be ID_FS_TYPE when comparing with old value

---
 udev/69-dm-lvm-metad.rules.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index b4be582..aa787e3 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -18,7 +18,7 @@ SUBSYSTEM!="block", GOTO="lvm_end"
 (LVM_EXEC_RULE)
 
 # If the PV label got lost, inform lvmetad about it.
-ENV{DM_ID_FS_TYPE_OLD}=="LVM2_member|LVM1_member", ENV{DM_ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_scan"
+ENV{DM_ID_FS_TYPE_OLD}=="LVM2_member|LVM1_member", ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_scan"
 
 # Only process devices already marked as a PV - this requires blkid to be called before.
 ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"


