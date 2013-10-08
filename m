From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Oct 2013 11:42:37 +0000 (UTC)
Subject: master - tests: vgrename duplicate rename
Message-ID: <20131008114237.9DCDE60F40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7edf61186b6afdcc7ab8b44072818995cef3702b
Commit:        7edf61186b6afdcc7ab8b44072818995cef3702b
Parent:        92bafade6051f95d49b35a53c77d0fc25a1fb7ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 8 11:16:00 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 8 13:42:09 2013 +0200

tests: vgrename duplicate rename

Test for rename of duplicated vgname (with different UUID)
---
 test/shell/vgrename-usage.sh |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgrename-usage.sh b/test/shell/vgrename-usage.sh
index 2b8ac5a..59576ac 100644
--- a/test/shell/vgrename-usage.sh
+++ b/test/shell/vgrename-usage.sh
@@ -38,3 +38,18 @@ vgcreate $vg1 "$dev1"
 vgcreate $vg2 "$dev2"
 not vgrename $vg1 $vg2
 vgremove $vg1 $vg2
+
+# vgrename duplicate name
+vgcreate $vg1 "$dev1"
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+UUID=$(vgs --noheading -o vg_uuid $vg1)
+aux enable_dev "$dev1"
+
+not vgrename $vg1 $vg2
+vgrename $UUID $vg2
+not vgrename $UUID $vg1
+
+vgs
+
+vgremove $vg1 $vg2


