From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 25 Jul 2016 11:59:53 +0000 (UTC)
Subject: master - segtype: Fix unrecognised flag message.
Message-ID: <20160725115953.A62E660DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5397837a9f334fa91973e36acf38655a19b88b28
Commit:        5397837a9f334fa91973e36acf38655a19b88b28
Parent:        e4e29add685fce5473bec3c23013a1ddb72fd4b6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 25 12:56:25 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 25 12:59:50 2016 +0100

segtype: Fix unrecognised flag message.

Show in hex not decimal.
---
 WHATS_NEW              |    1 +
 lib/metadata/segtype.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0d6d010..ca12e8c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.162 - 
 =================================
+  Fix unrecognised segtype flag message.
   lvconvert reuse cachepool metadade now ONLY with -Zn and clear otherwise.
   Enabled lvconvert --uncache to work with partial VG.
 
diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index 2b060da..35823d9 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -47,7 +47,7 @@ struct segment_type *get_segtype_from_flag(struct cmd_context *cmd, uint64_t fla
 		if (flag & segtype->flags)
 			return segtype;
 
-	log_error(INTERNAL_ERROR "Unrecognised segment type flag 0x%" PRIu64, flag);
+	log_error(INTERNAL_ERROR "Unrecognised segment type flag 0x%" PRIx64, flag);
 
 	return NULL;
 }


