From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 May 2014 11:23:33 +0000 (UTC)
Subject: master - tests: drop nosync
Message-ID: <20140519112333.31398602D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ecccb759048c143a4e9e2e1b96afb6b6178a9325
Commit:        ecccb759048c143a4e9e2e1b96afb6b6178a9325
Parent:        477351fc4d2f2d0a55089fb6b6bc1f26e2605f7b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 19 13:22:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 19 13:22:46 2014 +0200

tests: drop nosync

Mirrors currently do not support any conversion,
when they are created no-sync.
---
 test/shell/lvconvert-mirror-basic.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 49d32aa..28258b2 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -77,7 +77,7 @@ test_lvconvert() {
 		fi
 
 		lvcreate -aey -l2 --type mirror -m $start_count --mirrorlog $start_log_type \
-			--nosync -n $lv1 $vg $alloc
+			-n $lv1 $vg $alloc
 		check mirror_legs $vg $lv1 $start_count_p1
 		# FIXME: check mirror log
 	else


