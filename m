From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:52 +0000 (GMT)
Subject: dev-next - WHATS_NEW: update
Message-ID: <20210331214852.A7DB53858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e8b4306eb018a4a4fc8d7a68780563e929180367
Commit:        e8b4306eb018a4a4fc8d7a68780563e929180367
Parent:        acac3cb52457b536cf8e984ce947a0ac2e837a5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 09:59:26 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 09:59:26 2021 +0100

WHATS_NEW: update

---
 WHATS_NEW | 1 +
 1 file changed, 1 insertion(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5d018ef36..80e16d880 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.12 - 
 ===================================
+  Do not include editline/history.h when using editline library.
   Support lvconvert -Zn with thin-pool conversion.
   Support error and zero segtype for thin-pool data for testing.
   Support mixed extension for striped, error and zero segtypes.


