From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 31 Mar 2016 08:38:17 +0000 (UTC)
Subject: master - tests: vg-check-devs-used requires driver version 4.15 at least
Message-ID: <20160331083817.32ACE60E45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe7ae37f5e4af4f73aee5439dbef93d4facfaadf
Commit:        fe7ae37f5e4af4f73aee5439dbef93d4facfaadf
Parent:        9a086a660772fbe8e0baa5717db94982f5015137
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 31 10:38:05 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 31 10:38:05 2016 +0200

tests: vg-check-devs-used requires driver version 4.15 at least

---
 test/shell/vg-check-devs-used.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index c978b9e..26ba694 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -13,6 +13,9 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+# We need "dm" directory for dm devices in sysfs.
+aux driver_at_least 4 15 || skip
+
 aux prepare_devs 3 8
 
 vgcreate $vg $dev1 $dev2


