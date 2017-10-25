From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Oct 2017 16:05:10 -0400
Subject: master - commands: drop secondary for lvconvert --type snapshot
Message-ID: <201710252005.v9PK5AOX029385@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44c4fe8e61e4ae43e7513130bc62f1a584879b2e
Commit:        44c4fe8e61e4ae43e7513130bc62f1a584879b2e
Parent:        35df4b10eb17065f893bbf96cba01efdb9f46e4a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 25 19:56:40 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 25 22:02:54 2017 +0200

commands: drop secondary for lvconvert --type snapshot

Both form were marked and secondary thus none of the supported
syntax entered manpage.

This restores appearance of snapshot conversion in man page.
---
 tools/command-lines.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 265bda8..d0e5e06 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -633,7 +633,6 @@ DESC: Combine a former COW snapshot (second arg) with a former
 DESC: origin LV (first arg) to reverse a splitsnapshot command.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: all and lv_is_visible
-FLAGS: SECONDARY_SYNTAX
 
 lvconvert --snapshot LV LV_linear
 OO: --type snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT


