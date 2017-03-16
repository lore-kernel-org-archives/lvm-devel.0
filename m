From: David Teigland <teigland@sourceware.org>
Date: Thu, 16 Mar 2017 13:16:29 -0400
Subject: master - lvmetad: fix bug in snprintf of disable reason
Message-ID: <201703161716.v2GHGTBW018714@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73d028023a47a254b9762545222ca3eb778a620b
Commit:        73d028023a47a254b9762545222ca3eb778a620b
Parent:        c8719d4e9430c4a2edaae9df4b53da97c718cc76
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 16 12:15:03 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 16 12:15:40 2017 -0500

lvmetad: fix bug in snprintf of disable reason

---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index aa00329..af5d429 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2421,7 +2421,7 @@ static response get_global_info(lvmetad_state *s, request r)
 	pid = (int)daemon_request_int(r, "pid", 0);
 
 	if (s->flags & GLFL_DISABLE) {
-		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s%s",
+		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s%s%s",
 			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_REPAIR)     ? LVMETAD_DISABLE_REASON_REPAIR "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_LVM1)       ? LVMETAD_DISABLE_REASON_LVM1 "," : "",


