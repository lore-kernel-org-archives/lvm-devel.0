From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jan 2021 15:10:03 +0000 (GMT)
Subject: main - pvscan: make ret value defined
Message-ID: <20210122151003.B3082398E43C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5485ec10e2b592f48f5208d8b5e3cf5e0f0eb70d
Commit:        5485ec10e2b592f48f5208d8b5e3cf5e0f0eb70d
Parent:        cddeaed6e956b181faf665f8af789cb517259bc2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 19 22:38:17 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 22 15:30:37 2021 +0100

pvscan: make ret value defined

---
 tools/pvscan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 55c708682..0ad901c13 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1020,11 +1020,10 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 	struct processing_handle *handle = NULL;
 	struct dm_str_list *sl, *sl2;
 	int no_quick = 0;
-	int ret;
+	int ret = ECMD_FAILED;
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
-		ret = ECMD_FAILED;
 		goto out;
 	}
 


