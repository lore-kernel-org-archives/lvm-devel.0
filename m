From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  3 Dec 2014 22:48:15 +0000 (UTC)
Subject: master - mirror: Validate raid region size config setting.
Message-ID: <20141203224815.3C7BF6118F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a057f40155b415be40dac31bb138ee66761ce999
Commit:        a057f40155b415be40dac31bb138ee66761ce999
Parent:        de53e0955dc43d5f069604553b038fa672463da9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Dec 3 22:47:08 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Dec 3 22:47:08 2014 +0000

mirror: Validate raid region size config setting.

If necessary, round down to a power of 2 the raid/mirror region size
taken from the config files.
---
 lib/metadata/lv_manip.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b00e11b..4483fba 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -731,7 +731,7 @@ int get_pv_list_for_lv(struct dm_pool *mem,
  *
  * Returns: default region_size in sectors
  */
-int get_default_region_size(struct cmd_context *cmd)
+static int _get_default_region_size(struct cmd_context *cmd)
 {
 	int mrs, rrs;
 
@@ -759,6 +759,35 @@ int get_default_region_size(struct cmd_context *cmd)
 	return rrs;
 }
 
+static int _round_down_pow2(int r)
+{
+	/* Set all bits to the right of the leftmost set bit */
+	r |= (r >> 1);
+	r |= (r >> 2);
+	r |= (r >> 4);
+	r |= (r >> 8);
+	r |= (r >> 16);
+
+	/* Pull out the leftmost set bit */
+	return r & ~(r >> 1);
+}
+
+int get_default_region_size(struct cmd_context *cmd)
+{
+	int region_size = _get_default_region_size(cmd);
+
+	if (region_size > INT32_MAX)
+		region_size = INT32_MAX;
+
+	if (region_size & (region_size - 1)) {
+		region_size = _round_down_pow2(region_size);
+		log_verbose("Reducing mirror region size to %u kiB (power of 2).",
+			    region_size / 2);
+	}
+
+	return region_size;
+}
+
 int add_seg_to_segs_using_this_lv(struct logical_volume *lv,
 				  struct lv_segment *seg)
 {


