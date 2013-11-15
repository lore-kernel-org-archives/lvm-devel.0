From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:28 +0000 (UTC)
Subject: master - report: using _field_set_value
Message-ID: <20131115113928.A189E6135C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9eb81b1bf74411bba6cc950a4ebe0a44856c0e74
Commit:        9eb81b1bf74411bba6cc950a4ebe0a44856c0e74
Parent:        49ccf44f4505242262bf35f7e226d2791aad9397
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 23 10:17:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 11:05:02 2013 +0100

report: using _field_set_value

Simple conversion to use _field_set_value() and shorteing
the code.
---
 lib/report/report.c |  162 ++++++++++++++++++---------------------------------
 1 files changed, 56 insertions(+), 106 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 49a6b8a..697d642 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -106,12 +106,11 @@ static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm
 			 const void *data, void *private __attribute__((unused)))
 {
 	char *str;
-	if (!(str = lvseg_devices(mem, (const struct lv_segment *) data)))
-		return 0;
 
-	dm_report_field_set_value(field, str, NULL);
+	if (!(str = lvseg_devices(mem, (const struct lv_segment *) data)))
+		return_0;
 
-	return 1;
+	return _field_set_value(field, str, NULL);
 }
 
 static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -119,12 +118,11 @@ static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct d
 			  const void *data, void *private __attribute__((unused)))
 {
 	char *str;
-	if (!(str = lvseg_seg_pe_ranges(mem, (const struct lv_segment *) data)))
-		return 0;
 
-	dm_report_field_set_value(field, str, NULL);
+	if (!(str = lvseg_seg_pe_ranges(mem, (const struct lv_segment *) data)))
+		return_0;
 
-	return 1;
+	return _field_set_value(field, str, NULL);
 }
 
 static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -135,11 +133,9 @@ static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 	char *tags_str;
 
 	if (!(tags_str = tags_format_and_copy(mem, tags)))
-		return 0;
-
-	dm_report_field_set_value(field, tags_str, NULL);
+		return_0;
 
-	return 1;
+	return _field_set_value(field, tags_str, NULL);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -150,10 +146,9 @@ static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *modules_str;
 
 	if (!(modules_str = lv_modules_dup(mem, lv)))
-		return 0;
+		return_0;
 
-	dm_report_field_set_value(field, modules_str, NULL);
-	return 1;
+	return _field_set_value(field, modules_str, NULL);
 }
 
 static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -165,8 +160,7 @@ static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lv->profile)
 		return dm_report_field_string(rh, field, &lv->profile->name);
 
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -175,12 +169,10 @@ static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
 
-	if (!vg->fid) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (vg->fid)
+		return _string_disp(rh, mem, field, &vg->fid->fmt->name, private);
 
-	return _string_disp(rh, mem, field, &vg->fid->fmt->name, private);
+	return _field_set_value(field, "", NULL);
 }
 
 static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -190,12 +182,10 @@ static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
 
-	if (!pv->fmt) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (pv->fmt)
+		return _string_disp(rh, mem, field, &pv->fmt->name, private);
 
-	return _string_disp(rh, mem, field, &pv->fmt->name, private);
+	return _field_set_value(field, "", NULL);
 }
 
 static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -232,10 +222,9 @@ static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 	char *repstr;
 
 	if (!(repstr = lv_attr_dup(mem, lv)))
-		return 0;
+		return_0;
 
-	dm_report_field_set_value(field, repstr, NULL);
-	return 1;
+	return _field_set_value(field, repstr, NULL);
 }
 
 static int _pvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -247,10 +236,9 @@ static int _pvstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 	char *repstr;
 
 	if (!(repstr = pv_attr_dup(mem, pv)))
-		return 0;
+		return_0;
 
-	dm_report_field_set_value(field, repstr, NULL);
-	return 1;
+	return _field_set_value(field, repstr, NULL);
 }
 
 static int _vgstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -261,10 +249,9 @@ static int _vgstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 	char *repstr;
 
 	if (!(repstr = vg_attr_dup(mem, vg)))
-		return 0;
+		return_0;
 
-	dm_report_field_set_value(field, repstr, NULL);
-	return 1;
+	return _field_set_value(field, repstr, NULL);
 }
 
 static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
@@ -280,8 +267,7 @@ static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
 		return 0;
 	}
 
-	dm_report_field_set_value(field, name, NULL);
-	return 1;
+	return _field_set_value(field, name, NULL);
 }
 
 static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -294,8 +280,7 @@ static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((
 	if ((name = lv_mirror_log_dup(mem, lv)))
 		return dm_report_field_string(rh, field, &name);
 
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -325,9 +310,7 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	dm_report_field_set_value(field, repstr, lvname);
-
-	return 1;
+	return _field_set_value(field, repstr, lvname);
 }
 
 static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -340,8 +323,7 @@ static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (seg)
 		return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
 
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -354,8 +336,7 @@ static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribut
 	if (seg)
 		return _lvname_disp(rh, mem, field, seg->metadata_lv, private);
 
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -368,8 +349,7 @@ static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (seg)
 		return _lvname_disp(rh, mem, field, seg->pool_lv, private);
 
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _lvpath_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -380,11 +360,9 @@ static int _lvpath_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr;
 
 	if (!(repstr = lv_path_dup(mem, lv)))
-		return 0;
-
-	dm_report_field_set_value(field, repstr, NULL);
+		return_0;
 
-	return 1;
+	return _field_set_value(field, repstr, NULL);
 }
 
 static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -402,8 +380,7 @@ static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
 		return _lvname_disp(rh, mem, field, first_seg(lv)->external_lv, private);
 
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -413,11 +390,10 @@ static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name;
 
