From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:17 +0000 (GMT)
Subject: dev-next - tests: add should for racy test
Message-ID: <20210331214917.D78DA3858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9bcc76b63c14566e5ced09ac18129e1c9a98e8e4
Commit:        9bcc76b63c14566e5ced09ac18129e1c9a98e8e4
Parent:        5feb99dda68dd492929fff0d7b15d3ef0ab86347
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 00:43:44 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 00:43:44 2021 +0100

tests: add should for racy test

Depending on kernel, the race may or may not happen.
---
 test/shell/lvextend-raid.sh | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 08b34d00c..87ad802c3 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -74,7 +74,8 @@ check lv_field $vg/$lv1 sync_percent "100.00"
 lvextend -y -L+${lvext}M $vg/$lv1
 if [ $PROGRESS -eq 1 ]
 then
-	not check lv_field $vg/$lv1 sync_percent "100.00"
+	# Even with delayed devices wre are catching races here.
+	should not check lv_field $vg/$lv1 sync_percent "100.00"
 else
 	check lv_field $vg/$lv1 sync_percent "100.00"
 fi


