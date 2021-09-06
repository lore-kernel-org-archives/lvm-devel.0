From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  6 Sep 2021 13:25:09 +0000 (GMT)
Subject: main - vdo: lvm_import_vdo fix max_discard size
Message-ID: <20210906132509.45A8A3858023@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d5b7de54f21ce5e34d533599f9d5a42f2977cd5
Commit:        8d5b7de54f21ce5e34d533599f9d5a42f2977cd5
Parent:        79427151dc5ffb5faff133c57e058acbad00dd10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 6 14:57:43 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 6 15:19:51 2021 +0200

vdo: lvm_import_vdo fix max_discard size

Use correct 4K units in lvm2 for max_discard VDO option.
---
 scripts/lvm_import_vdo.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index ae2892949..65d2eee38 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -320,7 +320,7 @@ allocation {
 	vdo_logical_threads = $vdo_logicalThreads
 	vdo_physical_threads = $vdo_physicalThreads
 	vdo_write_policy = $vdo_writePolicy
-	vdo_max_discard = $(( $(get_kb_size_with_unit_ "$vdo_maxDiscardSize") * 1024 ))
+	vdo_max_discard = $(( $(get_kb_size_with_unit_ "$vdo_maxDiscardSize") / 4 ))
 	vdo_pool_header_size = 0
 }
 EOF


