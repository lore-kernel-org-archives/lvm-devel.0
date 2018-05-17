From: David Teigland <teigland@sourceware.org>
Date: Thu, 17 May 2018 16:19:26 -0400
Subject: master - liblvm2app: fix valgrind memory warning
Message-ID: <201805172019.w4HKJQxq014439@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=286c9c78b49f3b52bb05cef93659bb91e4249dc9
Commit:        286c9c78b49f3b52bb05cef93659bb91e4249dc9
Parent:        a39eaea27dcd2fd895740193e82ca6d0683eb3ad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 17 15:18:11 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 17 15:18:11 2018 -0500

liblvm2app: fix valgrind memory warning

---
 lib/metadata/metadata.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2609840..2f84d5f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4830,7 +4830,7 @@ static int _get_pvs(struct cmd_context *cmd, uint32_t warn_flags,
 		struct dm_list *pvslist, struct dm_list *vgslist)
 {
 	struct dm_str_list *strl;
-	const char *vgname, *vgid;
+	const char *vgname, *name, *vgid;
 	struct pv_list *pvl, *pvl_copy;
 	struct dm_list *vgids;
 	struct volume_group *vg;
@@ -4856,11 +4856,13 @@ static int _get_pvs(struct cmd_context *cmd, uint32_t warn_flags,
 		if (!vgid)
 			continue;	/* FIXME Unnecessary? */
 		consistent = 0;
-		if (!(vgname = lvmcache_vgname_from_vgid(NULL, vgid))) {
+		if (!(name = lvmcache_vgname_from_vgid(NULL, vgid))) {
 			stack;
 			continue;
 		}
 
+		vgname = dm_pool_strdup(cmd->mem, name);
+
 		/*
 		 * When we are retrieving a list to return toliblvm we need
 		 * that list to contain VGs that are modifiable as we are using


