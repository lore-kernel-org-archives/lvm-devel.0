From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:28:01 +0000 (UTC)
Subject: master - lv: show X attr when lv_info fails
Message-ID: <20140430082801.4687360DAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62ad6dee18199f4bf80f5dc0dafa68b7f5396508
Commit:        62ad6dee18199f4bf80f5dc0dafa68b7f5396508
Parent:        816cc94ac1a8a1048a5f737e9bc3f9e251773bf7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 20:14:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:29 2014 +0200

lv: show X attr when lv_info fails

Print 'X' also when lv_info() fails.
(i.e. compilation with --disable-ioctl)
---
 lib/metadata/lv.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0225704..54306a2 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -613,10 +613,10 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	repstr[3] = (lv->status & FIXED_MINOR) ? 'm' : '-';
 
-	if (!activation()) {
+	if (!activation() || !lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)) {
 		repstr[4] = 'X';		/* Unknown */
 		repstr[5] = 'X';		/* Unknown */
-	} else if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
+	} else if (info.exists) {
 		if (info.suspended)
 			repstr[4] = 's';	/* Suspended */
 		else if (info.live_table)


