From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  2 Jul 2013 09:09:38 +0000 (UTC)
Subject: master - archive: add missing bit set
Message-ID: <20130702090938.5160961282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b31725d0ae0539f2d13a2454849de557fe91c4fb
Commit:        b31725d0ae0539f2d13a2454849de557fe91c4fb
Parent:        bdf0594aa8064bc08623bc56f934aa0dd44d9220
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 2 11:07:15 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 2 11:07:15 2013 +0200

archive: add missing bit set

In the last update not all code paths have set the archived flag.
If we run in test mode or without archiving enabled - set the bit
as well - so test whether archiving has been called succesfully
will be ok. (in relase fix).
---
 lib/format_text/archiver.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index c012c8f..1e6dbac 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -113,10 +113,13 @@ int archive(struct volume_group *vg)
 	if (vg_is_archived(vg))
 		return 1; /* VG has been already archived */
 
-	if (!vg->cmd->archive_params->enabled || !vg->cmd->archive_params->dir)
+	if (!vg->cmd->archive_params->enabled || !vg->cmd->archive_params->dir) {
+		vg->status |= ARCHIVED_VG;
 		return 1;
+	}
 
 	if (test_mode()) {
+		vg->status |= ARCHIVED_VG;
 		log_verbose("Test mode: Skipping archiving of volume group.");
 		return 1;
 	}


