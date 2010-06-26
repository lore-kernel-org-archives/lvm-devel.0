From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:47 -0400
Subject: [PATCH 16/38] Add mdas_empty_or_ignored() helper function.
In-Reply-To: <1277520789-6808-16-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-17-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a helper function to consolidate checking for an empty mdas list
or ignored mdas.  Ignored mdas should behave almost identically to
an empty mda list - the metadata areas should not be read or written
to.  This function will make it easier to implement metadata balancing
and easier to track pvs with an empty mda list or ignored mdas.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   13 +++++++++++++
 lib/metadata/metadata.h |    1 +
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 525c360..ee419ba 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4039,6 +4039,19 @@ int pv_mda_set_ignored(const struct physical_volume *pv, int value)
 	return 1;
 }
 
+int mdas_empty_or_ignored(struct dm_list *mdas)
+{
+	struct metadata_area *mda;
+
+	if (!dm_list_size(mdas))
+		return 1;
+	dm_list_iterate_items(mda, mdas) {
+		if (mda_is_ignored(mda))
+			return 1;
+	}
+	return 0;
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index fd89423..63f9f72 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -185,6 +185,7 @@ void mda_set_ignored(struct metadata_area *mda, int value);
 int mda_locn_match(struct metadata_area *mda1, struct metadata_area *mda2);
 void fid_add_mda(struct format_instance *fid, struct metadata_area *mda);
 int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas);
+int mdas_empty_or_ignored(struct dm_list *mdas);
 
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
-- 
1.6.0.6


