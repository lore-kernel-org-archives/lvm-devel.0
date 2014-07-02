From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:31 +0000 (UTC)
Subject: master - mirror: mirror_or_raid_type_requested update
Message-ID: <20140702084831.770A661054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=355258be58fe52df0e90cb3831bc0e09f06d2e2a
Commit:        355258be58fe52df0e90cb3831bc0e09f06d2e2a
Parent:        c77197c688fad937b0701d749b9a449160bb40dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 1 10:13:10 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:34:39 2014 +0200

mirror: mirror_or_raid_type_requested update

mirror_or_raid_type_requested really checks for mirror type.

Convert macros mirror_or_raid_type_requested() and
snapshot_type_requested() into inline functions.
---
 tools/lvconvert.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d0555b3..28cbb32 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -211,11 +211,13 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 }
 
 /* -s/--snapshot and --type snapshot are synonyms */
-#define snapshot_type_requested(cmd,type_str) (arg_count(cmd, snapshot_ARG) || \
-					       !strcmp(type_str, "snapshot"))
+static inline int snapshot_type_requested(struct cmd_context *cmd, const char *type_str) {
+	return (arg_count(cmd, snapshot_ARG) || !strcmp(type_str, "snapshot"));
+}
 /* mirror/raid* (1,10,4,5,6 and their variants) reshape */
-#define mirror_or_raid_type_requested(cmd,type_str) (arg_count(cmd, mirrors_ARG) || \
-						     !strncmp(type_str, "raid", 4))
+static inline int mirror_or_raid_type_requested(struct cmd_context *cmd, const char *type_str) {
+	return (arg_count(cmd, mirrors_ARG) || !strncmp(type_str, "raid", 4) || !strcmp(type_str, "mirror"));
+}
 
 static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)


