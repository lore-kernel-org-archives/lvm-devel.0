From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Mar 2014 13:11:54 +0000 (UTC)
Subject: master - man: add repair info for thin pools
Message-ID: <20140326131154.49E9B60FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bda0fe95ad66b864429ce18bb9dc6277259ba348
Commit:        bda0fe95ad66b864429ce18bb9dc6277259ba348
Parent:        a3615f314993f4f898fb3bdc4e53f1548069698f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 26 14:04:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 14:11:36 2014 +0100

man: add repair info for thin pools

Document lvconvert --repair for thin pools.
---
 man/lvconvert.8.in |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 190e221..ade106d 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -333,14 +333,23 @@ a suitable value automatically.
 "None" is equivalent to specifying zero.
 .TP
 .B \-\-repair
-Repair a mirror after suffering a disk failure. The mirror will be brought back
-into a consistent state.  By default, the original number of mirrors will be
+Repair a mirror after suffering a disk failure or try to fix thin pool metadata.
+
+The mirror will be brought back into a consistent state.
+By default, the original number of mirrors will be
 restored if possible.  Specify \fB\-y\fP on the command line to skip
 the prompts. Use \fB\-f\fP if you do not want any replacement.
 Additionally, you may use \fB\-\-use\-policies\fP to use the device
 replacement policy specified in \fBlvm.conf\fP(5),
 viz. activation/mirror_log_fault_policy or
 activation/mirror_device_fault_policy.
+
+Thin pool repair automates the use of \fBthin_repair\fP(8) tool.
+Only inactive thin pool volumes can be repaired.
+There is no validation of metadata between kernel and lvm2.
+This requires further manual work.
+After successfull repair the old unmodified metadata are still
+available in \fB<pool>_tmeta<n>\fP LV.
 .TP
 .B \-\-replace \fIPhysicalVolume
 Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
@@ -498,4 +507,5 @@ cache pool LV.
 .BR lvscan (8),
 .BR vgcreate (8),
 .BR thin_dump (8),
+.BR thin_repair (8)
 .BR thin_restore (8)


