From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 18 Nov 2013 17:01:45 +0000 (UTC)
Subject: master - test: Force label-based reporting in pv-duplicate.sh.
Message-ID: <20131118170145.D023560E54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8a6b8f467fadd5334fdb0c4a149753916e097db
Commit:        b8a6b8f467fadd5334fdb0c4a149753916e097db
Parent:        ae337d472eb973bbde80d641da9567acfa7874ff
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Nov 18 17:53:06 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Nov 18 17:53:06 2013 +0100

test: Force label-based reporting in pv-duplicate.sh.

---
 test/shell/pv-duplicate.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index 40d1f68..f315d86 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -21,5 +21,5 @@ vgcreate --metadatasize 128k $vg1 "$dev1"
 dd if="$dev1" of="$dev2" bs=256K count=1
 dd if="$dev1" of="$dev3" bs=256K count=1
 
-pvs "$dev3"
+pvs "$dev3" -o pv_uuid
 vgs $vg1


