From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:26 -0400
Subject: master - lvconvert: drop limitation for converting lv
Message-ID: <201804201101.w3KB1QmM031113@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9068de011d900df46a87d6cb0de08160136bde66
Commit:        9068de011d900df46a87d6cb0de08160136bde66
Parent:        a7d077b89b71fb2ddd9e87526b5675aadf38dfba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 18 12:57:17 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:06:51 2018 +0200

lvconvert: drop limitation for converting lv

Fixing regresion on argument acceptance where any lv can be passed
with paramaterless lvconvert which is meant to figure out needed
operation - i.e. wait for  mirror synchronization.

User has no other 'effective' method to wait for mirror getting in-sync.
---
 WHATS_NEW              |    1 +
 tools/command-lines.in |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 192c5c2..82b47c5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Fix regression on acceptance of any LV on lvconvert.
   Restore usability of thin LV to be again external origin for another thin.
   Keep systemd vars on change event in 69-dm-lvm-metad.rules for systemd reload.
   Write systemd and non-systemd rule in 69-dm-lvm-metad.rules, GOTO active one.
diff --git a/tools/command-lines.in b/tools/command-lines.in
index e555e95..9d407d0 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -701,8 +701,8 @@ RULE: all and lv_is_converting
 lvconvert LV_mirror_raid
 OO: OO_LVCONVERT
 ID: lvconvert_start_poll
-DESC: Poll LV to continue conversion (also see --startpoll).
-RULE: all and lv_is_converting
+DESC: Poll LV to continue conversion (also see --startpoll)
+DESC: or waits till conversion/mirror syncing is finished
 FLAGS: SECONDARY_SYNTAX
 
 ---


