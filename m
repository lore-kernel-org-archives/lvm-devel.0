From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jan 2021 15:10:07 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20210122151007.23DFB398D000@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=665d265349596d1d4e67b1db5cb33f78338f4c7c
Commit:        665d265349596d1d4e67b1db5cb33f78338f4c7c
Parent:        fa2fa9f36da74d228db22a7765aa4df28107f71a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 16:09:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 22 16:09:38 2021 +0100

WHATS_NEW: update

---
 WHATS_NEW | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index ffefc9d2d..9fda1de87 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.03.12 - 
 ===================================
+  Support online rename of VDO pools.
+  Imporove removal of pmspare when last pool is removed.
+  Fix problem with wiping of converted LVs.
+  Fix memleak in scanning  (2.03.11).
   Fix corner case allocation for thin-pools.
 
 Version 2.03.11 - 08th January 2021


