From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:27 +0000 (UTC)
Subject: master - thin: tighten discard string conversions
Message-ID: <20120807203027.688103283@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b5ea9a5a89b4eff41520142f719a7d89435f7df
Commit:        7b5ea9a5a89b4eff41520142f719a7d89435f7df
Parent:        adfa778a58719cb78971526b68a93cee56a18cc4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 18:37:35 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 18:37:35 2012 +0100

thin: tighten discard string conversions

Respond with "unknown" rather than a NULL pointer if there's an
internal error and the discard value is invalid.

Don't accept 'no_passdown' or 'no-passdown' variants in the LVM
metadata: this is written by the program so should only ever contain
"nopassdown" and should be validated strictly against that.
---
 lib/metadata/thin_manip.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 8d1744c..0395b48 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -433,10 +433,7 @@ int get_pool_discard(const char *str, thin_discard_t *discard)
 {
 	if (!strcasecmp(str, "passdown"))
 		*discard = THIN_DISCARD_PASSDOWN;
-        /* Allow some variation in thin parameter */
-	else if (!strcasecmp(str, "nopassdown") ||
-		 !strcasecmp(str, "no-passdown") ||
-		 !strcasecmp(str, "no_passdown"))
+	else if (!strcasecmp(str, "nopassdown"))
 		*discard = THIN_DISCARD_NO_PASSDOWN;
 	else if (!strcasecmp(str, "ignore"))
 		*discard = THIN_DISCARD_IGNORE;
@@ -459,7 +456,7 @@ const char *get_pool_discard_name(thin_discard_t discard)
 		return "ignore";
 	}
 
-	log_error(INTERNAL_ERROR "Uknown discard type.");
+	log_error(INTERNAL_ERROR "Uknown discard type encountered.");
 
-	return NULL;
+	return "unknown";
 }


