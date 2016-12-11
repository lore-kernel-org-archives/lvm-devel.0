From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:35:08 +0000 (UTC)
Subject: master - tests: remove unwanted exit
Message-ID: <20161211223508.7F51560C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=273ccb11704075b1876f6931e9e8de19ff2b31a3
Commit:        273ccb11704075b1876f6931e9e8de19ff2b31a3
Parent:        b902fd08f688c823937fec612a0ea72848289e56
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 11 10:21:26 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

tests: remove unwanted exit

Exit seemes slipped in from local testing in:
eb6b2a11e3548f7598c726787494be2c3ea4dca1
---
 test/shell/lvchange-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index b5a6a86..3a8cc52 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -49,7 +49,7 @@ test -n "$no_discard" || check grep_dmsetup status $vg-pool " no_discard_passdow
 lvchange --discards passdown $vg/pool
 check grep_dmsetup table $vg-pool -v "passdown"
 test -n "$no_discard" || check grep_dmsetup status $vg-pool " discard_passdown"
-exit
+
 # zero_ARG  (default is 'yes')
 check grep_dmsetup table $vg-pool -v "zeroing"
 lvchange --zero n $vg/pool


