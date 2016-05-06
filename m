From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:01:13 +0000 (UTC)
Subject: master - metadata: move warning message about repairing VG
Message-ID: <20160506140113.BE0CD60722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2d823eced26b97874399670a59c1d5b9c1fb54d
Commit:        e2d823eced26b97874399670a59c1d5b9c1fb54d
Parent:        fa130722cbe3f7ac7f80fce4bcd3c3dc12d6897e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 5 12:47:29 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

metadata: move warning message about repairing VG

Move the message to just before the repair is going
to happen to avoid printing the message in cases
where repair is skipped.
---
 lib/metadata/metadata.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index dbe443e..8adcbbd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3942,6 +3942,8 @@ static int _repair_inconsistent_vg(struct volume_group *vg)
 		return 0;
 	}
 
+	log_warn("WARNING: Inconsistent metadata found for VG %s - updating to use version %u", vg->name, vg->seqno);
+
 	vg->cmd->handles_missing_pvs = 1;
 	if (!vg_write(vg)) {
 		log_error("Automatic metadata correction failed");
@@ -4554,9 +4556,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			return correct_vg;
 		}
 
-		log_warn("WARNING: Inconsistent metadata found for VG %s - updating "
-			 "to use version %u", vgname, correct_vg->seqno);
-
 		/*
 		 * If PV is marked missing but we found it,
 		 * update metadata and remove MISSING flag


