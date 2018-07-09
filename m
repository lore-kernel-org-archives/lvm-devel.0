From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:23 -0400
Subject: master - lvresize: vdo support
Message-ID: <201807091335.w69DZNgZ030783@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6945bbdbc6f997568707594b4b930f3551893910
Commit:        6945bbdbc6f997568707594b4b930f3551893910
Parent:        96e9929f2f2d23d2113920efd67431d0272aba5f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 2 10:54:56 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

lvresize: vdo support

Unsupported ATM.

Wait till VDO kernel target starts to use updated resize sequence,
LOAD, SUSPEND, RESUME.
---
 lib/metadata/lv_manip.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d3c4e76..43e09a4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4893,6 +4893,12 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_vdo_type(lv)) {
+		log_error("Resize of VDO type volume %s is not yet supported.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	if (lv_is_raid(lv) &&
 	    lp->resize == LV_REDUCE) {
 		unsigned attrs;


