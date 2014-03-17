From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:16 +0000 (UTC)
Subject: master - lvconvert: delay archiving of metadata
Message-ID: <20140317133316.1F56A60EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b738260c7cdbc6094feda9f9e2426d50bd413263
Commit:        b738260c7cdbc6094feda9f9e2426d50bd413263
Parent:        d425e788e9ebaa2eef1fd747aec4dad03897114e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 13:07:08 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:43 2014 +0100

lvconvert: delay archiving of metadata

Delay archiving of metadata until we really start to
update metadata when converting volume into a snapshot.
Archive is not necessary when we abort operation early.
---
 tools/lvconvert.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7f27dd4..4a26614 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2080,6 +2080,9 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!archive(lv->vg))
+		return_0;
+
 	if (!vg_add_snapshot(org, lv, NULL, org->le_count, lp->chunk_size)) {
 		log_error("Couldn't create snapshot.");
 		return 0;
@@ -3040,9 +3043,6 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 			return ECMD_FAILED;
 		}
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-
 		if (!_lvconvert_snapshot(cmd, lv, lp))
 			return_ECMD_FAILED;
 


