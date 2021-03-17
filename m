From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:44 +0000 (GMT)
Subject: main - tests: require newer version of raid target
Message-ID: <20210317000044.B0357385043E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87659256f043ba7a76716cb8c97c350d723209db
Commit:        87659256f043ba7a76716cb8c97c350d723209db
Parent:        92ee16f7c0d5d6983b90fe97d31e2884a8e5804d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 21:37:19 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:59:50 2021 +0100

tests: require newer version of raid target

---
 test/shell/lvconvert-raid-regionsize.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 924e95a39..23d54d05f 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -85,7 +85,7 @@ else
   echo "Skipping RAID6 tests"
 fi
 
-if aux have_raid 1 10 1; then
+if aux have_raid 1 12 0; then
 # Create 6-way raid01
 lvcreate --yes -aey --type raid10 -i 3 -m 1 --stripesize 128K -R 256K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid10"


