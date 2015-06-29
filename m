From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 12:46:33 +0000 (UTC)
Subject: master - toolcontext: use proper set of chars to check time format against
Message-ID: <20150629124633.7B97960C49@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=158723608911fae1f18df5ea3c506434b521b5b5
Commit:        158723608911fae1f18df5ea3c506434b521b5b5
Parent:        125cd06698bc1c52b812faa1686988b92cc2e192
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 29 14:45:45 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 14:45:53 2015 +0200

toolcontext: use proper set of chars to check time format against

---
 lib/commands/toolcontext.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0d243f2..09c14a3 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -443,10 +443,10 @@ static const char *_set_time_format(struct cmd_context *cmd)
 					chars_to_check = allowed_format_chars;
 
 				for (i = 0; chars_to_check[i]; i++) {
-					if (c == allowed_format_chars[i])
+					if (c == chars_to_check[i])
 						break;
 				}
-				if (!allowed_format_chars[i])
+				if (!chars_to_check[i])
 					goto_bad;
 			}
 			else if (isprint(c))


