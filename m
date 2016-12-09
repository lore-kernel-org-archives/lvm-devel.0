From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Dec 2016 14:15:23 +0000 (UTC)
Subject: master - tests: fix missing exclusive activation
Message-ID: <20161209141523.D39EB602B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=900d203586faf1fef447002aa2e784cfc9575ad1
Commit:        900d203586faf1fef447002aa2e784cfc9575ad1
Parent:        c5aeb210155eff180ad5f1127ed451307bd7b854
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 8 16:27:24 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 9 15:15:02 2016 +0100

tests: fix missing exclusive activation

For cluster conversion  LV for caching needs to be activated
exclusively.
---
 test/shell/lvs-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index 2c518d0..74077ae 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -23,7 +23,7 @@ aux have_cache 1 3 0 || skip
 aux prepare_vg 5 8000
 
 # Use 10M origin size
-lvcreate -L10 -n $lv1 $vg
+lvcreate -aey -L10 -n $lv1 $vg
 lvcreate -H -L5 $vg/$lv1
 
 # replace 10M size with 5M size of cache device


