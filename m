From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 24 Apr 2023 22:14:38 +0000 (GMT)
Subject: main - tests: use 300M lv size for xfs
Message-ID: <20230424221438.7F4FC3858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c8901dabde8d962a95a827f249ad50a86b0a42c
Commit:        7c8901dabde8d962a95a827f249ad50a86b0a42c
Parent:        e42b56c31b71751bcd9d9cc9bae765433fa68027
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 24 22:18:10 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 00:12:31 2023 +0200

tests: use 300M lv size for xfs

---
 test/shell/integrity-large.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 68822e3ef..37823ab96 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -96,7 +96,7 @@ _verify_data_on_lv() {
 # be extended from 4MB to 8MB.
 
 _prepare_vg
-lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 -n $lv1 -L 300 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
 _add_data_to_lv

