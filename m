From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 11:22:24 -0400
Subject: master - tests: correct typo
Message-ID: <201707111522.v6BFMOXw015541@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21e0e98665f0a51b928e621ea5a6794d36d16a47
Commit:        21e0e98665f0a51b928e621ea5a6794d36d16a47
Parent:        429e613ba86386829d2bd3556d29158aff93a04f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 11 11:19:09 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 11 16:26:12 2017 +0200

tests: correct typo

Use defined MARKED_AS_USED_MSG shell var.
---
 test/shell/pv-ext-flags.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index cc21eab..bae16df 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -48,7 +48,7 @@ grep "$MARKED_AS_USED_MSG" err
 not pvchange -u "$dev1" 2>err
 grep "$MARKED_AS_USED_MSG" err
 not vgcreate $vg2 "$dev1" 2>err
-grep "$MARKED_AS_USED" err
+grep "$MARKED_AS_USED_MSG" err
 not pvremove "$dev1" 2>err
 grep "$MARKED_AS_USED_MSG" err
 
@@ -113,7 +113,7 @@ grep "$MARKED_AS_USED_MSG" err
 not pvchange -u "$dev1" 2>err
 grep "$MARKED_AS_USED_MSG" err
 not vgcreate $vg2 "$dev1" 2>err
-grep "$MARKED_AS_USED" err
+grep "$MARKED_AS_USED_MSG" err
 not pvremove "$dev1" 2>err
 grep "$MARKED_AS_USED_MSG" err
 


