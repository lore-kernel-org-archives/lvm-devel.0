From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Fri, 14 Mar 2014 07:17:40 +0000 (UTC)
Subject: master - lvmetad: Fix previous commit
Message-ID: <20140314071740.F16B360DE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67c539f346a8259a4100ab10196486f8793fecce
Commit:        67c539f346a8259a4100ab10196486f8793fecce
Parent:        816197aaabbd41dd85d7728a6fd2992c148e124f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Mar 14 08:09:37 2014 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Mar 14 08:09:37 2014 +0100

lvmetad: Fix previous commit

"%d" in buffer_append_vf is 64 bit wide. Using just `int` for the
variable will fetch more from va_list than intended and shifting
remaining arguments resulting in errors like:

    Internal error: Bad format string at '#orphan'
---
 daemons/lvmetad/lvmetad-core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 93a56c6..1b093cc 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -863,8 +863,8 @@ static response pv_found(lvmetad_state *s, request r)
 	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
 	char *old;
 	char *pvid_dup;
-	int complete = 0, orphan = 0, changed = 0;
-	int64_t seqno = -1, seqno_old = -1;
+	int complete = 0, orphan = 0;
+	int64_t seqno = -1, seqno_old = -1, changed = 0;
 
 	if (!pvid)
 		return reply_fail("need PV UUID");


