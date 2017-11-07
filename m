From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:16 -0500
Subject: master - cleanup: gcc const warning
Message-ID: <201711072036.vA7KaGAF008003@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2fce429cfccf974be93bc939eed6f111738659c
Commit:        e2fce429cfccf974be93bc939eed6f111738659c
Parent:        d45a9c0f5b2c5c7d5098abc056174fa09f88cc58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 5 09:20:08 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:26:11 2017 +0100

cleanup: gcc const warning

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 53097b3..ced0311 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -902,7 +902,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		if (!dm_report_object_is_selected(_report, &obj, _selection_cmd ? 0 : 1, &selected))
 			goto_out;
 		if (_selection_cmd && selected) {
-			device_name = dm_task_get_name(dmt);
+			device_name = (char*) dm_task_get_name(dmt);
 			if (!_selection_cmd->fn(_selection_cmd, NULL, 1, &device_name, NULL, 1))
 				goto_out;
 		}


