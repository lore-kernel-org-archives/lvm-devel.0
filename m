From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Oct 2018 15:57:04 -0400
Subject: master - tests: fix tested targeted
Message-ID: <201810161957.w9GJv4KF002201@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c15ac326cc29b5d91e726647d584c1b563c8c294
Commit:        c15ac326cc29b5d91e726647d584c1b563c8c294
Parent:        05b57748274492aa76e530e4513e5f8e9a39a735
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 19:05:19 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 16 21:56:00 2018 +0200

tests: fix tested targeted

Fix cut&paste bug.
---
 test/shell/profiles-vdo.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/profiles-vdo.sh b/test/shell/profiles-vdo.sh
index 4a0f07e..c870315 100644
--- a/test/shell/profiles-vdo.sh
+++ b/test/shell/profiles-vdo.sh
@@ -18,7 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_cache 1 8 0 || skip
+aux have_vdo 6 2 0 || skip
 
 PDIR="$LVM_SYSTEM_DIR/profile"
 PFILE="vdo-test"


