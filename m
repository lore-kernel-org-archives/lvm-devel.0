From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:49:57 +0000 (UTC)
Subject: master - man: Update the lvscan manpage with a section on --cache.
Message-ID: <20140722204957.A633360926@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab1887fe4719a296c2bd4b4778348f55f1b7a49a
Commit:        ab1887fe4719a296c2bd4b4778348f55f1b7a49a
Parent:        66686a5bc5ec09a48b0e549f5539424cbf2c7de8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 22 22:47:27 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jul 22 22:48:41 2014 +0200

man: Update the lvscan manpage with a section on --cache.

---
 man/lvscan.8.in |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/man/lvscan.8.in b/man/lvscan.8.in
index fad0fbe..0b6e50b 100644
--- a/man/lvscan.8.in
+++ b/man/lvscan.8.in
@@ -34,6 +34,15 @@ mimage_0, mimage_1, and mlog.
 .BR \-b ", " \-\-blockdevice
 This option is now ignored.  Instead, use \fBlvs\fP(8) or
 \fBlvdisplay\fP(8) to obtain the device number.
+.TP
+.IR \fB\-\-cache " " LogicalVolume
+Applicable only when \fBlvmetad\fP(8) is in use (see also \fBlvm.conf\fP(5),
+global/use_lvmetad). This command issues a rescan of physical volume labels and
+metadata areas of all PVs that the logical volume uses. In particular, this can
+be used when a RAID logical volume becomes degraded, to update information
+about physical volume availability. This is only necessary if the logical
+volume is \fBnot\fP being monitored by dmeventd (see \fBlvchange\fP(8), option
+\fB\-\-monitor\fP).
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvcreate (8),


