From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 2 Oct 2019 11:15:47 -0400
Subject: stable-2.02 - test: increase size of raid10 LV allowing tests to succeed on fast storage
Message-ID: <201910021515.x92FFlA5004069@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8632aa5fd371b9a2dc1996a65135b35e9c006036
Commit:        8632aa5fd371b9a2dc1996a65135b35e9c006036
Parent:        a0b30eadd14ec3cc0f47f8d5cddd3026ffe08b31
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 2 14:59:17 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 2 17:03:52 2019 +0200

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


