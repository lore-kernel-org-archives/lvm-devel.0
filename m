From: okozina <okozina@fedoraproject.org>
Date: Mon, 20 Apr 2015 08:42:31 +0000 (UTC)
Subject: master - WHATS_NEW: update for various commits
Message-ID: <20150420084231.0C76460EAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de4791c052b1576bb9de73b3fa8e51b771522f7e
Commit:        de4791c052b1576bb9de73b3fa8e51b771522f7e
Parent:        5cd6381717696ad1513a9f8ff1cbd8fa3098e4b1
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Apr 20 10:31:43 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Apr 20 10:38:54 2015 +0200

WHATS_NEW: update for various commits

add info for various commits, most significant were:

- toollib: close connection to lvmetad after fork
  (fe30658a4d5fe4e4e6bb346c9c9ee7142a98f49d)

- toollib: do not spawn polling in lv_change_activate
  (c26d81d6e6939906729d91fae83cd8bbdd743bb7)

- pvmove: split pvmove_update_metadata function
  (65623b63a20a221b48dfd87455dc77f5ac0c6bf4)

- lvconvert: move poll code in before refactoring
  (5190f566055ab4584772b1288fd8cbf69565eb4a)

- pvmove: move poll code in before refactoring
  (a098aa419f5be5d8f805ab6dc747770e58a4b7b1)
---
 WHATS_NEW |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9c306db..987a7c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.02.119 - 
 ==================================
+  Close connection to lvmetad after fork.
+  Make lvchange able to resume background pvmove polling again.
+  Split pvmove update metadata fn in an initial one and a subsequent one.
+  Refactor shared pvmove and lvconvert code into new _poll files.
   Add --unconfigured option to dumpconfig to print strings unconfigured.
   Add --withfullcomments option to dumpconfig to print full comment.
   Check for lvm binary in blkdeactivate and skip LVM processing if not present.


