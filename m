From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 17:03:39 -0400
Subject: master - tests: show more debug info
Message-ID: <201706242103.v5OL3dWW031867@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0cc49bda15c041dc6e53b17a10b9306abd7d1a93
Commit:        0cc49bda15c041dc6e53b17a10b9306abd7d1a93
Parent:        1b9bf5ce9e65c22e5e06025ca9700cecd8addc68
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 23:01:26 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 23:02:42 2017 +0200

tests: show more debug info

Helpful for analysis (revert later).
---
 test/shell/lvconvert-repair-raid-dmeventd.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index 84b0591..5b5bdcc 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -33,4 +33,7 @@ mkfs.ext3 "$DM_DEV_DIR/$vg/4way"
 sleep 5 # FIXME: need a "poll" utility, akin to "check"
 aux enable_dev "$dev2" "$dev4"
 
-vgremove -ff $vg
+dmsetup table
+dmsetup status
+dmsetup info -c
+vgremove -vvvv -ff $vg


