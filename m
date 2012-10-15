From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Oct 2012 12:10:12 +0000 (UTC)
Subject: master - lvchange: resync returns error on usupported volumes
Message-ID: <20121015121012.10E05A0C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=457387718600579b862fe940c9a9daea3da59141
Commit:        457387718600579b862fe940c9a9daea3da59141
Parent:        b3899056d94d14eaa80c49e4a5a52c8e7865f08a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 13:42:18 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 14:09:37 2012 +0200

lvchange: resync returns error on usupported volumes

---
 tools/lvchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 85253ef..04facdd 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -343,7 +343,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 	if (!(lv->status & MIRRORED) && !seg_is_raid(seg)) {
 		log_error("Unable to resync %s.  It is not RAID or mirrored.",
 			  lv->name);
-		return 1;
+		return 0;
 	}
 
 	if (lv->status & PVMOVE) {


