From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:08:18 -0500
Subject: master - hints: drop unneeded memset
Message-ID: <92367.119111412081603708@us-mta-422.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14e01d6316479a1ee6225010f36d348c103a26c7
Commit:        14e01d6316479a1ee6225010f36d348c103a26c7
Parent:        1760b96368ae41e76e89a7064254f995713a41e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:59:32 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

hints: drop unneeded memset

strncpy will zero buffer itself.
---
 lib/label/hints.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index ac2c089..45ab2ff 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -941,7 +941,6 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 		 * detect when the devices on the system change, which
 		 * invalidates the existing hints.
 		 */
-		memset(devpath, 0, sizeof(devpath));
 		strncpy(devpath, dev_name(dev), PATH_MAX);
 		hash = calc_crc(hash, (const uint8_t *)devpath, strlen(devpath));
 		count++;



