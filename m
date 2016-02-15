From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:27 +0000 (UTC)
Subject: master - pv: format-text: store PV_EXT_USED flag if PV is used and unset it otherwise
Message-ID: <20160215120827.A94F060DC9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d320d9c52bd1817daf5573b772e01a871837d2ee
Commit:        d320d9c52bd1817daf5573b772e01a871837d2ee
Parent:        10128c9bd67a027b480e0f0637745f97fb39ecfa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 12 10:59:27 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

pv: format-text: store PV_EXT_USED flag if PV is used and unset it otherwise

When adding a PV to VG, set the PV_EXT_USED flag in PV header and
vice versa - if the PV is no longer in a VG, unset the flag.
---
 lib/format_text/format-text.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index f290619..7202658 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1319,6 +1319,21 @@ static int _write_single_mda(struct metadata_area *mda, void *baton)
 	return 1;
 }
 
+static int _set_ext_flags(struct physical_volume *pv, struct lvmcache_info *info)
+{
+	uint32_t ext_flags = lvmcache_ext_flags(info);
+
+	if (is_orphan(pv))
+		ext_flags &= ~PV_EXT_USED;
+	else
+		ext_flags |= PV_EXT_USED;
+
+	lvmcache_set_ext_version(info, PV_HEADER_EXTENSION_VSN);
+	lvmcache_set_ext_flags(info, ext_flags);
+
+	return 1;
+}
+
 /* Only for orphans - FIXME That's not true any more */
 static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv)
 {
@@ -1402,6 +1417,9 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	if (!lvmcache_foreach_mda(info, _write_single_mda, &baton))
 		return_0;
 
+	if (!_set_ext_flags(pv, info))
+		return_0;
+
 	if (!label_write(pv->dev, label)) {
 		stack;
 		if (!dev_close(pv->dev))


