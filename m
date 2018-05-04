From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 4 May 2018 10:54:58 -0400
Subject: master - tests: don't rely on cache target in component-raid.sh
Message-ID: <201805041454.w44Eswl9026827@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bf92875f7f4633d457640af2503c06ffdee7f37
Commit:        8bf92875f7f4633d457640af2503c06ffdee7f37
Parent:        bc50dc6e70453c98e45aaa845db2828e586f9370
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri May 4 16:53:16 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri May 4 16:54:01 2018 +0200

tests: don't rely on cache target in component-raid.sh

Lead to unnecessary skips of the test.
---
 test/shell/component-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/component-raid.sh b/test/shell/component-raid.sh
index 84f823f..4ef9600 100644
--- a/test/shell/component-raid.sh
+++ b/test/shell/component-raid.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_cache 1 3 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5 80
 


