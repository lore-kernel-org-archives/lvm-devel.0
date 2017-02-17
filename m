From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Feb 2017 21:34:15 +0000 (UTC)
Subject: master - man: mention force behavior in various places
Message-ID: <20170217213415.36AFF60E2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6064b0359a7f3fbc07e56dd7094732ea184c199e
Commit:        6064b0359a7f3fbc07e56dd7094732ea184c199e
Parent:        50e0345f9d245cdcb29e4988760e788defa5e88e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 17 15:11:19 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 17 15:11:19 2017 -0600

man: mention force behavior in various places

---
 man/lvremove.8.des     |    5 +++++
 man/pvcreate.8.des     |    3 +++
 man/pvremove.8.des     |    5 +++++
 man/vgcfgrestore.8.des |    3 +++
 man/vgremove.8.des     |    3 +++
 5 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/man/lvremove.8.des b/man/lvremove.8.des
index d049c63..14587c1 100644
--- a/man/lvremove.8.des
+++ b/man/lvremove.8.des
@@ -6,6 +6,11 @@ removal.  LVs cannot be deactivated or removed while they are open (e.g.
 if they contain a mounted filesystem). Removing an origin LV will also
 remove all dependent snapshots.
 
+When a single force option is used, LVs are removed without confirmation,
+and the command will try to deactivate unused LVs.
+
+To remove damaged LVs, two force options may be required (\fB-ff\fP).
+
 \fBHistorical LVs\fP
 
 If the configuration setting \fBmetadata/record_lvs_history\fP is enabled
diff --git a/man/pvcreate.8.des b/man/pvcreate.8.des
index 3dfddbc..1b00e9e 100644
--- a/man/pvcreate.8.des
+++ b/man/pvcreate.8.des
@@ -16,3 +16,6 @@ data on that disk. This can be done by zeroing the first sector with:
 Use \fBvgcreate\fP(8) to create a new VG on the PV, or \fBvgextend\fP(8)
 to add the PV to existing VG.
 
+The force option will create a PV without confirmation.  Repeating the
+force option (\fB-ff\fP) will forcibly create a PV, overriding checks that
+normally prevent it, e.g. if the PV is already in a VG.
diff --git a/man/pvremove.8.des b/man/pvremove.8.des
index f12b76e..cc84148 100644
--- a/man/pvremove.8.des
+++ b/man/pvremove.8.des
@@ -1,2 +1,7 @@
 pvremove wipes the label on a device so that LVM will no longer recognise
 it as a PV.
+
+A PV cannot be removed from a VG while it is used by an active LV.
+
+Repeat the force option (\fB-ff\fP) to forcibly remove a PV belonging to
+an existing VG. Normally, \fBvgreduce\fP(8) should be used instead.
diff --git a/man/vgcfgrestore.8.des b/man/vgcfgrestore.8.des
index cb7867d..ee3a99e 100644
--- a/man/vgcfgrestore.8.des
+++ b/man/vgcfgrestore.8.des
@@ -6,3 +6,6 @@ A back up file can be specified with \fB\-\-file\fP.  If no backup file is
 specified, the most recent one is used. Use \fB\-\-list\fP for a list of
 the available back up and archive files of a VG.
 
+WARNING: When a VG contains thin pools, changes to thin metadata cannot be
+reverted, and data loss may occur if thin metadata has changed. The force
+option is required to restore in this case.
diff --git a/man/vgremove.8.des b/man/vgremove.8.des
index 04dc0e3..6414c73 100644
--- a/man/vgremove.8.des
+++ b/man/vgremove.8.des
@@ -4,3 +4,6 @@ to confirm LV removal.
 If one or more PVs in the VG are lost, consider
 \fBvgreduce \-\-removemissing\fP to make the VG
 metadata consistent again.
+
+Repeat the force option (\fB-ff\fP) to forcibly remove LVs in the VG
+without confirmation.


