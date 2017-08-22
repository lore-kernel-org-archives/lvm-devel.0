From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Aug 2017 04:34:52 -0400
Subject: master - lvmcache: check for lvmcache_foreach_mda return code
Message-ID: <201708220834.v7M8Yqb4031368@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1e3f96c9764b242898914c282fb273803ba89ae
Commit:        c1e3f96c9764b242898914c282fb273803ba89ae
Parent:        d4ce98de4d6c7c3ddeca0e380a18bbdc102e6c3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 16 14:29:12 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 22 10:23:31 2017 +0200

lvmcache: check for lvmcache_foreach_mda return code

lvmcache_foreach_mda() can fail for numerous reasons
and failing error code cannot be ignored (out-of-memory...)

TODO: might need more error handling tunning.
---
 lib/format_text/text_label.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 6edfae7..ad323b6 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -437,7 +437,9 @@ out:
 	baton.info = info;
 	baton.label = *label;
 
-	lvmcache_foreach_mda(info, _update_mda, &baton);
+	if (!lvmcache_foreach_mda(info, _update_mda, &baton))
+		return_0;
+
 	lvmcache_make_valid(info);
 
 	return 1;


