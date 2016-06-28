From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:26 +0000 (UTC)
Subject: master - lvmetad: remove unused code for other format types
Message-ID: <20160628013326.63A1E60237@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc3e7c7c31de8d69d9f1eb610181584482ee90a3
Commit:        cc3e7c7c31de8d69d9f1eb610181584482ee90a3
Parent:        5a327755b4cfe45b35863a2b4177a6b32c17642f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 7 16:09:45 2016 -0500
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:30:25 2016 +0100

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


