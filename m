From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 12 Apr 2017 12:45:48 -0400
Subject: master - WHATS_NEW_DM: add recent dmsetup and dmfilemapd entries
Message-ID: <201704121645.v3CGjmvk023145@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5b0697c0535a532aa81bcf78e59fb6d7cdd9fe0
Commit:        f5b0697c0535a532aa81bcf78e59fb6d7cdd9fe0
Parent:        ba12a2e81a319c22353c8e52bf29f55c924b2d9f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Apr 12 17:41:29 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Apr 12 17:41:29 2017 +0100

WHATS_NEW_DM: add recent dmsetup and dmfilemapd entries

---
 WHATS_NEW_DM |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7afeb5e..23f3ce5 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,9 @@
 Version 1.02.139 - 
 ==================================
+  Flush stdout on each iteration when using --count or --interval.
+  Show detailed error message when execvp fails while starting dmfilemapd.
+  Fix segmentation fault when dmfilemapd is run with no arguments.
+  Numerous minor dmfilemapd fixes from coverity.
 
 Version 1.02.138 - 28th March 2017
 ==================================


