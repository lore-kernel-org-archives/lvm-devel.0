From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 30 Apr 2010 11:07:19 +0200
Subject: [PATCH 1/3] Display errornous pattern to the user
In-Reply-To: <cover.1272618315.git.zkabelac@redhat.com>
References: <cover.1272618315.git.zkabelac@redhat.com>
Message-ID: <faa688b19e8215fa87f2e86d9362e74f15337281.1272618315.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Show string with errornous pattern and start error message with
capital letter.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/filters/filter-regex.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 1d415a4..c062402 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -103,7 +103,7 @@ static int _build_matcher(struct rfilter *rf, struct config_value *val)
 	 */
 	for (v = val; v; v = v->next) {
 		if (v->type != CFG_STRING) {
-			log_error("filter patterns must be enclosed in quotes");
+			log_error("Filter patterns must be enclosed in quotes.");
 			goto out;
 		}
 
@@ -128,7 +128,7 @@ static int _build_matcher(struct rfilter *rf, struct config_value *val)
 	 */
 	for (v = val, i = count - 1; v; v = v->next, i--)
 		if (!_extract_pattern(scratch, v->v.str, regex, rf->accept, i)) {
-			log_error("invalid filter pattern");
+			log_error("Invalid filter pattern \"%s\".", v->v.str);
 			goto out;
 		}
 
-- 
1.7.0.1


