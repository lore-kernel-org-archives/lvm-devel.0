From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 May 2014 21:32:22 +0000 (UTC)
Subject: master - man: cleanup dmsetup
Message-ID: <20140526213222.D62CF60DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=965592340d04f02096b800107591290c1ad44443
Commit:        965592340d04f02096b800107591290c1ad44443
Parent:        3cb2658fb7ff0bba45e66e79bce8812c819dff52
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 26 22:55:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 26 22:57:20 2014 +0200

man: cleanup dmsetup

Add few bold texts.
---
 man/dmsetup.8.in |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index ae84489..9a738fb 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -426,11 +426,11 @@ that contain a version of device-mapper prior to 4.8.0.
 In this case the device will be deleted when its open_count
 drops to zero.  From version 4.8.0 onwards, if a device can't
 be removed because an uninterruptible process is waiting for
-I/O to return from it, adding \-\-force will replace the table
+I/O to return from it, adding \fB\-\-force\fP will replace the table
 with one that fails all I/O, which might allow the
 process to be killed. If an attempt to remove a device fails,
 perhaps because a process run from a quick udev rule
-temporarily opened the device, the \-\-retry option will cause
+temporarily opened the device, the \fB\-\-retry\fP option will cause
 the operation to be retried for a few seconds before failing.
 Do NOT combine \fB\-\-force\fP and \fB\-\-udevcookie\fP,
 as udev may start to process udev rules in the middle of error target
@@ -443,7 +443,7 @@ replacement and result in nondeterministic result.
 Attempts to remove all device definitions i.e. reset the driver.
 Use with care!  From version 4.8.0 onwards, if devices can't
 be removed because uninterruptible processes are waiting for
-I/O to return from them, adding \-\-force will replace the table
+I/O to return from them, adding \fB\-\-force\fP will replace the table
 with one that fails all I/O, which might allow the
 process to be killed.  This also runs \fBmknodes\fP afterwards.
 .br
@@ -494,7 +494,7 @@ Default subsystem is LVM.
 .RI [ device_name ]
 .br
 Outputs status information for each of the device's targets.
-With \-\-target, only information relating to the specified target type
+With \fB\-\-target\fP, only information relating to the specified target type
 any is displayed.  With \fB\-\-noflush\fP, the thin target (from version 1.3.0)
 doesn't commit any outstanding changes to disk before reporting its statistics.
 .br


