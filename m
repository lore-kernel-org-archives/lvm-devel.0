From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 4 Jul 2018 07:42:03 -0400
Subject: 2018-06-01-stable - tests: update with --yes
Message-ID: <201807041142.w64Bg384019152@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1dbb22ba44460bf75c2dc7c0f72434abab40219
Commit:        c1dbb22ba44460bf75c2dc7c0f72434abab40219
Parent:        99cddd67a9dfcd6400640ac8ebf8d6d568ce19d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 24 20:49:59 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 4 13:41:00 2018 +0200

tests: update with --yes

vgcfgrestore needs to confirm restore while LVs from VG are present.
---
 test/shell/thin-restore.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
index 3682a8c..d8bae3c 100644
--- a/test/shell/thin-restore.sh
+++ b/test/shell/thin-restore.sh
@@ -33,7 +33,7 @@ vgcfgbackup -f backup $vg
 # use of --force is mandatory
 not vgcfgrestore -f backup $vg
 
-vgcfgrestore -f backup --force $vg
+vgcfgrestore -y -f backup --force $vg
 
 check lv_field $vg/pool transaction_id 1
 