-	if (!(name = lv_move_pv_dup(mem, lv)))
-		dm_report_field_set_value(field, "", NULL);
-	else
+	if ((name = lv_move_pv_dup(mem, lv)))
 		return dm_report_field_string(rh, field, &name);
-	return 1;
+
+	return _field_set_value(field, "", NULL);
 }
 
 static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -425,14 +401,12 @@ static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute
 			   const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *name = NULL;
+	const char *name;
 
-	name = lv_convert_lv_dup(mem, lv);
-	if (name)
+	if ((name = lv_convert_lv_dup(mem, lv)))
 		return dm_report_field_string(rh, field, &name);
 
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _size32_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -458,9 +432,7 @@ static int _size32_disp(struct dm_report *rh __attribute__((unused)), struct dm_
 
 	*sortval = (uint64_t) size;
 
-	dm_report_field_set_value(field, repstr, sortval);
-
-	return 1;
+	return _field_set_value(field, repstr, sortval);
 }
 
 static int _size64_disp(struct dm_report *rh __attribute__((unused)),
@@ -486,9 +458,8 @@ static int _size64_disp(struct dm_report *rh __attribute__((unused)),
 	}
 
 	*sortval = size;
-	dm_report_field_set_value(field, repstr, sortval);
 
-	return 1;
+	return _field_set_value(field, repstr, sortval);
 }
 
 static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -520,10 +491,8 @@ static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
-	if (lv->read_ahead == DM_READ_AHEAD_AUTO) {
-		dm_report_field_set_value(field, "auto", &_minusone64);
-		return 1;
-	}
+	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
+		return _field_set_value(field, "auto", &_minusone64);
 
 	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
 }
@@ -561,9 +530,7 @@ static int _segmonitor_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!(str = lvseg_monitor_dup(mem, (const struct lv_segment *)data)))
 		return_0;
 
-	dm_report_field_set_value(field, str, NULL);
-
-	return 1;
+	return _field_set_value(field, str, NULL);
 }
 
 static int _segstart_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -663,9 +630,7 @@ static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
 		return dm_report_field_string(rh, field, &discards_str);
 	}
 
-	dm_report_field_set_value(field, "", NULL);
-
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -678,9 +643,7 @@ static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (size)
 		return _size64_disp(rh, mem, field, &size, private);
 
-	dm_report_field_set_value(field, "", &_zero64);
-
-	return 1;
+	return _field_set_value(field, "", &_zero64);
 }
 
 static int _pvused_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -741,13 +704,12 @@ static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 		      struct dm_report_field *field,
 		      const void *data, void *private __attribute__((unused)))
 {
-	char *repstr = NULL;
+	char *repstr;
 
 	if (!(repstr = id_format_and_copy(mem, data)))
 		return_0;
 
-	dm_report_field_set_value(field, repstr, NULL);
-	return 1;
+	return _field_set_value(field, repstr, NULL);
 }
 
 static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -799,10 +761,8 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint32_t count = vg_mda_copies(vg);
 
-	if (count == VGMETADATACOPIES_UNMANAGED) {
-		dm_report_field_set_value(field, "unmanaged", &_minusone64);
-		return 1;
-	}
+	if (count == VGMETADATACOPIES_UNMANAGED)
+		return _field_set_value(field, "unmanaged", &_minusone64);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -816,8 +776,7 @@ static int _vgprofile_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (vg->profile)
 		return dm_report_field_string(rh, field, &vg->profile->name);
 
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
+	return _field_set_value(field, "", NULL);
 }
 
 static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1006,13 +965,10 @@ static int _raidsyncaction_disp(struct dm_report *rh __attribute__((unused)),
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *sync_action;
 
-	if (!(lv->status & RAID) ||
-	    !lv_raid_sync_action(lv, &sync_action)) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (lv_is_raid(lv) && lv_raid_sync_action(lv, &sync_action))
+		return _string_disp(rh, mem, field, &sync_action, private);
 
-	return _string_disp(rh, mem, field, &sync_action, private);
+	return _field_set_value(field, "", NULL);
 }
 
 static int _raidmismatchcount_disp(struct dm_report *rh __attribute__((unused)),
@@ -1211,9 +1167,7 @@ static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	*sortval = lv->timestamp;
 
-	dm_report_field_set_value(field, repstr, sortval);
-
-	return 1;
+	return _field_set_value(field, repstr, sortval);
 }
 
 static int _lvhost_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1228,9 +1182,7 @@ static int _lvhost_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	dm_report_field_set_value(field, repstr, repstr);
-
-	return 1;
+	return _field_set_value(field, repstr, NULL);
 }
 
 static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1244,9 +1196,7 @@ static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	dm_report_field_set_value(field, repstr, NULL);
-
-	return 1;
+	return _field_set_value(field, repstr, NULL);
 }
 
 /* Report object types */


