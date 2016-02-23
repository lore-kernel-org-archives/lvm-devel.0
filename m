From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 11:26:06 +0000 (UTC)
Subject: master - cleanup: drop double ;
Message-ID: <20160223112606.B029660DFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d8a67714f3f35bef066f4c550b16193d8bc2cd8
Commit:        7d8a67714f3f35bef066f4c550b16193d8bc2cd8
Parent:        dbc71dc05ef100a3907e6b47764b8eff71f1c7f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 12:12:29 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 12:25:25 2016 +0100

cleanup: drop double ;

---
 lib/format_text/archiver.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 1bc9557..e52854f 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -364,7 +364,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct dm_list new_pvs;
 	struct pv_list *pvl, *new_pvl;
 	struct physical_volume *existing_pv, *pv;
-	struct dm_list *pvs = &vg->pvs;;
+	struct dm_list *pvs = &vg->pvs;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 	int should_write_pv;


