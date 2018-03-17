From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:35:08 -0400
Subject: master - cleanup: use direct initializer
Message-ID: <201803172235.w2HMZ890011282@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c40e81a7e6a42e40a49c89758f8e9fd269de8d7
Commit:        5c40e81a7e6a42e40a49c89758f8e9fd269de8d7
Parent:        f4383a70ba0538f290657adfa20fe00967553195
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 14:13:30 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

cleanup: use direct initializer

---
 daemons/lvmetad/lvmetad-core.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index eeb3f20..66a6b82 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2421,14 +2421,11 @@ static response set_global_info(lvmetad_state *s, request r)
 
 static response get_global_info(lvmetad_state *s, request r)
 {
-	char reason[REASON_BUF_SIZE];
+	/* This buffer should be large enough to hold all the possible reasons. */
+	char reason[REASON_BUF_SIZE] = { 0 };
 	char flag_str[64];
 	int pid;
 
-	/* This buffer should be large enough to hold all the possible reasons. */
-
-	memset(reason, 0, sizeof(reason));
-
 	pid = (int)daemon_request_int(r, "pid", 0);
 
 	if (s->flags & GLFL_DISABLE) {


