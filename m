From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 16 Sep 2009 22:06:24 -0400
Subject: [PATCH] update dmeventd plugins to use proper lvm2_log_fn_t
Message-ID: <20090917020623.GA7271@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The dmeventd plugins provide their own _temporary_log_fn.  But they were
not updated when lvm2_log_fn_t was last updated, see:
http://sources.redhat.com/git/?p=lvm2.git;a=commit;h=0ed40c04c

I verified this patch fixes a SEGV seen in the dmeventd snapshot plugin:

# lvs
  LV          VG   Attr   LSize   Origin Snap%  Move Log Copy%  Convert
  testlv      test owi-a- 300.00M
  testlv_snap test swi-ao  52.00M testlv  92.68
# vgchange --monitor y test
  2 logical volume(s) in volume group "test" monitored

and messages file shows:

Sep 16 21:15:05 really-raw dmeventd[12522]: dmeventd ready for processing.
Sep 16 21:15:11 really-raw lvm[12522]: Monitoring snapshot test-testlv_snap
Sep 16 21:15:15 really-raw lvm[12522]: Snapshot test-testlv_snap is now 92% full.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>

---
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 8869e80..503ec0d 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -126,8 +126,10 @@ out_parse:
 	return ME_IGNORE;
 }
 
-static void _temporary_log_fn(int level, const char *file __attribute((unused)),
+static void _temporary_log_fn(int level,
+			      const char *file __attribute((unused)),
 			      int line __attribute((unused)),
+			      int dm_errno __attribute((unused)),
 			      const char *format)
 {
 	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 3e250af..96c4688 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -57,6 +57,7 @@ static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 static void _temporary_log_fn(int level,
 			      const char *file __attribute((unused)),
 			      int line __attribute((unused)),
+			      int dm_errno __attribute((unused)),
 			      const char *format)
 {
 	if (!strncmp(format, "WARNING: ", 9) && (level < 5))


