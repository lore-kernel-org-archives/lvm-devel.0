From: David Teigland <teigland@sourceware.org>
Date: Tue, 20 Jun 2023 20:48:54 +0000 (GMT)
Subject: main - lvcreate: allow thin snapshot syntax that broke
Message-ID: <20230620204854.A59B03856263@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea6b5b694bf0886052b048b2e04b941ec65d90f9
Commit:        ea6b5b694bf0886052b048b2e04b941ec65d90f9
Parent:        1dbb86f8c7cd95cb484a5b3c465b847f35d2b760
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 20 15:41:24 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 20 15:47:01 2023 -0500

lvcreate: allow thin snapshot syntax that broke

The command "lvcreate --type thin --snapshot ..." to create a thin
snapshot would fail.

commit d651b340e68d97ada25e558eb50aa40062bba936 removed the optional
"--type thin" from the command definition "lvcreate --snapshot LV_thin",
and added --type thin as AUTOTYPE.  This was correct and should not have
changed anything if all the command defs were correct, but it broke
the "lvcreate --type thin --snapshot" case.  It reveals a problem in a
different command definintion:  "lvcreate --type thin LV_thin" that was
missing --snapshot in its OO list.
---
 test/shell/lvcreate-thin-snap.sh | 20 ++++++++++++++++++++
 tools/command-lines.in           |  6 +++---
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 6e6410cc1..8f1987986 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -74,5 +74,25 @@ lvcreate -L10M --zero n -T $vg/pool -V10M --name $lv1
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 lvcreate -K -s $vg/$lv1 --name snap
 fsck -n "$DM_DEV_DIR/$vg/snap"
+vgchange -an $vg
+lvremove -y $vg
+
+# One thin pool and one thin LV
+lvcreate --type thin-pool -L 10M -n tp $vg
+lvcreate --type thin -n thin1 -V 20M --thinpool tp $vg
+# Different syntaxes for creating a thin snapshot
+lvcreate --type thin -n snap1 $vg/thin1
+lvcreate --type thin --snapshot -n snap2 $vg/thin1
+lvcreate --type thin --thin -n snap3 $vg/thin1
+lvcreate --type thin --snapshot --thin -n snap4 $vg/thin1
+lvcreate --snapshot -n snap5 $vg/thin1
+lvcreate --thin -n snap6 $vg/thin1
+# The command defs allow --snapshot --thin, but the internal
+# lvcreate option checks disallow it.  It doesn't seem to make
+# sense to disallow this from a syntax point of view, but it's
+# possible that the lvcreate implementation would do the wrong
+# thing (that should probably be fixed.)
+not lvcreate --thin --snapshot -n snap7 $vg/thin1
+vgchange -an $vg
 
 vgremove -ff $vg
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 3d311288f..bb6e09933 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1088,7 +1088,7 @@ AUTOTYPE: thin
 ---
 
 lvcreate --type thin LV_thin
-OO: --thin, OO_LVCREATE
+OO: --thin, --snapshot, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV.
@@ -1096,7 +1096,7 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --thin LV_thin
-OO: OO_LVCREATE
+OO: --snapshot, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV.
@@ -1105,7 +1105,7 @@ AUTOTYPE: thin
 
 # alternate form of lvcreate --type thin
 lvcreate --snapshot LV_thin
-OO: OO_LVCREATE
+OO: --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV.

