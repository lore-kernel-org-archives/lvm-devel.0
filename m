From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Jul 2017 07:53:25 -0400
Subject: master - tests: use properly quoted device list
Message-ID: <201707121153.v6CBrP2I012166@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1daa1cc3a98b8812912875773ad3be1b9b173c4c
Commit:        1daa1cc3a98b8812912875773ad3be1b9b173c4c
Parent:        5a91b0a2e24dca07441aefb09fcaccaf98088a03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 12 13:50:25 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 12 13:50:25 2017 +0200

tests: use properly quoted device list

---
 test/api/percent.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/api/percent.sh b/test/api/percent.sh
index f25c441..32c0892 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -18,8 +18,9 @@ SKIP_WITH_LVMPOLLD=1
 aux kernel_at_least 2 6 33 || skip
 
 aux prepare_pvs 2
+get_devs
 
-vgcreate -s 4k $vg $(cat DEVICES)
+vgcreate -s 4k "$vg" "${DEVICES[@]}"
 lvcreate -aey -l 5 -n foo $vg
 lvcreate -s -n snap $vg/foo -l 3 -c 4k
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k


