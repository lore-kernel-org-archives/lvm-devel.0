From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:17 +0000 (GMT)
Subject: main - debug: drop stack from regular code flow
Message-ID: <20210315101417.3A0383858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc1bc4cffc2b5faa113b5c232aa5fc2faae8771a
Commit:        bc1bc4cffc2b5faa113b5c232aa5fc2faae8771a
Parent:        eadd58a97dd9a199b74260e8a2bdb5657bf7a88d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 12 22:30:29 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

debug: drop stack from regular code flow

---
 lib/label/hints.c       | 2 +-
 lib/metadata/metadata.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index aed0ea2ff..47236a15a 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -448,7 +448,7 @@ static int _dev_in_hint_hash(struct cmd_context *cmd, struct device *dev)
 		return 0;
 
 	if (!dev_get_size(dev, &devsize) || !devsize)
-		return_0;
+		return 0;
 
 	return 1;
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index cee236e3e..47d3d8b3e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4603,7 +4603,7 @@ static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, con
 
 		/* For other commands, return mismatch immediately. */
 		if (ret)
-			goto_out;
+			goto out;
 	}
 
 	if (ret) {


