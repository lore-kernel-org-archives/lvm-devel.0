From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed, 24 Aug 2022 10:26:12 +0000 (GMT)
Subject: main - libdm: report: fix escaping of JSON quote char in reported fields
Message-ID: <20220824102612.3AB20385354C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=800436d2affd4142b9d4b405112c4c30f1d31b5b
Commit:        800436d2affd4142b9d4b405112c4c30f1d31b5b
Parent:        508782a9135acf13b39b47605e675a5678495c58
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 24 12:08:51 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 24 12:10:10 2022 +0200

libdm: report: fix escaping of JSON quote char in reported fields

Commit 73ec3c954b21522352b6f5cce9a700d6bf30ccf4 added a way to print
only a part of the report string (repstr) to support decoding individual
string list items out of repstr.

The repstr is normally printed through _safe_repstr_output so that any
JSON_QUOTE character ('"') found within the repstr is escaped to not
interfere with value quoting in JSON format.

However, the commit 73ec3c954b21522352b6f5cce9a700d6bf30ccf4 missed
checking the 'len' argument passed to _safe_repstr_output function when
adding the rest of the repstr after all previous JSON_QUOTE characters
were escaped (when calling the last dm_pool_grow_object). When 'len'
is 0, we need to calculate the 'len' ourselves in the function by
simply calling strlen. This is because 'len' is passed to the function
only if we're taking a part of repstr, not as a whole.
---
 device_mapper/libdm-report.c | 11 +++--------
 libdm/libdm-report.c         | 11 +++--------
 2 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index d4cd06002..2d4c8883b 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -4572,17 +4572,12 @@ bad:
 static int _safe_repstr_output(struct dm_report *rh, const char *repstr, size_t len)
 {
 	const char *p_repstr;
-	const char *repstr_end = repstr + len;
+	const char *repstr_end = len ? repstr + len : repstr + strlen(repstr);
 
 	/* Escape any JSON_QUOTE that may appear in reported string. */
 	while (1) {
-		if (len) {
-			if (!(p_repstr = memchr(repstr, JSON_QUOTE[0], repstr_end - repstr)))
-				break;
-		} else {
-			if (!(p_repstr = strstr(repstr, JSON_QUOTE)))
-				break;
-		}
+		if (!(p_repstr = memchr(repstr, JSON_QUOTE[0], repstr_end - repstr)))
+			break;
 
 		if (p_repstr > repstr) {
 			if (!dm_pool_grow_object(rh->mem, repstr, p_repstr - repstr)) {
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index fc71ca5df..8eaf5896e 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4571,17 +4571,12 @@ bad:
 static int _safe_repstr_output(struct dm_report *rh, const char *repstr, size_t len)
 {
 	const char *p_repstr;
-	const char *repstr_end = repstr + len;
+	const char *repstr_end = len ? repstr + len : repstr + strlen(repstr);
 
 	/* Escape any JSON_QUOTE that may appear in reported string. */
 	while (1) {
-		if (len) {
-			if (!(p_repstr = memchr(repstr, JSON_QUOTE[0], repstr_end - repstr)))
-				break;
-		} else {
-			if (!(p_repstr = strstr(repstr, JSON_QUOTE)))
-				break;
-		}
+		if (!(p_repstr = memchr(repstr, JSON_QUOTE[0], repstr_end - repstr)))
+			break;
 
 		if (p_repstr > repstr) {
 			if (!dm_pool_grow_object(rh->mem, repstr, p_repstr - repstr)) {

