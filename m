From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:04 -0500
Subject: master - blkdeactive: use /sbin for mdamd
Message-ID: <201711072036.vA7Ka4Ew007646@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f0baec1f36d712e9611ea31bde0ad904aa08f33
Commit:        0f0baec1f36d712e9611ea31bde0ad904aa08f33
Parent:        2354fb3fe45c6e2739a0a902f378c70c5422ac48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 3 17:06:16 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:26:11 2017 +0100

blkdeactive: use /sbin for mdamd

Do not using lvm's  @SBINDIR@ for mdadm path.
Set this directly to  /sbin/mdadm like other tools.

Group them separately
---
 scripts/blkdeactivate.sh.in |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index cfec0af..a4b8a8f 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -31,17 +31,17 @@ shopt -s dotglob nullglob
 
 TOOL=blkdeactivate
 
-sbindir="@SBINDIR@"
-
 DEV_DIR="/dev"
 SYS_BLK_DIR="/sys/block"
 
+MDADM="/sbin/mdadm"
 MOUNTPOINT="/bin/mountpoint"
+MPATHD="/sbin/multipathd"
 UMOUNT="/bin/umount"
+
+sbindir="@SBINDIR@"
 DMSETUP="$sbindir/dmsetup"
 LVM="$sbindir/lvm"
-MDADM="$sbindir/mdadm"
-MPATHD="/sbin/multipathd"
 
 if "$UMOUNT" --help | grep -- "--all-targets" >"$DEV_DIR/null"; then
 	UMOUNT_OPTS="--all-targets "


