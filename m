From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Apr 2016 22:35:47 +0000 (UTC)
Subject: master - debug: move misplaced log_debug
Message-ID: <20160420223547.A805E60D88@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=509b2e524795d28f68be06b862794f7f0c5c9991
Commit:        509b2e524795d28f68be06b862794f7f0c5c9991
Parent:        57f468a53ed8ec425d1087ce06c90862caa19ff1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 20 12:45:15 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 21 00:34:01 2016 +0200

debug: move misplaced log_debug

It should log action before taking it instead of only in error path.
---
 lib/format_text/format-text.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 43ebd27..095ae97 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -985,8 +985,8 @@ static int _vg_write_file(struct format_instance *fid __attribute__((unused)),
 	if (lvm_fclose(fp, tc->path_edit))
 		return_0;
 
+	log_debug_metadata("Renaming %s to %s", temp_file, tc->path_edit);
 	if (rename(temp_file, tc->path_edit)) {
-		log_debug_metadata("Renaming %s to %s", temp_file, tc->path_edit);
 		log_error("%s: rename to %s failed: %s", temp_file,
 			  tc->path_edit, strerror(errno));
 		return 0;


