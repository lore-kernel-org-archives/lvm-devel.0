From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Mar 2015 15:12:49 +0000 (UTC)
Subject: master - tests: drop vg2 at end of test
Message-ID: <20150326151249.95D1361192@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a87fadbb026ca121c8af8669e68673aece46eb2
Commit:        8a87fadbb026ca121c8af8669e68673aece46eb2
Parent:        22d43ee14a1a9700b76960da2c983ff55cc3630c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 26 16:11:29 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 26 16:11:29 2015 +0100

tests: drop vg2 at end of test

---
 test/shell/select-tools.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index d04ed0a..b9e4b2f 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -273,3 +273,4 @@ pvchange -a --deltag 309 --deltag tag
 # iterates over LVs with process_each_lv_in_vg - so internally it actually
 # operates per-LV, but we still need the selection to be done per-VG)
 vgremove --yes -S 'lv_name=lv2' # should remove whole vg1, not just the lv2
+vgremove --yes $vg2


