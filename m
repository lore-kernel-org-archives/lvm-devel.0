From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:37 -0400
Subject: master - lvconvert: accept striped LV as snapshot COW LV
Message-ID: <201803172234.w2HMYbe2011143@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7273822757d6ccc7d4178f01c96fc3be52702a3
Commit:        d7273822757d6ccc7d4178f01c96fc3be52702a3
Parent:        67fbe980a710a790d6d1ea7f9cfaf9d8c6e50448
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 14:01:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

lvconvert: accept striped LV as snapshot COW LV

Restore back acceptance of striped LV to be valid COW LV.
---
 WHATS_NEW              |    1 +
 man/lvconvert.8_pregen |    4 ++--
 tools/command-lines.in |    4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5711f41..995b389 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Again accept striped LV as COW LV with lvconvert -s (2.02.169).
   Fix raid target version testing for supported features.
   Allow activation of pools when thin/cache_check tool is missing.
   Remove RaidLV on creation failure when rmeta devices can't be activated.
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 5171d6a..e0e38b9 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -760,7 +760,7 @@ Combine a former COW snapshot (second arg) with a former
 origin LV (first arg) to reverse a splitsnapshot command.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBsnapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
+\fBlvconvert\fP \fB--type\fP \fBsnapshot\fP \fILV\fP \fILV\fP\fI_linear_striped\fP
 .br
 .RS 4
 .ad l
@@ -1694,7 +1694,7 @@ Combine a former COW snapshot (second arg) with a former
 origin LV (first arg) to reverse a splitsnapshot command.
 .br
 .P
-\fBlvconvert\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
+\fBlvconvert\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP \fILV\fP\fI_linear_striped\fP
 .br
 .RS 4
 .ad l
diff --git a/tools/command-lines.in b/tools/command-lines.in
index a1776ce..2a6882e 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -626,7 +626,7 @@ FLAGS: SECONDARY_SYNTAX
 # will not be checked.
 
 # alternate form of lvconvert --snapshot
-lvconvert --type snapshot LV LV_linear
+lvconvert --type snapshot LV LV_linear_striped
 OO: --snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
 ID: lvconvert_combine_split_snapshot
 DESC: Combine a former COW snapshot (second arg) with a former
@@ -634,7 +634,7 @@ DESC: origin LV (first arg) to reverse a splitsnapshot command.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: all and lv_is_visible
 
-lvconvert --snapshot LV LV_linear
+lvconvert --snapshot LV LV_linear_striped
 OO: --type snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
 ID: lvconvert_combine_split_snapshot
 DESC: Combine a former COW snapshot (second arg) with a former


