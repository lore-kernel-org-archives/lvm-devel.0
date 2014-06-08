From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  8 Jun 2014 20:11:59 +0000 (UTC)
Subject: master - test: Try harder to vgremove in lvmetad-lvm1.sh.
Message-ID: <20140608201159.9AE5360C26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=150165591f36e0ba16d9dfdca70c569b3ae03a83
Commit:        150165591f36e0ba16d9dfdca70c569b3ae03a83
Parent:        b3bdd410927a3d9b1b17de94a05b1621a79bdb31
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 8 22:01:02 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 22:01:02 2014 +0200

test: Try harder to vgremove in lvmetad-lvm1.sh.

---
 test/shell/lvmetad-lvm1.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index d41e078..dcff55b 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -28,4 +28,4 @@ lvcreate -l1 $vg1
 pvremove -ff -y $dev2
 vgchange -an $vg1
 not lvremove $vg1
-not vgremove $vg1
+not vgremove -ff -y $vg1


