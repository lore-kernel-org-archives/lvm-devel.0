From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jun 2017 06:20:14 -0400
Subject: master - coverity: validate length of renaming path
Message-ID: <201706271020.v5RAKEfj003909@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=419e8284c8b918558b20bc1e2194ad2cbdd5d58b
Commit:        419e8284c8b918558b20bc1e2194ad2cbdd5d58b
Parent:        8e790702f12ddcb730f8dc43d3fdccf08e62aa45
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 11:37:24 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 12:15:42 2017 +0200

coverity: validate length of renaming path

Make sure path fits into buffer on stack.
---
 lib/format_text/format-text.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 533fece..5d731ca 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1043,6 +1043,11 @@ static int _vg_commit_file(struct format_instance *fid, struct volume_group *vg,
 
 	if (strcmp(slash, vg->name)) {
 		len = slash - tc->path_live;
+		if ((len + strlen(vg->name)) > (sizeof(new_name) - 1)) {
+			log_error("Renaming path %s is too long for VG %s.",
+				  tc->path_live, vg->name);
+			return 0;
+		}
 		strncpy(new_name, tc->path_live, len);
 		strcpy(new_name + len, vg->name);
 		log_debug_metadata("Renaming %s to %s", tc->path_live, new_name);


