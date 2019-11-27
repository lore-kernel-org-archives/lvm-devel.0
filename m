From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:20:49 -0500
Subject: master - Revert "pvck: check result of dev_get_size"
Message-ID: <47482.119112712204701225@us-mta-21.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39bd9b111bc6d2bcb56dfc5859e691b9c90db4c0
Commit:        39bd9b111bc6d2bcb56dfc5859e691b9c90db4c0
Parent:        4485b8edca559e9c45311f2a3b88d03bd3223834
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 14 12:31:30 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:40 2019 -0600

Revert "pvck: check result of dev_get_size"

This reverts commit 1f4968289c9c0e2a1e850317ef173df11938b7f3.

fixes folded into subsequent pvck commit
---
 tools/pvck.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index c6f6a33..ab3f7db 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1455,8 +1455,7 @@ static int _dump_search(struct cmd_context *cmd,
 		uint64_t dev_bytes;
 		uint64_t extra_bytes;
 
-		if (!dev_get_size(dev, &dev_sectors))
-			return_ECMD_FAILED;
+		dev_get_size(dev, &dev_sectors);
 
 		dev_bytes = dev_sectors * 512;
 		extra_bytes = dev_bytes % ONE_MB_IN_BYTES;



