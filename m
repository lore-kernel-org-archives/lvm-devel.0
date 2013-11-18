From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 18 Nov 2013 17:01:50 +0000 (UTC)
Subject: master - metadata: Make the fid mda routines a little more resilient.
Message-ID: <20131118170150.26BCF60E54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a6f91d7139119bea664050a957cbc21490398bc
Commit:        3a6f91d7139119bea664050a957cbc21490398bc
Parent:        03d3e1d9c17e959dc78a5bfa82cd69878653a9d2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Nov 18 18:00:49 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Nov 18 18:00:49 2013 +0100

metadata: Make the fid mda routines a little more resilient.

---
 lib/metadata/metadata.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index aa5f124..398def6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4400,6 +4400,9 @@ int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
 	if (!key)
 		return 1;
 
+	if (!fid->metadata_areas_index)
+		return_0;
+
 	/* Add metadata area to index. */
 	if (!_convert_key_to_string(key, key_len, sub_key,
 				    full_key, sizeof(full_key)))
@@ -4439,10 +4442,13 @@ struct metadata_area *fid_get_mda_indexed(struct format_instance *fid,
 	static char full_key[PATH_MAX];
 	struct metadata_area *mda = NULL;
 
+	if (!fid->metadata_areas_index)
+		return_NULL;
 
 	if (!_convert_key_to_string(key, key_len, sub_key,
 				    full_key, sizeof(full_key)))
 		return_NULL;
+
 	mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index,
 						      full_key);
 


