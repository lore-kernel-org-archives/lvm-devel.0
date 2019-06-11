From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Jun 2019 17:16:02 -0400
Subject: master - vgchange: change debug message level
Message-ID: <201906112116.x5BLG2kP002667@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7eaa3adedf4977352f93d8558dd0f1a0eb2c9921
Commit:        7eaa3adedf4977352f93d8558dd0f1a0eb2c9921
Parent:        4bb7d3da0e7472804361f639c6da5e2798b4e0d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 11 16:14:07 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 11 16:14:07 2019 -0500

vgchange: change debug message level

A debug message was mistakely left visible.
---
 tools/vgchange.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index a662be3..d6d4f91 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -407,8 +407,8 @@ static int _vgchange_metadata_copies(struct cmd_context *cmd,
 {
 	uint32_t mda_copies = arg_uint_value(cmd, vgmetadatacopies_ARG, DEFAULT_VGMETADATACOPIES);
 
-	log_warn("vgchange_metadata_copies new %u vg_mda_copies %u D %u",
-		 mda_copies, vg_mda_copies(vg), DEFAULT_VGMETADATACOPIES);
+	log_debug("vgchange_metadata_copies new %u vg_mda_copies %u D %u",
+		  mda_copies, vg_mda_copies(vg), DEFAULT_VGMETADATACOPIES);
 
 	if (mda_copies == vg_mda_copies(vg)) {
 		if (vg_mda_copies(vg) == VGMETADATACOPIES_UNMANAGED)


