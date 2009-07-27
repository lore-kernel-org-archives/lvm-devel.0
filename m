From: Thomas Woerner <twoerner@redhat.com>
Date: Mon, 27 Jul 2009 15:12:37 +0200
Subject: [PATCH 3/3] Initialize removed_pvs list in format-specific volume_group constructors.
In-Reply-To: <1248700357-10112-3-git-send-email-twoerner@redhat.com>
References: <1248700357-10112-1-git-send-email-twoerner@redhat.com>
	<1248700357-10112-2-git-send-email-twoerner@redhat.com>
	<1248700357-10112-3-git-send-email-twoerner@redhat.com>
Message-ID: <1248700357-10112-4-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Dave Wysochanski <dwysocha@redhat.com>

I think this is the reason the 'n' and 'p' members were still NULL.
Ideally, we should have a base constructor here that initializes the general,
non-format specific members of struct volume_group.  But until then, there
are multiple places to initialize these members.  Maybe a better patch would
be a base constructor patch for struct volume_group.  That is more work
though.  Maybe you could start one - might get bonus points.  ;-)

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 lib/format1/format1.c         |    1 +
 lib/format_pool/format_pool.c |    1 +
 lib/format_text/import_vsn1.c |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index c8f9519..aa1483a 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -132,6 +132,7 @@ static struct volume_group *_build_vg(struct format_instance *fid,
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
 
 	if (!_check_vgs(pvs))
 		goto_bad;
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 3f31bba..6f7e4b4 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -124,6 +124,7 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
 
 	if (!import_pool_vg(vg, smem, pds))
 		return_NULL;
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 629310a..3c41675 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -753,6 +753,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
 
 	/* Optional tags */
 	if ((cn = find_config_node(vgn, "tags")) &&
-- 
1.6.2.5


