From: Liuhua Wang <lwang@suse.com>
Date: Tue, 10 Feb 2015 15:11:05 +0800
Subject: [PATCH] man: modify lvscan man
Message-ID: <1423552265-5589-1-git-send-email-lwang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvscan has no output when it is in silent mode, which is inconsistent
with man/lvscan.

Signed-off-by: Liuhua Wang <lwang@suse.com>
---
 man/lvscan.8.in | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/man/lvscan.8.in b/man/lvscan.8.in
index 0b6e50b..bc4dc5c 100644
--- a/man/lvscan.8.in
+++ b/man/lvscan.8.in
@@ -16,7 +16,8 @@ lvscan \(em scan (all disks) for Logical Volumes
 lvscan scans all known volume groups or all supported LVM block devices
 in the system for defined Logical Volumes.  The output consists
 of one line for each Logical Volume indicating whether or not it is active,
-a snapshot or origin, the size of the device and its allocation policy.
+a snapshot or origin, the size of the device and its allocation policy when
+it is not in silent mode.
 Use \fBlvs\fP(8) or \fBlvdisplay\fP(8) to obtain more-comprehensive
 information about the Logical Volumes.
 .SH OPTIONS
-- 
2.1.2


