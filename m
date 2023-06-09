From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:02:02 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20230609160202.B51293858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ac5dbfd09e771f087a9467aca8a0d5905084459
Commit:        7ac5dbfd09e771f087a9467aca8a0d5905084459
Parent:        9105890d43bd1b6fe514114f671af2e946e13083
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 17:52:00 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:35 2023 +0200

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 493567c5d..cb38ba72e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 version 2.03.22 - 
 =================================
+  Enhance lvm_import_vdo and use snapshot when converting VDO volume.
+  Fix parsed of VDO metadata.
   Fix failing -S|--select for non-reporting cmds if using LV info/status fields.
 
 version 2.03.21 - 21st April 2023

