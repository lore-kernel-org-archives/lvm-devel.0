From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 15:57:04 -0500
Subject: master - config: Move use_mmap to local variable.
Message-ID: <201801102057.w0AKv4SB027515@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f771d3f870a3e0b86b729a730b1ef7797e35aec6
Commit:        f771d3f870a3e0b86b729a730b1ef7797e35aec6
Parent:        6210c1ec28b9b6859d3e4c30a4dd1928f5c5badc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 10 20:35:02 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 20:35:02 2018 +0000

config: Move use_mmap to local variable.

---
 lib/config/config.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 668df26..44d646e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -500,7 +500,6 @@ struct process_config_file_params {
 	uint32_t checksum;
 	int checksum_only;
 	int no_dup_node_check;
-	int use_mmap;
 	lvm_callback_fn_t config_file_read_fd_callback;
 	void *config_file_read_fd_context;
 	int ret;
@@ -552,6 +551,7 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 	char *fb;
 	int r = 0;
 	off_t mmap_offset = 0;
+	int use_mmap = 1;
 	const char *buf = NULL;
 	unsigned circular = size2 ? 1 : 0;	/* Wrapped around end of disk metadata buffer? */
 	struct config_source *cs = dm_config_get_custom(cft);
@@ -581,14 +581,13 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 	pcfp->no_dup_node_check = no_dup_node_check;
 	pcfp->config_file_read_fd_callback = config_file_read_fd_callback;
 	pcfp->config_file_read_fd_context = config_file_read_fd_context;
-	pcfp->use_mmap = 1;
 	pcfp->ret = 1;
 
 	/* Only use mmap with regular files */
 	if (!(dev->flags & DEV_REGULAR) || circular)
-		pcfp->use_mmap = 0;
+		use_mmap = 0;
 
-	if (pcfp->use_mmap) {
+	if (use_mmap) {
 		mmap_offset = offset % lvm_getpagesize();
 		/* memory map the file */
 		fb = mmap((caddr_t) 0, size + mmap_offset, PROT_READ,


