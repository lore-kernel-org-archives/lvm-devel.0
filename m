From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:09 +0000 (GMT)
Subject: main - cov: make read buffer obviously zero ended
Message-ID: <20210920133009.D7A953858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=752a9ec4b44198554b9f998ed6e4a837878fc49f
Commit:        752a9ec4b44198554b9f998ed6e4a837878fc49f
Parent:        6c87e98ee367e1ff410470c09e6131697f0a7660
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 01:57:06 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: make read buffer obviously zero ended

Coverity doesn't get the idea from memset() here.
---
 lib/config/config.c | 2 +-
 tools/pvck.c        | 5 ++---
 tools/pvscan.c      | 1 +
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 25a87c983..aedbb2b1e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -522,7 +522,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 	if (!(dev->flags & DEV_REGULAR) || size2)
 		use_plain_read = 0;
 
-	if (!(buf = malloc(size + size2))) {
+	if (!(buf = zalloc(size + size2))) {
 		log_error("Failed to allocate circular buffer.");
 		return 0;
 	}
diff --git a/tools/pvck.c b/tools/pvck.c
index 629e1feee..0d1bc1b17 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -2955,7 +2955,7 @@ static int _read_metadata_file(struct cmd_context *cmd, struct metadata_file *mf
 		goto out;
 	}
 
-	if (!(text_buf = zalloc(text_size + 1)))
+	if (!(text_buf = malloc(text_size + 1)))
 		goto_out;
 
 	rv = read(fd, text_buf, text_size);
@@ -2964,8 +2964,7 @@ static int _read_metadata_file(struct cmd_context *cmd, struct metadata_file *mf
 		free(text_buf);
 		goto out;
 	}
-
-	text_size += 1; /* null terminating byte */
+	text_buf[text_size++] = 0; /* null terminating byte */
 
 	if (close(fd))
 		stack;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index ec33c9a9a..b19b74b3e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -223,6 +223,7 @@ static int _online_pvid_file_read(char *path, int *major, int *minor, char *vgna
 		log_warn("No info in %s", path);
 		return 0;
 	}
+	buf[rv] = 0; /* \0 terminated buffer */
 
 	if (sscanf(buf, "%d:%d", major, minor) != 2) {
 		log_warn("No device numbers in %s", path);


