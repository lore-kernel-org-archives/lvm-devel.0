From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 May 2015 15:22:22 +0000 (UTC)
Subject: master - tests: remove forgotten -vvvv option
Message-ID: <20150512152222.D32A260403@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ec51e6185ba84578fbe314ba96be8b7d0f18bdc
Commit:        2ec51e6185ba84578fbe314ba96be8b7d0f18bdc
Parent:        257f7febc7e94f1e5b76593387f8791ac8c1b65d
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 12 16:00:08 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 12 17:16:54 2015 +0200

tests: remove forgotten -vvvv option

---
 test/shell/pvmove-resume-2.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 5bdfd7d..7ae3721 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -91,8 +91,7 @@ lvchange_single() {
 }
 
 lvchange_all() {
-	# remove -vvvv
-	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -vvvv -aey $vg/$lv1 $vg/$lv2
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1 $vg/$lv2
 
 	# we don't want to spawn more than $1 background pollings
 	if test -e LOCAL_LVMPOLLD; then


