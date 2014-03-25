From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:45 +0000 (UTC)
Subject: master - cleanup: use dm_free without extra test
Message-ID: <20140325102345.5463960F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=406ec4162f86d872e041d7aa524d1f7dfd0d1cc0
Commit:        406ec4162f86d872e041d7aa524d1f7dfd0d1cc0
Parent:        4a6f05e42085c0d3e8bc4b5352b57ab9b4434e02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 09:20:18 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:59 2014 +0100

cleanup: use dm_free without extra test

It's ok to free(NULL).
---
 daemons/dmeventd/libdevmapper-event.c |    8 ++++----
 lib/cache/lvmetad.c                   |    3 +--
 lib/format_text/format-text.c         |   13 +++++--------
 tools/pvscan.c                        |    6 ++----
 4 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 80d4420..b6e2f0d 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -700,8 +700,7 @@ static int _parse_message(struct dm_event_daemon_message *msg, char **dso_name,
 		return 0;
 	}
 
-	if (id)
-		dm_free(id);
+	dm_free(id);
 	return -ENOMEM;
 }
 
@@ -863,12 +862,13 @@ int dm_event_get_timeout(const char *device_path, uint32_t *timeout)
 		if (!p) {
 			log_error("malformed reply from dmeventd '%s'\n",
 				  msg.data);
+			dm_free(msg.data);
 			return -EIO;
 		}
 		*timeout = atoi(p);
 	}
-	if (msg.data)
-		dm_free(msg.data);
+	dm_free(msg.data);
+
 	return ret;
 }
 #endif
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index cc51258..040a790 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -114,8 +114,7 @@ void lvmetad_set_token(const struct dm_config_value *filter)
 {
 	int ft = 0;
 
-	if (_lvmetad_token)
-		dm_free(_lvmetad_token);
+	dm_free(_lvmetad_token);
 
 	while (filter && filter->type == DM_CFG_STRING) {
 		ft = calc_crc(ft, (const uint8_t *) filter->v.str, strlen(filter->v.str));
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 29df5f1..a652590 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -677,10 +677,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		if (!dev_close(mdac->area.dev))
 			stack;
 
-		if (fidtc->raw_metadata_buf) {
-			dm_free(fidtc->raw_metadata_buf);
-			fidtc->raw_metadata_buf = NULL;
-		}
+		dm_free(fidtc->raw_metadata_buf);
+		fidtc->raw_metadata_buf = NULL;
 	}
 
 	return r;
@@ -766,10 +764,9 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!precommit) {
 		if (!dev_close(mdac->area.dev))
 			stack;
-		if (fidtc->raw_metadata_buf) {
-			dm_free(fidtc->raw_metadata_buf);
-			fidtc->raw_metadata_buf = NULL;
-		}
+
+		dm_free(fidtc->raw_metadata_buf);
+		fidtc->raw_metadata_buf = NULL;
 	}
 
 	return r;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 9e5536e..724ae5f 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -169,15 +169,13 @@ static int _clear_dev_from_lvmetad_cache(dev_t devno, int32_t major, int32_t min
 	if (!dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor))
 		stack;
 	if (!lvmetad_pv_gone(devno, buf ? : "", handler)) {
-		if (buf)
-			dm_free(buf);
+		dm_free(buf);
 		return 0;
 	}
 
 	log_print_unless_silent("Device %s not found. "
 				"Cleared from lvmetad cache.", buf ? : "");
-	if (buf)
-		dm_free(buf);
+	dm_free(buf);
 
 	return 1;
 }


