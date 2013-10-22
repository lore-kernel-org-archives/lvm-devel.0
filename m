From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Oct 2013 14:37:26 +0000 (UTC)
Subject: master - WHATS_NEW: typo
Message-ID: <20131022143726.0D4CA610E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9883bffb0403d743641bb0971332b5ff0e373652
Commit:        9883bffb0403d743641bb0971332b5ff0e373652
Parent:        b109bfc1ef7e20a72170a83dc9244c8b21ea658c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 22 16:37:02 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 22 16:37:02 2013 +0200

WHATS_NEW: typo

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c2e511f..7cfa87c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.104
 ===================================
-  Fix endless loop for blkdeactivte <device>... if unable to umount/deactivate.
+  Fix endless loop in blkdeactivate <device>... if unable to umount/deactivate.
   Add dev-block-<major>:<minor>.device systemd alias for complete PV tracking.
   Use major:minor as short form of --major and --minor arg for pvscan --cache.
   Remove 2>/dev/null from three lvm commands executed by vgimportclone.


