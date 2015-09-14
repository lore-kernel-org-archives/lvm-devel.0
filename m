From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Sep 2015 07:32:24 +0000 (UTC)
Subject: master - tests: no sync raid
Message-ID: <20150914073224.E4EBD611CE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a82292ec90bba2a3796e3c7f1872a2bf72270da
Commit:        2a82292ec90bba2a3796e3c7f1872a2bf72270da
Parent:        e42ee69988fc770314a355e6acd417e00e0c9623
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 14 09:29:10 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 09:31:27 2015 +0200

tests: no sync raid

---
 test/shell/lvconvert-mirror-basic.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 4a3e62f..a3ec38a 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -79,7 +79,7 @@ test_lvconvert() {
 			alloc="--alloc anywhere"
 		fi
 
-		lvcreate -aey -l2 --type mirror -m $start_count --mirrorlog $start_log_type \
+		lvcreate -aey -l2 --nosync --type mirror -m $start_count --mirrorlog $start_log_type \
 			-n $lv1 $vg $alloc
 		check mirror_legs $vg $lv1 $start_count_p1
 		# FIXME: check mirror log


