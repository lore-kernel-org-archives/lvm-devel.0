From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 19 Feb 2015 16:51:52 +0000 (UTC)
Subject: master - man: update lvmthin about repair and recovery
Message-ID: <20150219165152.C2E8060755@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97e3e84c2ca8678630ee8a45cb5e3cc2949c607b
Commit:        97e3e84c2ca8678630ee8a45cb5e3cc2949c607b
Parent:        f80e7bb61bb794bfbedcca95a5dea8b1aac560b2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 6 04:24:30 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 19 10:49:39 2015 -0600

man: update lvmthin about repair and recovery

Explain the thin metadata repair might not work.
Clarify that a full thin pool won't require fsck for journaled fs.
---
 man/lvmthin.7.in |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index e342a2d..dab2d7e 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -431,8 +431,13 @@ This is not recommended.
 controls the command options used for the thin_check command.
 
 If the thin_check command finds a problem with the metadata,
-the thin pool LV is not activated, and the thin pool metadata should
-be repaired.
+the thin pool LV is not activated, and the thin pool metadata needs
+to be repaired.
+
+Simple repair commands are not always successful.  Advanced repair may
+require editing thin pool metadata and lvm metadata.  Newer versions of
+the kernel and lvm tools may be more successful at repair.  Report the
+details of damaged thin metadata to get the best advice on recovery.
 
 Command to repair a thin pool:
 .br
@@ -785,7 +790,9 @@ return to normal operation.
 While waiting to be extended, the thin pool will queue writes for up to 60
 seconds (the default).  If data space has not been extended after this
 time, the queued writes will return an error to the caller, e.g. the file
-system.  This can result in file system corruption that may require fsck.
+system.  This can result in file system corruption for non-journaled file
+systems that may require fsck.  When a thin pool returns errors for writes
+to a thin LV, any file system is subject to losing unsynced user data.
 
 The 60 second timeout can be changed or disabled with the dm\-thin\-pool
 kernel module option


