From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:18 +0000 (GMT)
Subject: main - tests: different check for mounted volume
Message-ID: <20230506204618.CD92B3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4af8063c963f0610761d9cecbd6ed23b52f77256
Commit:        4af8063c963f0610761d9cecbd6ed23b52f77256
Parent:        2fde4b6baa09f33890d4a5b951dc51b81828ef63
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 6 19:39:25 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 22:43:22 2023 +0200

tests: different check for mounted volume

It appears newer mount allows repeated mounting ??
Anyway - do the check with grep.
---
 test/shell/lvconvert-thin-external-cache.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-thin-external-cache.sh b/test/shell/lvconvert-thin-external-cache.sh
index 465ce52ad..a8b95b274 100644
--- a/test/shell/lvconvert-thin-external-cache.sh
+++ b/test/shell/lvconvert-thin-external-cache.sh
@@ -51,7 +51,7 @@ not lvconvert --thin --thinpool $vg/tpool $vg/$lv1
 lvchange --cachemode writethrough $vg/$lv1
 
 # Check $lv1 remains mounted (so it's not been unmounted by systemd)
-not mount "$DM_DEV_DIR/$vg/$lv1" mnt
+mountpoint "$PWD/mnt"
 
 lvconvert --thin $vg/$lv1 --originname extorg --thinpool $vg/tpool
 

