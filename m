From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Jan 2020 11:11:23 -0500
Subject: stable-2.02 - tests: partial revert of test change of b6e6ea2d65785f03f3cee7938be635bcb8ad4944
Message-ID: <08172.120012111111800571@us-mta-297.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1f06e2faebfbc091b4bbb900398cda05264c753
Commit:        a1f06e2faebfbc091b4bbb900398cda05264c753
Parent:        62888e9c7692443066e90494764791753277f02e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 21 17:07:20 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 21 17:07:20 2020 +0100

tests: partial revert of test change of b6e6ea2d65785f03f3cee7938be635bcb8ad4944

With the update with commit b6e6ea2d65785f03f3cee7938be635bcb8ad4944
the test file has been updated - however stable branch still has
clvmd & lvmetad so we want to omit runnig unit tests for these runs.
---
 test/unit/unit-test.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/unit/unit-test.sh b/test/unit/unit-test.sh
index f545f14..e8332d6 100644
--- a/test/unit/unit-test.sh
+++ b/test/unit/unit-test.sh
@@ -13,6 +13,8 @@
 
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_CLVMD=1
 
 SKIP_ROOT_DM_CHECK=1
 



