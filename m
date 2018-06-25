From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 25 Jun 2018 09:10:10 -0400
Subject: master - tests: update with --yes
Message-ID: <201806251310.w5PDAAGQ031441@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19b92ae3f3185919a0a1cef849a9a003101d4429
Commit:        19b92ae3f3185919a0a1cef849a9a003101d4429
Parent:        cea88a9e4ee5a2aa28b52d673fba66327e88ff6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 24 20:49:59 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 25 15:07:55 2018 +0200

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
 


