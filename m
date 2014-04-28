From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 28 Apr 2014 10:43:49 +0000 (UTC)
Subject: master - cleanup: put all tests within switch
Message-ID: <20140428104349.B48A860FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8214cb1546f942cc7cbcfb4849b4549132d74a0
Commit:        d8214cb1546f942cc7cbcfb4849b4549132d74a0
Parent:        d1aba7ccf6d1bc5f3bc1fa1b5fe70eec64f8c633
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 28 10:17:30 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 28 12:42:56 2014 +0200

cleanup: put all tests within switch

No reason to check for VALID in extra if.
---
 lib/display/display.c |   49 +++++++++++++++++++++++++------------------------
 1 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 36274b6..b83bb59 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -840,30 +840,31 @@ void display_tags(const struct cmd_context *cmd)
 
 void display_name_error(name_error_t name_error)
 {
-	if (name_error != NAME_VALID) {
-		switch(name_error) {
-		case NAME_INVALID_EMPTY:
-			log_error("Name is zero length");
-			break;
-		case NAME_INVALID_HYPEN:
-			log_error("Name cannot start with hyphen");
-			break;
-		case NAME_INVALID_DOTS:
-			log_error("Name starts with . or .. and has no "
-						"following character(s)");
-			break;
-		case NAME_INVALID_CHARSET:
-			log_error("Name contains invalid character, valid set includes: "
-					"[a-zA-Z0-9.-_+]");
-			break;
-		case NAME_INVALID_LENGTH:
-			/* Report that name length -1 to accommodate nul*/
-			log_error("Name length exceeds maximum limit of %d", (NAME_LEN -1));
-			break;
-		default:
-			log_error("Unknown error %d on name validation", name_error);
-			break;
-		}
+	switch(name_error) {
+	case NAME_VALID:
+		/* Valid name */
+		break;
+	case NAME_INVALID_EMPTY:
+		log_error("Name is zero length.");
+		break;
+	case NAME_INVALID_HYPEN:
+		log_error("Name cannot start with hyphen.");
+		break;
+	case NAME_INVALID_DOTS:
+		log_error("Name starts with . or .. and has no "
+			  "following character(s).");
+		break;
+	case NAME_INVALID_CHARSET:
+		log_error("Name contains invalid character, valid set includes: "
+			  "[a-zA-Z0-9.-_+].");
+		break;
+	case NAME_INVALID_LENGTH:
+		/* Report that name length - 1 to accommodate nul*/
+		log_error("Name length exceeds maximum limit of %d.", (NAME_LEN - 1));
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Unknown error %d on name validation.", name_error);
+		break;
 	}
 }
 


