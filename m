From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 12 Jul 2016 13:23:32 +0000 (UTC)
Subject: master - man: lvcreate: try to be clearer about -W|--wipesignatures
Message-ID: <20160712132332.A6D2260E9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5be748341ec88e35c826b70152bf1e757653a3a
Commit:        d5be748341ec88e35c826b70152bf1e757653a3a
Parent:        957480f4b9e6cbcc0cfc87ed06d0c0283269e17f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 12 15:20:12 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 12 15:23:29 2016 +0200

man: lvcreate: try to be clearer about -W|--wipesignatures

There was still some confusion report about -W|--wipesignatures
lvcreate option so try to be even clearer. Hopefully, the last edit
here.
---
 man/lvcreate.8.in |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 1bc2a91..1cce0b6 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -720,16 +720,17 @@ device sizes (GiB), thin provisioning should be used for this case.
 .BR \-W | \-\-wipesignatures
 .RB { y | n }
 .br
-Controls wiping of detected signatures on newly created Logical Volume.
-If this option is not specified, then by default signature wiping is done
-each time the zeroing (
-.BR \-Z | \-\-zero
-) is done. This default behaviour
+Controls detection and subsequent wiping of signatures on newly created
+Logical Volume. There's a prompt for each signature detected to confirm
+its wiping (unless \fB--yes\fP is used where LVM assumes 'yes' answer
+for each prompt automatically). If this option is not specified, then by
+default \fB-W\fP | \fB--wipesignatures y\fP is assumed each time the
+zeroing is done (\fB\-Z\fP | \fB\-\-zero y\fP). This default behaviour
 can be controlled by \fB\%allocation/wipe_signatures_when_zeroing_new_lvs\fP
 setting found in
 .BR lvm.conf (5).
 .br
-If blkid wiping is used \fBallocation/use_blkid_wiping\fP setting in
+If blkid wiping is used (\fBallocation/use_blkid_wiping\fP setting in
 .BR lvm.conf (5))
 and LVM2 is compiled with blkid wiping support, then \fBblkid\fP(8) library is used
 to detect the signatures (use \fBblkid \-k\fP command to list the signatures that are recognized).


