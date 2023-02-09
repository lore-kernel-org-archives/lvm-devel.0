From: David Teigland <teigland@sourceware.org>
Date: Thu,  9 Feb 2023 23:39:00 +0000 (GMT)
Subject: main - vgimportclone: fix non-duplicate PV with non-unique basevgname arg
Message-ID: <20230209233900.539D5385828E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=be124ae81027e8736106e4958bd2dfab971d6764
Commit:        be124ae81027e8736106e4958bd2dfab971d6764
Parent:        94f77a4d8d9737fca05fb4e451678ec440c68670
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 9 17:14:19 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 9 17:37:22 2023 -0600

vgimportclone: fix non-duplicate PV with non-unique basevgname arg

Fix hang of vgimportclone command when:
the PV(s) being imported are not actually clones/duplicates, and
the -n vgname arg is the same as the current vgname.

(Not the intended use of the command, but it should still work.)

In this case, the old and new vgnames ended up being the same, when
the code expected they would be different.  A file lock on both the
old and new vgnames is used, so when both flocks are on the same
file, the second blocks indefinitely.

Fix the new vgname to be the old name plus a numeric suffix, which
is the expected result.
---
 test/shell/vgimportclone.sh | 20 ++++++++++++++++++++
 tools/vgimportclone.c       | 15 +++++++++++++--
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index e1b9d3832..13924c3dd 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -104,6 +104,26 @@ pvremove "$dev1"
 pvremove "$dev2"
 pvremove "$dev3"
 
+# Test importing a non-duplicate pv using the existing vg name
+vgcreate $vg1 "$dev1"
+vgimportclone -n $vg1 "$dev1"
+vgs ${vg1}1
+not vgs $vg1
+vgremove ${vg1}1
+
+# Test importing a non-duplicate pv using the existing vg name
+# Another existing VG is using the initial generated vgname with
+# the "1" suffix, so "2" is used.
+vgcreate $vg1 "$dev1"
+vgcreate ${vg1}1 "$dev2"
+vgimportclone -n $vg1 "$dev1"
+vgs ${vg1}1
+vgs ${vg1}2
+vgremove ${vg1}1
+vgremove ${vg1}2
+pvremove "$dev1"
+pvremove "$dev2"
+
 # Verify that if we provide the -n|--basevgname,
 # the number suffix is not added unnecessarily.
 vgcreate $SHARED --metadatasize 128k A${vg1}B "$dev1"
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 93fa3b18d..a6d055f7f 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -407,8 +407,19 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 			log_error("Base vg name %s is too long.", vgname);
 			goto out;
 		}
-		(void) dm_strncpy(tmp_vgname, base_vgname, NAME_LEN);
-		vgname_count = 0;
+		if (strcmp(vgname, vp.old_vgname)) {
+			(void) dm_strncpy(tmp_vgname, base_vgname, NAME_LEN);
+			vgname_count = 0;
+		} else {
+			/* Needed when basename matches old name, and PV is not a duplicate
+			   which means old name is not found on other devs, and is not seen
+			   in the vgnames search below, causing old and new names to match. */
+			if (dm_snprintf(tmp_vgname, sizeof(tmp_vgname), "%s1", vp.old_vgname) < 0) {
+				log_error("Temporary vg name %s1 is too long.", vp.old_vgname);
+				goto out;
+			}
+			vgname_count = 1;
+		}
 	} else {
 		if (dm_snprintf(base_vgname, sizeof(base_vgname), "%s", vp.old_vgname) < 0) {
 			log_error(INTERNAL_ERROR "Old vg name %s is too long.", vp.old_vgname);

