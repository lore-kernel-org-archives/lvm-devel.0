From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Oct 2013 13:10:04 +0000 (UTC)
Subject: master - udev: properly trigger LVM scan for MD partitions
Message-ID: <20131030131004.68F7361068@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f070e3543a411d483b7c34b6ea8e6e8e0cc35edf
Commit:        f070e3543a411d483b7c34b6ea8e6e8e0cc35edf
Parent:        264b5c2b1252fae5918307326c2db07752b59001
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 30 14:02:38 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 30 14:09:11 2013 +0100

udev: properly trigger LVM scan for MD partitions

MD can directly create partition devices without a need to run
an extra kpartx or partprobe call. We need to react to this event in
a different way as for bare MD devices - we need to handle the ADD event
for KERNEL=="md[0-9]*p[0-9]*" kernel name and trigger the LVM scanning
to update lvmetad to trigger autoactivation and so on...

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1023250
---
 WHATS_NEW                     |    1 +
 udev/69-dm-lvm-metad.rules.in |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b8c1f15..b8a9bf7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104 -
 ===================================
+  Fix missing lvmetad scan for PVs found on MD partitions.
   Respect DM_UDEV_DISABLE_OTHER_RULES_FLAG in lvmetad udev rules.
   Fix clvmd message verification to not reject REMOTE flag. (2.02.100)
   Compare equality of double values with DBL_EPSILON predefined constant.
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 949c897..8ea5c92 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -58,6 +58,7 @@ LABEL="next"
 KERNEL!="loop[0-9]*", GOTO="next"
 ACTION=="add", ENV{LVM_LOOP_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_LOOP_PV_ACTIVATED}!="1", TEST=="loop/backing_file", ENV{LVM_LOOP_PV_ACTIVATED}="1", GOTO="lvm_scan"
+ACTION=="add", KERNEL=="md[0-9]*p[0-9]*", GOTO="lvm_scan"
 GOTO="lvm_end"
 
 # If the PV is not a special device listed above, scan only after device addition (ADD event)


