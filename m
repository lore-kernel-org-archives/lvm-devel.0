From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Feb 2014 13:55:36 +0000 (UTC)
Subject: master - tests: drop remove
Message-ID: <20140227135536.C877760FA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4afd07700986b368c7ea8543f04f8e2dfc02a8c
Commit:        f4afd07700986b368c7ea8543f04f8e2dfc02a8c
Parent:        07ba047116b3fa5e07647ee79854b93c7fb27bb8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 27 14:48:32 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 27 14:48:32 2014 +0100

tests: drop remove

Generates waaaaay too much log from lvmetad test.

TODO: once we will be able to remove more LVs with a single
write - we may restore....
---
 test/shell/vgchange-many.sh |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index ba3d2b8..491c8b1 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -50,5 +50,3 @@ vgcfgrestore -f data_new $vg
 # Activate and deactivate all of them
 vgchange -ay $vg
 vgchange -an $vg
-
-vgremove -ff $vg


