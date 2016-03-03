From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Mar 2016 09:20:16 +0000 (UTC)
Subject: master - tests: drop check for md5sum
Message-ID: <20160303092016.E3935605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e718ec66679aad42773901a40e168ba4c3f3f50
Commit:        5e718ec66679aad42773901a40e168ba4c3f3f50
Parent:        49839b6d9677f40993b2468bc85e8cc8c82f9a8e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 2 11:12:00 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 3 10:17:03 2016 +0100

tests: drop check for md5sum

---
 test/shell/error-usage.sh |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index 3f6bf97..531dad3 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -16,8 +16,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-which md5sum || skip
-
 aux prepare_pvs 1
 
 vgcreate -s 256k $vg $(cat DEVICES)


