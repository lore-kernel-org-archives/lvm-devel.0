From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Dec 2012 11:06:30 +0000 (UTC)
Subject: master - test: update thin discards testing
Message-ID: <20121211110630.D372614EF@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b38ba2708346b52a48be5596b22b3ad4f1304af1
Commit:        b38ba2708346b52a48be5596b22b3ad4f1304af1
Parent:        ff5c1c576c9f0162e9d82becfe30b100fc601c88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 10 10:51:25 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 11 12:05:48 2012 +0100

test: update thin discards testing

Reflect fixed disards behavior.
---
 test/shell/lvcreate-thin-power2.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index 882b05c..e1effa4 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -27,11 +27,12 @@ vgcreate $vg -s 64K $(cat DEVICES)
 # create non-power-of-2 pool
 lvcreate -l100 -c 192 -T $vg/pool
 
-check lv_field $vg/pool discards "ignore"
+check lv_field $vg/pool discards "passdown"
 
 # check we cannot change discards settings
-not lvchange --discard passdown $vg/pool
-not lvchange --discard nopassdown $vg/pool
+not lvchange --discard ignore $vg/pool
+lvchange --discard nopassdown $vg/pool
+check lv_field $vg/pool discards "nopassdown"
 
 # must be multiple of 64KB
 not lvcreate -l100 -c 168 -T $vg/pool1


