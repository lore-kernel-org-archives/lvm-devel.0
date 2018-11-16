From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:33:20 -0500
Subject: master - tests: drop unwanted backup
Message-ID: <201811162333.wAGNXKPh016152@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a23ed35f6c14e2f914796c34fea2404d54b08302
Commit:        a23ed35f6c14e2f914796c34fea2404d54b08302
Parent:        97a95f9648ffe2882ad7fadcea3f0908c8947c7d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 12 17:57:40 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:30:50 2018 +0100

tests: drop unwanted backup

---
 test/shell/lvcreate-cache-no-tools.sh |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-cache-no-tools.sh b/test/shell/lvcreate-cache-no-tools.sh
index 253c8a5..bbab0fe 100644
--- a/test/shell/lvcreate-cache-no-tools.sh
+++ b/test/shell/lvcreate-cache-no-tools.sh
@@ -76,7 +76,6 @@ lvcreate -aey -l1 -n $lv1 $vg
 lvcreate -H -l2 $vg/$lv1
 
 check_change_ "Check is skipped"
-vgcfgbackup -f /dev/shm/back
 
 # prepare fake version of cache_check tool that reports old version
 make_fake_ "0.1.0"


