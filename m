From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  9 Sep 2021 14:14:22 +0000 (GMT)
Subject: main - tests: check lvm2 parses vdo statistics
Message-ID: <20210909141422.24E3D384B801@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd2dae464386033241afa35934cdeddfe47f6a77
Commit:        bd2dae464386033241afa35934cdeddfe47f6a77
Parent:        e6f735d411e5911de186a610932c9bb9638275eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 15:22:20 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 9 15:24:21 2021 +0200

tests: check lvm2 parses vdo statistics

---
 test/shell/lvcreate-vdo.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/shell/lvcreate-vdo.sh b/test/shell/lvcreate-vdo.sh
index 9fb2959db..44f8bf094 100644
--- a/test/shell/lvcreate-vdo.sh
+++ b/test/shell/lvcreate-vdo.sh
@@ -47,6 +47,7 @@ fi
 check lv_field $vg/$lv1 size "<1.24g"
 check lv_field $vg/${lv2} size "4.00g"
 check lv_field $vg/${lv2}_vdata size "4.00g"
+check lv_field $vg/${lv1} data_percent "0.00"
 lvremove -ff $vg
 
 


