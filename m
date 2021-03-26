From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 26 Mar 2021 23:42:21 +0000 (GMT)
Subject: main - tests: increase mirror throttling
Message-ID: <20210326234221.645B7385800F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53338cf566838381febe37d8254275e5f2a408ce
Commit:        53338cf566838381febe37d8254275e5f2a408ce
Parent:        8e9bc52b15106d0edaf47f56e4f467f8365597f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 27 00:29:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 27 00:29:28 2021 +0100

tests: increase mirror throttling

---
 test/shell/pvmove-resume-multiseg.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index b38195a84..1263d81ed 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -20,7 +20,7 @@ SKIP_WITH_LVMLOCKD=1
 . lib/inittest
 
 aux prepare_pvs 5 40
-aux throttle_dm_mirror 50 || :
+aux throttle_dm_mirror 40 || :
 
 vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
 pvcreate --metadatacopies 0 "$dev4" "$dev5"


