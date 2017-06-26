From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:29:38 -0400
Subject: master - debug: check for fail in id validation
Message-ID: <201706262229.v5QMTcdG010140@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c440bb0742fa70ca37ead55b7edd18e2f7a19eda
Commit:        c440bb0742fa70ca37ead55b7edd18e2f7a19eda
Parent:        3e331c8e68d5f80cacc194625ad97ee4c26fc3ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:20:29 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:36 2017 +0200

debug: check for fail in id validation

---
 lib/metadata/metadata.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b44f2df..45495dc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4149,7 +4149,8 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 		if (!pvl->pv->dev) {
 			/* is_missing_pv doesn't catch NULL dev */
 			memset(&uuid, 0, sizeof(uuid));
-			id_write_format(&pvl->pv->id, uuid, sizeof(uuid));
+			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
+				goto_out;
 			log_warn("WARNING: Not repairing PV %s with missing device.", uuid);
 			continue;
 		}


