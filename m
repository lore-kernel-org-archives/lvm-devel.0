From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:49 +0000 (GMT)
Subject: main - tests: even more aggressive throttling
Message-ID: <20210322215349.83DF43858004@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=daca6e2c225889a8ee4bfe4f4724d92481df2558
Commit:        daca6e2c225889a8ee4bfe4f4724d92481df2558
Parent:        bee8027cfa296bd910c75d5000a60d7ef99ecd78
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 09:49:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:36:37 2021 +0100

tests: even more aggressive throttling

Try if the test gets slowed down with slower mirroring (1)
or we would need something better to beat the race.
---
 test/shell/pvmove-resume-multiseg.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index c94706ed1..5a32bc607 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -20,7 +20,7 @@ SKIP_WITH_LVMLOCKD=1
 . lib/inittest
 
 aux prepare_pvs 5 30
-aux throttle_dm_mirror 50 || :
+aux throttle_dm_mirror || :
 
 vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
 pvcreate --metadatacopies 0 "$dev4" "$dev5"


