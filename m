From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 15 Apr 2015 07:19:26 +0000 (UTC)
Subject: master - man: fix some formatting and also mention -vv
Message-ID: <20150415071926.A460F606FF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22defdac64703945938483433a8d7cc7e3708ef9
Commit:        22defdac64703945938483433a8d7cc7e3708ef9
Parent:        6cdab82cf360f2237fc55aabac60e7e1f8866250
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 15 09:19:11 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 15 09:19:11 2015 +0200

man: fix some formatting and also mention -vv

---
 man/blkdeactivate.8.in |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
index ebeaeaa..990be4a 100644
--- a/man/blkdeactivate.8.in
+++ b/man/blkdeactivate.8.in
@@ -9,9 +9,7 @@ blkdeactivate \(em utility to deactivate block devices
 .RB [ \-l \  \fIlvm_options\fP ]
 .RB [ \-u ]
 .RB [ \-v ]
-.RS
 .RI [ device ]
-.RE
 .SH DESCRIPTION
 blkdeactivate utility deactivates block devices. If a device
 is mounted, the utility can unmount it automatically before
@@ -57,7 +55,7 @@ Unmount a mounted device before trying to deactivate it.
 Without this option used, a device that is mounted is not deactivated.
 .TP
 .BR \-v ", " \-\-verbose
-Run in verbose mode.
+Run in verbose mode. Use \-\-vv for even more verbose mode.
 .SH EXAMPLES
 .sp
 Deactivate all supported block devices found in the system. If a device


