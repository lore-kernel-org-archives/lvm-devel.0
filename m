From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Nov 2014 16:31:43 +0000 (UTC)
Subject: master - toollib: fix regression in parsing /dev/mapper/vg-lv
Message-ID: <20141126163143.BAEDF610B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4bfdb01f789a50267cbb50288a3bd5bc60edd685
Commit:        4bfdb01f789a50267cbb50288a3bd5bc60edd685
Parent:        c8890e3ac1adcb9129c30d3fe9a1a11ceedebce4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 26 17:09:47 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 26 17:29:35 2014 +0100

toollib: fix regression in parsing /dev/mapper/vg-lv

Commit b0dde9e8f026ddd679 introduced regression in parsing
/dev/mapper prefix - and tried to check for '/' one char behind.
---
 WHATS_NEW              |    1 +
 test/shell/listings.sh |    5 +++++
 tools/toollib.c        |    4 ++--
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bd7b7f9..d90cd94 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.114 - 
 =====================================
+  Fix regression when parsing /dev/mapper dir (2.02.112).
   Fix missing rounding to 64KB when estimating optimal thin pool chunk size.
   Fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT variable to be ignored.
   Fix size in pvresize "Resizing to ..." verbose msg to show proper result size.
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index fbd4af7..fcf6308 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -68,6 +68,11 @@ test $(lvs --noheadings $vg | wc -l) -eq 2
 test $(lvs -a --noheadings $vg | wc -l) -eq 6
 dmsetup ls | grep "$PREFIX" | grep -v "LVMTEST.*pv."
 
+# Check we parse /dev/mapper/vg-lv
+lvdisplay "$DM_DEV_DIR/mapper/$vg-$lv3"
+# Check we parse /dev/vg/lv
+lvdisplay "$DM_DEV_DIR/$vg/$lv3"
+
 lvcreate -l2 -s $vg/$lv3
 lvcreate -l1 -s -n inval $vg/$lv3
 lvcreate -l4 -I4 -i2 -n stripe $vg
diff --git a/tools/toollib.c b/tools/toollib.c
index 71eb9a8..6d409a9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -130,8 +130,8 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 			vg_name++;
 
 		/* Reformat string if /dev/mapper found */
-		if (!strncmp(vg_name, dmdir, dmdir_len) && vg_name[dmdir_len + 1] == '/') {
-			vg_name += devdir_len + 1;
+		if (!strncmp(vg_name, dmdir, dmdir_len) && vg_name[dmdir_len] == '/') {
+			vg_name += dmdir_len + 1;
 			while (*vg_name == '/')
 				vg_name++;
 


