From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Dec 2022 15:23:33 +0000 (GMT)
Subject: main - vdo: fix reader error path
Message-ID: <20221220152333.2049D385B50E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6b1c19365d20d926d8aa39bf591731a7f9bb75a
Commit:        b6b1c19365d20d926d8aa39bf591731a7f9bb75a
Parent:        4baef0f93f608403b6f2db445e7bf1e80f8f3ee6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 20 13:52:31 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 20 15:04:36 2022 +0100

vdo: fix reader error path

Nothing to be closed on this error path.
---
 device_mapper/vdo/vdo_reader.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/device_mapper/vdo/vdo_reader.c b/device_mapper/vdo/vdo_reader.c
index 4f91f8011..3596afbd3 100644
--- a/device_mapper/vdo/vdo_reader.c
+++ b/device_mapper/vdo/vdo_reader.c
@@ -189,7 +189,7 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 	*logical_blocks = 0;
 	if ((fh = open(vdo_path, O_RDONLY)) == -1) {
 		log_sys_debug("Failed to open VDO backend %s.", vdo_path);
-		goto err;
+		return false;
 	}
 
 	if (ioctl(fh, BLKGETSIZE64, &size) == -1) {

