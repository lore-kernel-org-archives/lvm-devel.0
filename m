From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 27 Jun 2016 18:00:50 +0000 (UTC)
Subject: master - lvmetad: remove unused code for other format types
Message-ID: <20160627180050.1855A60529@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6c376ee2dae4539b1cc38ed6d9c5430777d2753
Commit:        e6c376ee2dae4539b1cc38ed6d9c5430777d2753
Parent:        8eebb4bfb901caa5330676697557943fdb9733a5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 7 16:09:45 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 27 11:16:35 2016 -0500

lvmetad: remove unused code for other format types

lvmetad is no longer used at all with the lvm1 format,
so the text format is the only one that uses lvmetad.
---
 lib/metadata/metadata.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9b1fd31..e55463b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3546,13 +3546,6 @@ int vg_write(struct volume_group *vg)
 	if (!_vg_update_vg_precommitted(vg)) /* prepare precommited */
 		return_0;
 
-	/*
-	 * If precommit is not supported, changes take effect immediately.
-	 * FIXME Replace with a more-accurate FMT_COMMIT flag.
-	 */
-	if (!(vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
-		return_0;
-
 	lockd_vg_update(vg);
 
 	return 1;


