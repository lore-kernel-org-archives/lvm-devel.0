From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:42 +0000 (GMT)
Subject: main - vdo: just one probe is enough
Message-ID: <20210217105442.6F06E3857C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5bf1dba9eb8a8b77410e386e59dadeb27801b14e
Commit:        5bf1dba9eb8a8b77410e386e59dadeb27801b14e
Parent:        a7cb25c877ad70c48fa66258f8e3f2157e2e2be5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 11:12:11 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

vdo: just one probe is enough

target_present_version() can handle modprobing no need to try it
twice.
---
 lib/vdo/vdo.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index f26874ce5..52e9443ea 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -414,13 +414,9 @@ static int _vdo_target_present(struct cmd_context *cmd,
 	if (!_vdo_checked) {
 		_vdo_checked = 1;
 
-		if (!target_present_version(cmd, TARGET_NAME_VDO, 0,
-					    &maj, &min, &patchlevel)) {
-			/* Try to load kmod VDO module */
-			if (!module_present(cmd, MODULE_NAME_VDO) ||
-			    !target_version(TARGET_NAME_VDO, &maj, &min, &patchlevel))
-				return 0;
-		}
+		if (!target_present_version(cmd, TARGET_NAME_VDO, 1,
+					    &maj, &min, &patchlevel))
+			return 0;
 
 		if (maj < 6 || (maj == 6 && min < 2)) {
 			log_warn("WARNING: Target %s version %u.%u.%u is too old.",


