From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Apr 2018 16:43:27 -0400
Subject: master - lvchange: update mirror table when changing monitoring
Message-ID: <201804232043.w3NKhR8e004989@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae274617770aa44263619151ef24393cb8a16a79
Commit:        ae274617770aa44263619151ef24393cb8a16a79
Parent:        fcdac700f9aac079761ad302e06413a5eb2178b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 23 21:28:35 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 23 22:42:18 2018 +0200

lvchange: update mirror table when changing monitoring

Since for non-monitored mirrors we let mirror running without
error handling - when monitoring changes for mirror, updated
table (refresh) is needed.
---
 tools/lvchange.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0aac5ac..e1be4cb 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1603,6 +1603,10 @@ static int _lvchange_monitor_poll_single(struct cmd_context *cmd,
 				         struct logical_volume *lv,
 				         struct processing_handle *handle)
 {
+	/* Mirror is using different table line when un/monitored */
+	if (lv_is_mirror(lv) && !lv_refresh(cmd, lv))
+		return_ECMD_FAILED;
+
 	if (arg_is_set(cmd, monitor_ARG) &&
 	    !_lvchange_monitoring(cmd, lv))
 		return_ECMD_FAILED;


