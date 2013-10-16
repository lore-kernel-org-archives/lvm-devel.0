From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 16 Oct 2013 13:08:02 +0000 (UTC)
Subject: master - coverity: assigned variable not used and reassigned later
Message-ID: <20131016130802.E903960DB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee878bc52c18dca928682d5f282e8e4ed54bcc2e
Commit:        ee878bc52c18dca928682d5f282e8e4ed54bcc2e
Parent:        dd3a2f13f1680228fe9ddd5fa1b1c5900cf8dc96
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 16 15:06:43 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 16 15:06:43 2013 +0200

coverity: assigned variable not used and reassigned later

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8f09af7..383bab1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -89,7 +89,7 @@ static int _lv_is_on_pv(struct cmd_context *cmd,
 	struct physical_volume *pv2;
 	struct lv_segment *seg;
 
-	if (!lv || !(seg = first_seg(lv)))
+	if (!lv || !(first_seg(lv)))
 		return_0;
 
 	/*


