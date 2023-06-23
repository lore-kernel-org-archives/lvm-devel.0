From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:49 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20230623160949.590453858C36@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a5712ada4753cd034d862389e6e91af387c406f
Commit:        0a5712ada4753cd034d862389e6e91af387c406f
Parent:        9756824f6447fb8c6096760e802d4f616929f710
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 18:07:31 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:08:10 2023 +0200

WHATS_NEW: update

---
 WHATS_NEW | 1 +
 1 file changed, 1 insertion(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index cb38ba72e..de40d239d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 version 2.03.22 - 
 =================================
+  Add lvm.conf thin_restore and cache_restore settings.
   Enhance lvm_import_vdo and use snapshot when converting VDO volume.
   Fix parsed of VDO metadata.
   Fix failing -S|--select for non-reporting cmds if using LV info/status fields.

