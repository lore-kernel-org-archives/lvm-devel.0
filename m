From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:58 +0000 (GMT)
Subject: main - debug: shorter code
Message-ID: <20210927165758.E50E6385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3b4c365a4d9fc3f88dcfaca6dff89b924fc4851
Commit:        e3b4c365a4d9fc3f88dcfaca6dff89b924fc4851
Parent:        f74d30d411af0849e4c7f5ac6027899a32b48f52
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 27 11:52:16 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

debug: shorter code

---
 lib/format_text/format-text.c | 71 ++++++++++---------------------------------
 1 file changed, 16 insertions(+), 55 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e8b1865f8..c880f0eb6 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1082,61 +1082,22 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 
 	rlocn_set_ignored(rlocn_slot0, mda_is_ignored(mda));
 
-	if (mdac->rlocn.size) {
-		if (precommit) {
-			log_debug_metadata("VG %s metadata precommit seq %u on %s mda header at %llu %s",
-					   vg->name, vg->seqno, dev_name(mdac->area.dev),
-					   (unsigned long long)mdac->area.start,
-					   mda_is_ignored(mda) ? "(ignored)" : "(used)");
-
-			log_debug_metadata("VG %s metadata precommit slot0 offset %llu size %llu slot1 offset %llu size %llu",
-					   vg->name,
-					   (unsigned long long)mdab->raw_locns[0].offset,
-					   (unsigned long long)mdab->raw_locns[0].size,
-					   (unsigned long long)mdab->raw_locns[1].offset,
-					   (unsigned long long)mdab->raw_locns[1].size);
-
-		} else {
-			log_debug_metadata("VG %s metadata commit seq %u on %s mda header at %llu %s",
-					   vg->name, vg->seqno, dev_name(mdac->area.dev),
-					   (unsigned long long)mdac->area.start,
-					   mda_is_ignored(mda) ? "(ignored)" : "(used)");
-
-			log_debug_metadata("VG %s metadata commit slot0 offset %llu size %llu slot1 offset %llu size %llu",
-					   vg->name,
-					   (unsigned long long)mdab->raw_locns[0].offset,
-					   (unsigned long long)mdab->raw_locns[0].size,
-					   (unsigned long long)mdab->raw_locns[1].offset,
-					   (unsigned long long)mdab->raw_locns[1].size);
-		}
-	} else {
-		if (precommit) {
-			log_debug_metadata("VG %s metadata precommit empty seq %u on %s mda header at %llu %s",
-					   vg->name, vg->seqno, dev_name(mdac->area.dev),
-					   (unsigned long long)mdac->area.start,
-					   mda_is_ignored(mda) ? "(ignored)" : "(used)");
-
-			log_debug_metadata("VG %s metadata precommit empty slot0 offset %llu size %llu slot1 offset %llu size %llu",
-					   vg->name,
-					   (unsigned long long)mdab->raw_locns[0].offset,
-					   (unsigned long long)mdab->raw_locns[0].size,
-					   (unsigned long long)mdab->raw_locns[1].offset,
-					   (unsigned long long)mdab->raw_locns[1].size);
-
-		} else {
-			log_debug_metadata("VG %s metadata commit empty seq %u on %s mda header at %llu %s",
-					   vg->name, vg->seqno, dev_name(mdac->area.dev),
-					   (unsigned long long)mdac->area.start,
-					   mda_is_ignored(mda) ? "(ignored)" : "(used)");
-
-			log_debug_metadata("VG %s metadata commit empty slot0 offset %llu size %llu slot1 offset %llu size %llu",
-					   vg->name,
-					   (unsigned long long)mdab->raw_locns[0].offset,
-					   (unsigned long long)mdab->raw_locns[0].size,
-					   (unsigned long long)mdab->raw_locns[1].offset,
-					   (unsigned long long)mdab->raw_locns[1].size);
-		}
-	}
+	log_debug_metadata("VG %s metadata %scommit %sseq %u on %s mda header at %llu %s.",
+			   vg->name,
+			   (precommit) ? "pre" : "",
+			   (!mdac->rlocn.size) ? "empty ": "",
+			   vg->seqno, dev_name(mdac->area.dev),
+			   (unsigned long long)mdac->area.start,
+			   mda_is_ignored(mda) ? "(ignored)" : "(used)");
+
+	log_debug_metadata("VG %s metadata %scommit %sslot0 offset %llu size %llu slot1 offset %llu size %llu.",
+			   vg->name,
+			   (precommit) ? "pre" : "",
+			   (!mdac->rlocn.size) ? "empty ": "",
+			   (unsigned long long)mdab->raw_locns[0].offset,
+			   (unsigned long long)mdab->raw_locns[0].size,
+			   (unsigned long long)mdab->raw_locns[1].offset,
+			   (unsigned long long)mdab->raw_locns[1].size);
 
 	rlocn_set_ignored(mdab->raw_locns, mda_is_ignored(mda));
 


