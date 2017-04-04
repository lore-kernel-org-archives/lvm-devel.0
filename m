From: David Teigland <teigland@sourceware.org>
Date: Tue, 4 Apr 2017 17:48:59 -0400
Subject: master - lvconvert: fix converting hidden lv to pool
Message-ID: <201704042148.v34Lmxic016012@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76b70d5058cbbe41b60b99f11cda5e698b3c62e9
Commit:        76b70d5058cbbe41b60b99f11cda5e698b3c62e9
Parent:        b951d0433765d3ed7b0507906dec1894053cef4f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 4 16:47:47 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 4 16:47:47 2017 -0500

lvconvert: fix converting hidden lv to pool

A hidden LV can not be converted to a thin pool or cache pool.
---
 tools/command-lines.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index b2682fa..fe98cc6 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -495,6 +495,7 @@ ID: lvconvert_to_thinpool_or_swap_metadata
 DESC: Convert LV to type thin-pool (variant, use \\-\\-type thin-pool).
 DESC: Swap metadata LV in a thin pool (variant, use \\-\\-swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
+RULE: all and lv_is_visible
 
 ---
 
@@ -533,6 +534,7 @@ ID: lvconvert_to_cachepool_or_swap_metadata
 DESC: Convert LV to type cache-pool (variant, use \\-\\-type cache-pool).
 DESC: Swap metadata LV in a cache pool (variant, use \\-\\-swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
+RULE: all and lv_is_visible
 
 ---
 


