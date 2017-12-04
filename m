From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:58:12 -0500
Subject: master - cleanup: drop unused define
Message-ID: <201712041458.vB4EwCXG007211@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76954884c741e31eb2ddb4f5f5ffe9d2b8c60572
Commit:        76954884c741e31eb2ddb4f5f5ffe9d2b8c60572
Parent:        110dac870c0a0f53b4569f99daf5b6ac83a549f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 14:26:56 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: drop unused define

---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 4dfd6c7..404519b 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -62,8 +62,6 @@ struct dso_state {
 
 DM_EVENT_LOG_FN("thin")
 
-#define UUID_PREFIX "LVM-"
-
 static int _run_command(struct dso_state *state)
 {
 	char val[3][36];


