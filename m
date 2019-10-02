From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 2 Oct 2019 09:29:00 -0400
Subject: master - test: increase size of raid10 LV allowing tests to succeed on fast storage
Message-ID: <201910021329.x92DT0wi030925@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b138a87f43bcfdd3f523556d54f0a482ecf8c40b
Commit:        b138a87f43bcfdd3f523556d54f0a482ecf8c40b
Parent:        242e2dccc3ba9f4f465a539159269623a357fe72
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 2 14:59:17 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 2 15:25:43 2019 +0200

test: increase size of raid10 LV allowing tests to succeed on fast storage

Also add health char check.
---
 test/shell/lvchange-rebuild-raid.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 22acb92..d2bb723 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -43,8 +43,8 @@ done
 ##############################################
 # Create an 8-way striped raid10 with 4 mirror
 # groups and rebuild selected PVs.
-lvcreate --type raid10 -m 1 -i 4 -l 2 -n $lv1 $vg
-_sync
+lvcreate --type raid10 -m 1 -i 4 -l 64 -n $lv1 $vg
+_sync "AAAAAAAA"
 
 # Rebuild 1st and 2nd device would rebuild a
 # whole mirror group and needs to be rejected.


