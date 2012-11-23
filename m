From: Ondrej Kozina <okozina@redhat.com>
Date: Fri, 23 Nov 2012 15:48:37 +0100
Subject: [PATCH 2/3] - minor change in fsadm man page
In-Reply-To: <1353682118-17855-1-git-send-email-okozina@redhat.com>
References: <1353682118-17855-1-git-send-email-okozina@redhat.com>
Message-ID: <1353682118-17855-3-git-send-email-okozina@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 man/fsadm.8.in | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/man/fsadm.8.in b/man/fsadm.8.in
index 46be1ff..17874db 100644
--- a/man/fsadm.8.in
+++ b/man/fsadm.8.in
@@ -16,7 +16,7 @@ fsadm \- utility to resize or check filesystem on a device
 .SH DESCRIPTION
 fsadm utility checks or resizes the filesystem on a device.
 It tries to use the same API for 
-.IR ext2 ", " ext3 ", " ext4 ", " ReiserFS " and " XFS
+.IR ext2 ", " ext3 ", " ext4 ", " ReiserFS ", " XFS " and "btrfs
 filesystem.
 .SH OPTIONS
 .TP
@@ -78,4 +78,6 @@ Defaults to "/dev" and must be an absolute path.
 .BR resize_reiserfs (8),
 .BR xfs_info (8),
 .BR xfs_growfs (8),
-.BR xfs_check (8)
+.BR xfs_check (8),
+.BR btrfs (8),
+.BR btrfsck (8)
-- 
1.8.0


