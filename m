From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Oct 2022 17:36:10 +0000 (GMT)
Subject: main - lvmlockd: fix warning
Message-ID: <20221011173610.C8F8E3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=657df00c9615ea5abb6faf4c21f01f90de17b207
Commit:        657df00c9615ea5abb6faf4c21f01f90de17b207
Parent:        fc01dd89006bc0a37351cca9332244bfa8d2f096
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 11 12:35:38 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 11 12:35:38 2022 -0500

lvmlockd: fix warning

---
 daemons/lvmlockd/lvmlockd-dlm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 01bec6f43..d262fa281 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -222,7 +222,7 @@ int lm_prepare_lockspace_dlm(struct lockspace *ls)
 
 #define DLM_COMMS_PATH "/sys/kernel/config/dlm/cluster/comms"
 #define LOCK_LINE_MAX 1024
-static int get_local_nodeid()
+static int get_local_nodeid(void)
 {
 	struct dirent *de;
 	DIR *ls_dir;

