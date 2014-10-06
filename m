From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:32 +0000 (UTC)
Subject: master - man: document -ff for removal
Message-ID: <20141006133332.3F91661041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7783fe3e93b6fee0e8ea8198917b2d1a3072bdab
Commit:        7783fe3e93b6fee0e8ea8198917b2d1a3072bdab
Parent:        79ca382b2c24fd01aa25c98c0ab29b97a4358270
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 4 17:06:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:22:24 2014 +0200

man: document -ff for removal

Make it visible in man page that -ff could make removal
process proceed in case of damaged pool.
---
 man/lvremove.8.in |    2 ++
 man/vgremove.8.in |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/man/lvremove.8.in b/man/lvremove.8.in
index b0bb477..8426cac 100644
--- a/man/lvremove.8.in
+++ b/man/lvremove.8.in
@@ -31,6 +31,8 @@ See \fBlvm\fP(8) for common options.
 .TP
 .BR \-f ", " \-\-force
 Remove active logical volumes without confirmation.
+Tool will try to deactivate \fIunused\fP volume.
+To proceed with damaged pools use \-ff
 .TP
 .B \-\-noudevsync
 Disable udev synchronisation. The
diff --git a/man/vgremove.8.in b/man/vgremove.8.in
index f824a56..10a431f 100644
--- a/man/vgremove.8.in
+++ b/man/vgremove.8.in
@@ -28,6 +28,7 @@ See \fBlvm\fP(8) for common options.
 .BR \-f ", " \-\-force
 Force the removal of any logical volumes on the volume group
 without confirmation.
+To remove also damaged pool volumes use \-ff.
 .TP
 .BR \-\-noudevsync
 Disable udev synchronisation. The


