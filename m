From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Jan 2020 04:32:54 -0500
Subject: master - WHATS_NEW: update
Message-ID: <45203.120012304325100183@us-mta-252.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7404216241827d903dcb3ff441bae0c8819309d2
Commit:        7404216241827d903dcb3ff441bae0c8819309d2
Parent:        bab3b70e3ae253da39da6fb9146ccf428cdb6ab3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 23 10:25:35 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 10:32:15 2020 +0100

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index b7aa4e9..66ea748 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.08 - 
 ====================================
+  Accept more output lines from vdo_format.
+  Prohibit reshaping of stacked raid LVs.
   Avoid running cache input arg validation when creating vdo pool.
   Prevent raid reshaping of stacked volumes.
   Added VDO lvmdbusd methods for enable/disable compression & dedupe.



