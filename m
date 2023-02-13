From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:30 +0000 (GMT)
Subject: main - WHATS_NEW_DM: update
Message-ID: <20230213133130.696DF3881D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0fc2d418f76a9e98ab988ff5a3440a3beef5295f
Commit:        0fc2d418f76a9e98ab988ff5a3440a3beef5295f
Parent:        9b78f7eee9f231d88ed5ca05fbf6da8c473ab41e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 23:50:09 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 13:41:59 2023 +0100

WHATS_NEW_DM: update

---
 WHATS_NEW_DM | 1 +
 1 file changed, 1 insertion(+)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 020efe6f4..1f94e5e27 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.191 - 
 =====================================
+  Improve parallel creation of /dev/mapper/control device node.
   Import previous ID_FS_* udev records in 13-dm-disk.rules for suspended DM dev.
   Remove NAME="mapper/control" rule from 10-dm.rules to avoid udev warnings.
 

