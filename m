From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Apr 2020 13:36:30 +0000 (GMT)
Subject: stable-2.02 - WHATS_NEWS: update
Message-ID: <20200408133630.7B4683887033@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bac7d5951dd3b5b04d4532b342c1034802f0d466
Commit:        bac7d5951dd3b5b04d4532b342c1034802f0d466
Parent:        70d2ff38c0dfb4e46648102ed655afa9f0929c60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 8 15:22:25 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 15:36:01 2020 +0200

WHATS_NEWS: update

---
 WHATS_NEW    | 1 +
 WHATS_NEW_DM | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index cdc2396e6..0e65ff172 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
 
 Version 2.02.187 - 24th March 2020
 ==================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 925be5a7b..f1b4f2b6a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.172 - 
 ==================================
+  Fix dm_list interators with gcc 10 optimization (-ftree-pta).
+  Dmeventd handles timer without looping on short intervals.
 
 Version 1.02.170 - 24th March 2020
 ==================================



