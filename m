From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Jun 2015 11:43:59 +0000 (UTC)
Subject: master - tests: skip when snapshot does not work
Message-ID: <20150623114359.6B36A60666@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae76e8f0d0659482e8c0440a93d63a9ce5786b10
Commit:        ae76e8f0d0659482e8c0440a93d63a9ce5786b10
Parent:        7ee3ccd826e609fa62a57205f0e8480686f906af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 13:25:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 23 13:25:09 2015 +0200

tests: skip when snapshot does not work

Some older kernel (i.e. 3.11.10 on fc20) do not work properly.
Skip the test if snapshot does not meet 50%.
---
 test/api/percent.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/api/percent.sh b/test/api/percent.sh
index 0031a67..a9b7b90 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -22,6 +22,8 @@ lvcreate -aey -l 5 -n foo $vg
 lvcreate -s -n snap $vg/foo -l 3 -c 4k
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/snap2" count=1 bs=1024 oflag=direct
+# skip test with broken kernel
+check lv_field $vg/snap2 data_percent "50.00" || skip
 lvcreate -aey --type mirror -m 1 -n mirr $vg -l 1 --mirrorlog core
 lvs -a $vg
 aux apitest percent $vg


