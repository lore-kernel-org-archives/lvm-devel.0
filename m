From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Oct 2020 20:47:40 +0000 (GMT)
Subject: master - tests: revert lvm shell use in pvck-dump
Message-ID: <20201027204740.0AF32385783F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05d23b2dd80919ebd2239cfd7f8e08d5de9ebace
Commit:        05d23b2dd80919ebd2239cfd7f8e08d5de9ebace
Parent:        5a94126e7a2824387c36d87f5ede97702a82cdda
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 27 15:44:56 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 27 15:44:56 2020 -0500

tests: revert lvm shell use in pvck-dump

doesn't work on my machine
---
 test/shell/pvck-dump.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index c27fcc471..80a01a214 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -145,7 +145,7 @@ pvcreate --pvmetadatacopies 2 --metadatasize 32M "$dev1"
 
 vgcreate $SHARED -s 64K --metadatasize 32M $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
-for i in $(seq 1 500); do echo "lvcreate -an -n lv$i -l1 $vg"; done | lvm
+for i in $(seq 1 500); do lvcreate -an -n lv$i -l1 $vg; done 
 
 pvck --dump headers "$dev1" > h1
 


