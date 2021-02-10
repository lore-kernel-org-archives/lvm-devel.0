From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:44:02 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20210210144402.C28A03857C7B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f49bedc0295d4b038004adfda64fafcfa8b1d2c7
Commit:        f49bedc0295d4b038004adfda64fafcfa8b1d2c7
Parent:        04cd4df847c682a65fa4c451d78b76a052d1155d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 15:34:12 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

WHATS_NEW: update

---
 WHATS_NEW | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index bf2c5806c..01ee40dc4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.03.12 - 
 ===================================
+  Add workaround to avoid read of internal 'converted' devices.
+  Prohibit merging snapshot into the read-only thick snapshot origin.
+  Restore support for flipping rw/r permissions for thin snapshot origin.
   Support resize of cached volumes.
   Disable autoactivation with global/event_activation=0.
   Check if lvcreate passes read_only_volume_list with tags and skips zeroing.


