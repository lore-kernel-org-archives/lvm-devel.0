From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:07 +0000 (GMT)
Subject: main - man: document fsadm -l option
Message-ID: <20210423210607.AA1F23B08C1C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=579c9413212deb80c56628a11bd36ba9bace3a22
Commit:        579c9413212deb80c56628a11bd36ba9bace3a22
Parent:        6f61de300980a55381c70347712c22a96c22807b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 11:09:05 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

man: document fsadm -l option

Missed -l option in man page, although users should prefer
lvresize -r when the also want to do a volume management,
as there they can specify i.e. extents for allocation.
Also mention dm-crypt support in command description.
---
 man/fsadm.8_main | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/man/fsadm.8_main b/man/fsadm.8_main
index d83e99292..dfff5bb97 100644
--- a/man/fsadm.8_main
+++ b/man/fsadm.8_main
@@ -25,13 +25,14 @@ fsadm \(em utility to resize or check filesystem on a device
 .
 .SH DESCRIPTION
 .
-fsadm utility checks or resizes the filesystem on a device.
+fsadm utility checks or resizes the filesystem on a device (can be
+also dm-crypt encrypted device).
 It tries to use the same API for
 .BR ext2 ,
 .BR ext3 ,
 .BR ext4 ,
 .BR ReiserFS
-.RB and
+and
 .BR XFS
 filesystem.
 .
@@ -50,6 +51,12 @@ Bypass some sanity checks.
 Display the help text.
 .
 .TP
+.BR -l | --lvresize
+Resize also given lvm2 logical volume. More volume management
+functionality is provided with complementary \fBlvresize\fP(8) and the option
+.BR -r | --resizefs.
+.
+.TP
 .BR -n | --dry-run
 Print commands without running them.
 .


