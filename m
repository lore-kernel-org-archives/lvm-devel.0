From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:16 +0000 (UTC)
Subject: master - cleanup: reorder code
Message-ID: <20121215162516.A2901AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21f6511bc200af434fb933a181f5334021b3ee08
Commit:        21f6511bc200af434fb933a181f5334021b3ee08
Parent:        13835d04ac2a2c518ec935d220c7feb711327884
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 19:43:42 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: reorder code

Swap if() test condition and check for failure
and use traditional 'stack' trace.
---
 lib/format_text/format-text.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b562cfa..476d5d9 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2226,11 +2226,12 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 	if (!(fid = alloc_fid(fmt, fic)))
 		return_NULL;
 
-	if (_create_vg_text_instance(fid, fic))
-		return fid;
+	if (!_create_vg_text_instance(fid, fic)) {
+		dm_pool_destroy(fid->mem);
+		return_NULL;
+	}
 
-	dm_pool_destroy(fid->mem);
-	return NULL;
+	return fid;
 }
 
 static struct format_handler _text_handler = {


