From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Jan 2020 11:42:08 -0500
Subject: stable-2.02 - WHATS_NEW: update
Message-ID: <34661.120011311420400887@us-mta-402.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=846ae8d49d74ac61c2caed84c9720aedbe9867ae
Commit:        846ae8d49d74ac61c2caed84c9720aedbe9867ae
Parent:        c575c1c9ff71d95b6af0ec75798dd597491ca0b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 13 17:37:29 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 13 17:41:44 2020 +0100

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 047479b..c885a21 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.187 - 
 ===================================
+  Avoid running cache input arg validation when creating vdo pool.
+  Prevent raid reshaping of stacked volumes.
   Ensure minimum required region size on striped RaidLV creation.
   Fix resize of thin-pool with data and metadata of different segtype.
   Fix splitting mirror leg in cluster.



