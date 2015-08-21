From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 21 Aug 2015 22:00:52 +0000 (UTC)
Subject: master - tests: fix check for lvmlockd test
Message-ID: <20150821220052.D0B7D6036F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba898b9ab6f02153eb3fa44d1e893f6b49424652
Commit:        ba898b9ab6f02153eb3fa44d1e893f6b49424652
Parent:        d827dd8b053d69adf3cdfa6f3b8071af4b0e3846
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 21 17:00:21 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 21 17:00:21 2015 -0500

tests: fix check for lvmlockd test

---
 test/shell/lvmlockd-lv-types.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmlockd-lv-types.sh b/test/shell/lvmlockd-lv-types.sh
index 79cde22..64c0362 100644
--- a/test/shell/lvmlockd-lv-types.sh
+++ b/test/shell/lvmlockd-lv-types.sh
@@ -13,7 +13,7 @@ test_description='Check lvmlockd lock_args for different LV types'
 
 . lib/inittest
 
-test -e LOCAL_LVMLOCKD && skip
+[ -z "$LVM_TEST_LVMLOCKD" ] && skip;
 
 if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK" ; then
 LOCKARGS1="1.0.0:70254592"


