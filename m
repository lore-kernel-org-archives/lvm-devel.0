From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 13:05:34 +0000 (UTC)
Subject: master - lvmetad: restore use of FMTd64
Message-ID: <20151109130534.53154614BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b5a75c9af1be5959ed946fea816aa642b5f918a
Commit:        0b5a75c9af1be5959ed946fea816aa642b5f918a
Parent:        7103012754884a964da481626cf96fd6f64b5175
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 14:02:27 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 14:02:27 2015 +0100

lvmetad: restore use of FMTd64

daemon_reply_simple() eats just 64bit numbers - so make it explicit.
---
 daemons/lvmetad/lvmetad-core.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 69dc961..da9a510 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2467,11 +2467,11 @@ static response pv_found(lvmetad_state *s, request r)
 
 	return daemon_reply_simple("OK",
 				   "status = %s", vg_status,
-				   "changed = %d", changed,
+				   "changed = " FMTd64, (int64_t) changed,
 				   "vgid = %s", arg_vgid ? arg_vgid : "#orphan",
 				   "vgname = %s", arg_name ? arg_name : "#orphan",
-				   "seqno_before = %d", old_seqno,
-				   "seqno_after = %d", vg_status_seqno,
+				   "seqno_before = " FMTd64, (int64_t) old_seqno,
+				   "seqno_after = " FMTd64, (int64_t) vg_status_seqno,
 				   NULL);
 
  nomem:
@@ -2590,8 +2590,8 @@ static response set_global_info(lvmetad_state *s, request r)
 
 static response get_global_info(lvmetad_state *s, request r)
 {
-	return daemon_reply_simple("OK", "global_invalid = %d",
-					 (s->flags & GLFL_INVALID) ? 1 : 0,
+	return daemon_reply_simple("OK", "global_invalid = " FMTd64,
+					 (int64_t)((s->flags & GLFL_INVALID) ? 1 : 0),
 					 NULL);
 }
 


