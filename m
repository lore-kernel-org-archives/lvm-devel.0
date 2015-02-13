From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 13 Feb 2015 17:15:25 +0000 (UTC)
Subject: master - system_id: omit leading hyphens from system_id
Message-ID: <20150213171525.5BB4360CD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=def0866ded7c11b1a93fa7bd093e2433d90f09d3
Commit:        def0866ded7c11b1a93fa7bd093e2433d90f09d3
Parent:        737c992431aed05ed21d55e08a801660d0faa4b1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 13 11:14:46 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 13 11:14:46 2015 -0600

system_id: omit leading hyphens from system_id

---
 lib/misc/lvm-string.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 05d168a..f9cba31 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -118,6 +118,14 @@ void copy_valid_chars(const char *src, char *dst)
 	if (!s || !*s)
 		return;
 
+	/* Omit leading hypens. */
+	for (i = 0; i < strlen(src); i++) {
+		c = *s;
+		if (c != '-')
+			break;
+		s++;
+	}
+
 	for (i = 0; i < strlen(src); i++) {
 		c = *s;
 


