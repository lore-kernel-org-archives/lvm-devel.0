From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 00:05:51 -0400
Subject: [PATCH 6/8] Update vgcreate and vgextend man pages to clarify implicit pvcreate.
In-Reply-To: <1248235553-13519-6-git-send-email-dwysocha@redhat.com>
References: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-2-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-3-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-4-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-5-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1248235553-13519-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

vgcreate and vgextend now implicitly call pvcreate on devices not
currently initialized for LVM use.  Previously these commands would
fail with an error, so clarify the new behavior in the man page.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/vgcreate.8.in |   14 ++++++++------
 man/vgextend.8.in |    5 +++++
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 71bc136..6ec1d8e 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -21,16 +21,18 @@ vgcreate \- create a volume group
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.I VolumeGroupName PhysicalVolumePath
-.RI [ PhysicalVolumePath ...]
+.I VolumeGroupName PhysicalDevicePath
+.RI [ PhysicalDevicePath ...]
 .SH DESCRIPTION
 .B vgcreate
 creates a new volume group called
 .I VolumeGroupName
-using the block special device
-.IR PhysicalVolumePath
-previously configured for LVM with
-.BR pvcreate (8).
+using the block special device \fIPhysicalDevicePath\fP.
+If \fIPhysicalDevicePath\fP was not previously configured for LVM with
+\fBpvcreate (8)\fP, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default
+\fPpvcreate\fP values are are desired, \fBpvcreate\fP should be explicitly
+called prior to calling \fBvgcreate\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index 682cc5a..deb1cf3 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -11,6 +11,11 @@ VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
 vgextend allows you to add one or more initialized physical volumes ( see
 .B pvcreate(8)
 ) to an existing volume group to extend it in size.
+If \fIPhysicalDevicePath\fP was not previously configured for LVM with
+\fBpvcreate (8)\fP, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default
+\fPpvcreate\fP values are are desired, \fBpvcreate\fP should be explicitly
+called prior to calling \fBvgcreate\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH Examples
-- 
1.6.0.6


