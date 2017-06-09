From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 15:50:35 -0400
Subject: master - cleanup: update message
Message-ID: <201706091950.v59JoZ5H010286@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57379157f4209acc72e943e26209b084575f811c
Commit:        57379157f4209acc72e943e26209b084575f811c
Parent:        db5938a4f8b5f13f5bc804f0d8e931f36dcbbef3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 21:31:02 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 21:49:19 2017 +0200

cleanup: update message

---
 lib/metadata/thin_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 7f7d314..ad45ce9 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -718,7 +718,7 @@ int update_thin_pool_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	log_print_unless_silent("Thin pool data with chunk size %s can address at most %s of data.",
+	log_print_unless_silent("Thin pool volume with chunk size %s can address at most %s of data.",
 				display_size(cmd, *chunk_size), display_size(cmd, max_pool_data_size));
 
 	if (!validate_thin_pool_chunk_size(cmd, *chunk_size))


