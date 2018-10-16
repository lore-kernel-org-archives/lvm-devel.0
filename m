From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Oct 2018 17:50:40 -0400
Subject: master - tests: add raid target presence check
Message-ID: <201810162150.w9GLoebS017363@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32f1afbe36f6cc804a8f4e669af7c90639389811
Commit:        32f1afbe36f6cc804a8f4e669af7c90639389811
Parent:        69bebfd9587e2db292051501d1a1e83d4f4564a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 23:44:15 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 16 23:49:35 2018 +0200

tests: add raid target presence check

---
 test/shell/lvcreate-raid1-read-error.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-raid1-read-error.sh b/test/shell/lvcreate-raid1-read-error.sh
index 6907758..322c60e 100644
--- a/test/shell/lvcreate-raid1-read-error.sh
+++ b/test/shell/lvcreate-raid1-read-error.sh
@@ -14,6 +14,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_raid 1 3 0 || skip
+
 # Test for MD raid1 kernel bug causing read
 # errors on failing first leg sectors.
 


