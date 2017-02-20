From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Feb 2017 23:06:38 +0000 (UTC)
Subject: master - man vgchange/lvchange: note special option usage
Message-ID: <20170220230638.5222D6134D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d22cccdf631576d4fd0504ffd17812d778f9d37b
Commit:        d22cccdf631576d4fd0504ffd17812d778f9d37b
Parent:        a2d2cd8777ea0f387383743ba2739007ef1b3baf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 20 15:26:24 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 20 15:36:30 2017 -0600

man vgchange/lvchange: note special option usage

---
 tools/command-lines.in |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 092f941..606d2e7 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -250,7 +250,9 @@ OO_LVCHANGE_META: --addtag Tag, --deltag Tag,
 lvchange OO_LVCHANGE_META VG|LV|Tag|Select ...
 OO: --activate Active, OO_LVCHANGE
 ID: lvchange_properties
-DESC: Change a general LV property.
+DESC: Change a general LV attribute.
+DESC: For options listed in parentheses, any one is
+DESC: required, after which the others are optional.
 RULE: all not lv_is_pvmove lv_is_mirror_log lv_is_mirror_image
 RULE: all and lv_is_vg_writable
 RULE: --contiguous not --alloc
@@ -1408,7 +1410,9 @@ vgchange OO_VGCHANGE_META
 OO: OO_VGCHANGE
 OP: VG|Tag|Select ...
 ID: vgchange_properties
-DESC: Change a general VG property.
+DESC: Change a general VG attribute.
+DESC: For options listed in parentheses, any one is
+DESC: required, after which the others are optional.
 
 vgchange --monitor Bool
 OO: --sysinit, --ignorelockingfailure, --poll Bool, OO_VGCHANGE


