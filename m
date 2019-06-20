From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jun 2019 05:22:53 -0400
Subject: stable-2.02 - tests: drop unwanted backup
Message-ID: <201906200922.x5K9MrXn009417@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=24186cd9ce2d24616da7aba56787bc97acb2e42a
Commit:        24186cd9ce2d24616da7aba56787bc97acb2e42a
Parent:        2806e6265f58308697d183a4d99967604663b734
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 12 17:57:40 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 20 11:21:59 2019 +0200

tests: drop unwanted backup

---
 test/shell/lvcreate-cache-no-tools.sh |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-cache-no-tools.sh b/test/shell/lvcreate-cache-no-tools.sh
index 23528e4..e7d947a 100644
--- a/test/shell/lvcreate-cache-no-tools.sh
+++ b/test/shell/lvcreate-cache-no-tools.sh
@@ -76,7 +76,6 @@ lvcreate -aey -l1 -n $lv1 $vg
 lvcreate -H -l2 $vg/$lv1
 
 check_change_ "Check is skipped"
-vgcfgbackup -f /dev/shm/back
 
 # prepare fake version of cache_check tool that reports old version
 make_fake_ "0.1.0"


