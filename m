From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:31 +0100
Subject: [PATCH 08/24] Perf: optimize _eat_space and _get_token
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <940671e7df6a46240a08536590d725900f51eb33.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Makes the code more readable and has a smaller number of memory
accesses.

For _get_token() optimize number parsing. Check for '.' char only
if it's not a digit. Move pointer incrementation into one place.

For _eat_space() check only p->te for '\0' in skipping of comment line.
Avoid check for '\0' when we know it is space. Also master while loop
doesn't need checking p->tb for '\0'. We just need to check p->tb
isn't already at the end of buffer. This could give 'extra' loop cycle
if we are already there - but safes memory access in every other case.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/config.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 237c610..53a6a57 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -821,18 +821,20 @@ static void _get_token(struct parser *p, int tok_prev)
 	case '+':
 	case '-':
 		if (values_allowed) {
-			te++;
-			while ((te != p->fe) && (*te)) {
-				if (*te == '.') {
-					if (p->t == TOK_FLOAT)
-						break;
-					p->t = TOK_FLOAT;
-				} else if (!isdigit((int) *te))
+			while (++te != p->fe) {
+				if (!isdigit((int) *te)) {
+					if (*te == '.') {
+						if (p->t != TOK_FLOAT) {
+							p->t = TOK_FLOAT;
+							continue;
+						}
+					}
 					break;
-				te++;
+				}
 			}
 			break;
 		}
+		/* fall through */
 
 	default:
 		p->t = TOK_IDENTIFIER;
@@ -849,21 +851,19 @@ static void _get_token(struct parser *p, int tok_prev)
 
 static void _eat_space(struct parser *p)
 {
-	while ((p->tb != p->fe) && (*p->tb)) {
+	while (p->tb != p->fe) {
 		if (*p->te == '#')
 			while ((p->te != p->fe) && (*p->te) && (*p->te != '\n'))
 				p->te++;
 
-		else if (isspace(*p->te)) {
-			while ((p->te != p->fe) && (*p->te) && isspace(*p->te)) {
-				if (*p->te == '\n')
-					p->line++;
-				p->te++;
-			}
-		}
+		else if (!isspace(*p->te))
+			break;
 
-		else
-			return;
+		while ((p->te != p->fe) && isspace(*p->te)) {
+			if (*p->te == '\n')
+				p->line++;
+			p->te++;
+		}
 
 		p->tb = p->te;
 	}
-- 
1.7.3.5


