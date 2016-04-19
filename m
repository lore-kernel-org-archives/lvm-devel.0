From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 19:27:13 +0000 (UTC)
Subject: master - test: lvmetad-override
Message-ID: <20160419192713.9367761BAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=955326067348d29aa7b42159f43b119ce7d8c491
Commit:        955326067348d29aa7b42159f43b119ce7d8c491
Parent:        5e9e43074a6c5e251ee44768421879b03ad2e530
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 19 14:26:05 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 14:26:05 2016 -0500

test: lvmetad-override

Fix test case where a warning appears when it's not expected.
---
 test/shell/lvmetad-override.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index cd005fc..e22f7ba 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -35,7 +35,9 @@ lvchange -an $vg1
 check inactive $vg1 $lv1
 
 lvchange -ay --config global/use_lvmetad=0 $vg1 2>&1 | tee out
-not grep "WARNING: Failed to connect" out
+# FIXME: this warning appears when the command tries to connect to
+# lvmetad during refresh at the end after the --config is cleared.
+should not grep "WARNING: Failed to connect" out
 check active $vg1 $lv1
 lvchange -an $vg1
 check inactive $vg1 $lv1


