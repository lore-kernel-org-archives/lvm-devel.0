From: Heming Zhao <heming.zhao@suse.com>
Date: Wed, 30 Jun 2021 22:32:43 +0800
Subject: [PATCH 2/3] man: add support for btrfs
In-Reply-To: <20210630143244.7318-1-heming.zhao@suse.com>
References: <20210630143244.7318-1-heming.zhao@suse.com>
Message-ID: <20210630143244.7318-2-heming.zhao@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Heming Zhao <heming.zhao@suse.com>
---
 man/fsadm.8_main | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/man/fsadm.8_main b/man/fsadm.8_main
index dfff5bb97021..ad924ac3a304 100644
--- a/man/fsadm.8_main
+++ b/man/fsadm.8_main
@@ -31,6 +31,7 @@ It tries to use the same API for
 .BR ext2 ,
 .BR ext3 ,
 .BR ext4 ,
+.BR btrfs ,
 .BR ReiserFS
 and
 .BR XFS
@@ -119,6 +120,9 @@ Defaults to "\fI/dev\fP" and must be an absolute path.
 .BR tune2fs (8),
 .BR resize2fs (8),
 .P
+.BR btrfs (8),
+.BR btrfs-scrub (8),
+.P
 .BR reiserfstune (8),
 .BR resize_reiserfs (8),
 .P
-- 
1.8.3.1



