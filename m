From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Jun 2015 11:44:01 +0000 (UTC)
Subject: master - tests: use vgscan after enable_dev
Message-ID: <20150623114401.8144860666@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c6b3f5ec37bf4e0d361d241a0b6f9d0902a4359
Commit:        4c6b3f5ec37bf4e0d361d241a0b6f9d0902a4359
Parent:        ae76e8f0d0659482e8c0440a93d63a9ce5786b10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 13:39:57 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 23 13:39:57 2015 +0200

tests: use vgscan after enable_dev

Since our test environment runs also in non-real-udev world,
it's using  /etc/.cache file with scanned files.

So in this case it is mandatory the user runs 'vgscan'
after a device reappears in the system.

This 'first' lvm2 command then fixes metadata (just like vgs did).
---
 test/shell/unlost-pv.sh |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index c56d488..76bf8a1 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -48,7 +48,11 @@ check_ not
 aux disable_dev "$dev1"
 vgreduce --removemissing --force $vg
 aux enable_dev "$dev1"
-vgs 2>&1 | grep 'Removing PV'
-vgs 2>&1 | not grep 'Removing PV'
+
+vgscan 2>&1 | tee out
+grep 'Removing PV' out
+
+vgs 2>&1 | tee out
+not grep 'Removing PV' out
 
 vgremove -ff $vg


