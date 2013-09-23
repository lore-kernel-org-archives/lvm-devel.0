From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:32 +0000 (UTC)
Subject: master - tests: hide expected error message
Message-ID: <20130923101632.1A85460FFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ced563e3a729f3440cf69c4ed1f290d474fbd791
Commit:        ced563e3a729f3440cf69c4ed1f290d474fbd791
Parent:        ebf66ac316da27399308d8cd553988c78f7ea150
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 18 10:48:51 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 12:14:20 2013 +0200

tests: hide expected error message

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7939949..d27d263 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -380,7 +380,7 @@ disable_dev() {
 		maj=$(($(stat --printf=0x%t "$dev")))
 		min=$(($(stat --printf=0x%T "$dev")))
 		echo "Disabling device $dev ($maj:$min)"
-		dmsetup remove -f "$dev" || true
+		dmsetup remove -f "$dev" 2>/dev/null || true
 		notify_lvmetad --major "$maj" --minor "$min"
 	done
 	finish_udev_transaction


