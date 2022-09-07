From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:58 +0000 (GMT)
Subject: main - tests: no caching for blkid in testing
Message-ID: <20220907130458.85B9D3858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afcf954491416dab5845d25dc45c53c3e8000773
Commit:        afcf954491416dab5845d25dc45c53c3e8000773
Parent:        80b782f86ffea19a9881b026df3dc133eebffbe5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 31 14:14:59 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: no caching for blkid in testing

---
 test/lib/lvm_vdo_wrapper.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/lvm_vdo_wrapper.sh b/test/lib/lvm_vdo_wrapper.sh
index 90d0b2ce8..b1da2e35b 100755
--- a/test/lib/lvm_vdo_wrapper.sh
+++ b/test/lib/lvm_vdo_wrapper.sh
@@ -142,7 +142,7 @@ esac
 
 test -n "${vdo_device-}" || vdo_die_ "VDO device is missing"
 
-blkid -s UUID -o value "${vdo_device}" || true
+blkid -c /dev/null -s UUID -o value "${vdo_device}" || true
 
 devsize=$(blockdev --getsize64 "$vdo_device")
 devsize=$(( devsize / 4096 )) # convert to 4KiB units

