From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Sep 2015 15:45:51 +0000 (UTC)
Subject: master - libdm: parse Overflow string from snapshot status
Message-ID: <20150918154551.2FB7960DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0d915a8733c690abc36f91f89cdcc542b35dc82
Commit:        e0d915a8733c690abc36f91f89cdcc542b35dc82
Parent:        90ad817a43a8c2ef6ca9d6797d5b9e50c6a87cfd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:41:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:45:45 2015 +0200

libdm: parse Overflow string from snapshot status

This is likely to be a new 'info' provided by kernel
snapshot target.
For now just parse this string.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |    1 +
 libdm/libdm-deptree.c |    2 ++
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c6250a6..006421b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.109 - 
 ======================================
+  Parse new Overflow status string for snapshot target.
   Check dir path components are valid if using dm_create_dir, error out if not.
   Fix /dev/mapper handling to remove dangling entries if symlinks are found.
   Make it possible to use blank value as selection for string list report field.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 098fa85..8077867 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -352,6 +352,7 @@ struct dm_status_snapshot {
 	unsigned has_metadata_sectors : 1; /* set when metadata_sectors is present */
 	unsigned invalid : 1;		/* set when snapshot is invalidated */
 	unsigned merge_failed : 1;	/* set when snapshot merge failed */
+	unsigned overflow : 1;		/* set when snapshot overflows */
 };
 
 int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 7b7ca5b..cc00014 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3126,6 +3126,8 @@ int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
 		s->invalid = 1;
 	else if (!strcmp(params, "Merge failed"))
 		s->merge_failed = 1;
+	else if (!strcmp(params, "Overflow"))
+		s->overflow = 1;
 	else {
 		dm_pool_free(mem, s);
 		log_error("Failed to parse snapshot params: %s.", params);


