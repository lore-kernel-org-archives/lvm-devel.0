From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:56 +0000 (GMT)
Subject: main - tests: check for at least 1G of RAM
Message-ID: <20220907130456.3EB3F385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1e05cf2b526fbd8689dca8b0b232f0b1ce8ed7c
Commit:        e1e05cf2b526fbd8689dca8b0b232f0b1ce8ed7c
Parent:        a6e47a161240e977bac5522d85e92fff3c1c9026
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 31 13:57:41 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: check for at least 1G of RAM

This test requires quite some RAM to be there.
---
 test/shell/lvconvert-raid-reshape.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index bc6eaa733..e55ab7ab9 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -20,6 +20,8 @@ LVM_SKIP_LARGE_TESTS=0
 which mkfs.ext4 || skip
 aux have_raid 1 14 0 || skip
 
+test "$(aux total_mem)" -gt 1048576 || skip "Not enough RAM for this test"
+
 if [ $LVM_SKIP_LARGE_TESTS -eq 0 ]
 then
 	aux prepare_pvs 65 9

