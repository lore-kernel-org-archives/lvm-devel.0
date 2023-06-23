From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:47 +0000 (GMT)
Subject: main - debug: add backtraces
Message-ID: <20230623160947.173B73858434@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46fe47b8e0ad8069bb3736d2aa3e78befdccb38d
Commit:        46fe47b8e0ad8069bb3736d2aa3e78befdccb38d
Parent:        a1d5fba666ccc6f3189d492ba01896f79cf6176f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 16:04:55 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:08:03 2023 +0200

debug: add backtraces

---
 lib/config/config.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 5531e431d..1c074abe8 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -741,13 +741,13 @@ static struct dm_config_value *_get_def_array_values(struct cmd_context *cmd,
 	}
 	/* Proper value always starts with '#'. */
 	if (token[0] != '#')
-		goto bad;
+		goto_bad;
 
 	while (token) {
 		/* Move to type identifier. Error on no char. */
 		token++;
 		if (!token[0])
-			goto bad;
+			goto_bad;
 
 		/* Move to the actual value and decode any "##" into "#". */
 		p = token + 1;

