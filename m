From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 17 Mar 2014 10:55:52 +0000 (UTC)
Subject: master - tests: fix name-mangling test
Message-ID: <20140317105552.601D761068@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12eb284eecc631096e31384537289a3376617580
Commit:        12eb284eecc631096e31384537289a3376617580
Parent:        b16235de96a18c9e9e619bebe506d41f80fff834
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 17 11:51:30 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 17 11:51:30 2014 +0100

tests: fix name-mangling test

We need to use "--verifyudev" for dmsetup mangle command used in
the name-mangling test since without the --verifyudev, we'd end up
with the failed rename.

Also, add direct check for the dev nodes - node with old name must
be gone and node with new name must be present. Before, we checked
just the output of the command.

One bug popped up here when renaming with udev and libdevmapper
fallback checking the udev when target mangle mode is "none"
(fixme added in the libdevmapper's node rename code).
---
 libdm/libdm-common.c        |   18 ++++++++++++++++++
 test/shell/name-mangling.sh |   29 ++++++++++++++++++++++++++---
 2 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 2ec66e7..72fa508 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1073,6 +1073,24 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 			 oldpath, newpath);
 
 	/* udev may already have renamed the node. Ignore ENOENT. */
+	/* FIXME: when renaming to target mangling mode "none" with udev
+	 * while there are some blacklisted characters in the node name,
+	 * udev will remove the old_node, but fails to properly rename
+	 * to new_node. The libdevmapper code tries to call
+	 * rename(old_node,new_node), but that won't do anything
+	 * since the old node is already removed by udev.
+	 * For example renaming 'a\x20b' to 'a b':
+	 *   - udev removes 'a\x20b'
+	 *   - udev creates 'a' and 'b' (since it considers the ' ' as a delimiter
+	 *   - libdevmapper checks udev has done the rename properly
+	 *   - libdevmapper calls stat(new_node) and it does not see it
+	 *   - libdevmapper calls rename(old_node,new_node)
+	 *   - the rename is a NOP since the old_node does not exist anymore
+	 *
+	 * However, this situation is very rare - why would anyone need
+	 * to rename to an unsupported mode??? So a fix for this would be
+	 * just for completeness.
+	 */
 	if (rename(oldpath, newpath) < 0 && errno != ENOENT) {
 		log_error("Unable to rename device node from '%s' to '%s'",
 			  old_name, new_name);
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 2f07523..cf218fe 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -129,7 +129,7 @@ function check_mangle_cmd()
 
 	create_dm_dev none "$dm_name"
 
-	dmsetup mangle --manglename $mode "${PREFIX}$dm_name" 1>out 2>err || true;
+	dmsetup mangle --manglename $mode --verifyudev "${PREFIX}$dm_name" 1>out 2>err || true;
 
 	if [ "$expected" = "OK" ]; then
 		grep "$CORRECT_FORM_STR" out || r=1
@@ -139,7 +139,30 @@ function check_mangle_cmd()
 		grep "$FAIL_MULTI_STR" err || r=1
 	else
 		rename_expected=1
-		grep -F "$RENAMING_STR ${PREFIX}$expected" out || r=1
+		if grep -F "$RENAMING_STR ${PREFIX}$expected" out; then
+			# Check the old node is really renamed.
+			test -b "$DM_DEV_DIR/mapper/${PREFIX}$dm_name" && r=1
+			# FIXME: when renaming to mode=none with udev, udev will
+			#        remove the old_node, but fails to properly rename
+			#        to new_node. The libdevmapper code tries to call
+			#        rename(old_node,new_node), but that won't do anything
+			#        since the old node is already removed by udev.
+			#        For example renaming 'a\x20b' to 'a b':
+			#          - udev removes 'a\x20b'
+			#          - udev creates 'a' and 'b' (since it considers the ' ' as a delimiter)
+			#          - libdevmapper checks udev has done the rename properly
+			#          - libdevmapper calls stat(new_node) and it does not see it
+			#          - libdevmapper calls rename(old_node,new_node)
+			#          - the rename is a NOP since the old_node does not exist anymore
+			#
+			# Remove this condition once the problem is fixed in libdevmapper.
+			#
+			if [ "$mode" != "none" ]; then
+				test -b "$DM_DEV_DIR/mapper/${PREFIX}$expected" || r=1
+			fi
+		else
+			r=1
+		fi
 	fi
 
 	if [ $r = 0 -a $rename_expected = 1 ]; then
@@ -149,7 +172,7 @@ function check_mangle_cmd()
 		# failed to rename to expected or renamed when it should not - find the new name
 		new_name=$(sed -e "s/.*: $RENAMING_STR //g" out)
 		# try to remove any of the form - falling back to less probable error scenario
-		aux dmsetup remove --verifyudev --manglename none "$new_name" || \
+		remove_dm_dev none "$new_name" || \
 		remove_dm_dev none "$dm_name" || remove_dm_dev none "$expected"
 	else
 		# successfuly done nothing


