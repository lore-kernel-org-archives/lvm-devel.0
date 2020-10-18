From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:17 +0000 (GMT)
Subject: stable-2.02 - WHATS_NEWS: update
Message-ID: <20201018210217.DF6FC3858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9bddffd7adf75d8f63041dfeb9b73a783757b43d
Commit:        9bddffd7adf75d8f63041dfeb9b73a783757b43d
Parent:        ef5cddc20847b64b11a729ba3ce5dde12a9f606c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 8 15:22:25 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 23:14:12 2020 +0200

WHATS_NEWS: update

---
 WHATS_NEW | 1 +
 1 file changed, 1 insertion(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index dfaec8c53..0a916438a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
   Support interruption for bcache waiting.
   Fix bcache when device has too many failing writes.
   Fix bcache waiting for IO completion with failing disks.


