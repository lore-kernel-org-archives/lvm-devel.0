From: corubba <corubba@gmx.de>
Date: Thu, 27 Oct 2022 03:20:24 +0200
Subject: [PATCH 2/2] report: query lvmlockd for lv_active_exclusively
In-Reply-To: <752e9d7d-028d-270c-9024-f50feadc2d5a@gmx.de>
References: <752e9d7d-028d-270c-9024-f50feadc2d5a@gmx.de>
Message-ID: <b2e8d774-e127-6a62-22c3-5d62c581c9ad@gmx.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adjusted the lv_active_exclusively option to account for shared VGs.

A LV is definitely not exclusively active if:
- it is not (locally) active, regardless of whether it is in a local or
   shared VG.
- it is in a shared VG, locally active, and lvmlockd reports a
   non-exclusive lock (e.g. shared lock or no lock at all).

A LV is definitely exclusively active if:
- it is in a local VG, and (locally) active.
- it is in a shared VG, locally active, and lvmlockd reports a exclusive
   lock.

The "exclusively active" state of a LV is undefined if:
- it is in a shared VG, locally active, and lvmlockd can't be reached or
   responds with an error.

For the sanlock lvmlock LV, lvmlockd reports no lock and it is thus
shown as not exclusively active.

The lvmlockd socket is opened and closed for every query. This may pose
a performance bottleneck, and could be optimised by lazy-opening it once
when needed for the first time, and closing it once after all LVs are
done.

Signed-off-by: corubba <corubba@gmx.de>
---
  lib/report/report.c | 56 +++++++++++++++++++++++++++++++++++++++++++++
  1 file changed, 56 insertions(+)

diff --git a/lib/report/report.c b/lib/report/report.c
index cb5fc93c8..f3a7ff44d 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -25,6 +25,8 @@
  #include "lib/device/device-types.h"
  #include "lib/datastruct/str_list.h"

+#include "daemons/lvmlockd/lvmlockd-client.h"
+
  #include <stddef.h> /* offsetof() */
  #include <float.h> /* DBL_MAX */
  #include <time.h>
@@ -3849,6 +3851,55 @@ static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
  	return _binary_disp(rh, mem, field, active_remotely, GET_FIRST_RESERVED_NAME(lv_active_remotely_y), private);
  }

+/* Returns 0 on success, 1 on error. */
+static int _lvactiveexclusively_lvmlockd(const struct logical_volume *lv, int *active_exclusively)
+{
+	int ret = 0;
+	daemon_handle lvmlockd;
+	daemon_reply reply;
+	const char *reply_str = NULL;
+
+	log_debug("lvmlockd query_lock_lv %s/%s", lv->vg->name, lv->name);
+
+	lvmlockd = lvmlockd_open(NULL);
+	if (lvmlockd.socket_fd < 0 || lvmlockd.error) {
+		log_error("Cannot connect to lvmlockd.");
+		return 1;
+	}
+
+	reply = daemon_send_simple(lvmlockd,
+			"query_lock_lv",
+			"pid = " FMTd64, (int64_t) getpid(),
+			"opts = %s", "none",
+			"vg_name = %s", lv->vg->name,
+			"lv_name = %s", lv->name,
+			"lv_uuid = %s", lv_uuid_dup(NULL, lv),
+			"vg_lock_type = %s", lv->vg->lock_type,
+			"vg_lock_args = %s", lv->vg->lock_args,
+			"lv_lock_args = %s", lv->lock_args,
+			NULL);
+
+	if (reply.error) {
+		log_error("reply error %d", reply.error);
+		ret = 1;
+	}
+
+	if (!ret)
+		reply_str = daemon_reply_str(reply, "mode", NULL);
+	if (!ret && !reply_str) {
+		log_error("query_lock_lv mode not returned");
+		ret = 1;
+	} else if (!ret) {
+		log_debug("query_lock_lv result mode %s", reply_str);
+		*active_exclusively = strcmp(reply_str, "ex") ? 0 : 1;
+	}
+
+	daemon_reply_destroy(reply);
+	lvmlockd_close(lvmlockd);
+
+	return ret;
+}
+
  static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
  				     struct dm_report_field *field,
  				     const void *data, void *private)
@@ -3861,6 +3912,11 @@ static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,

  	active_exclusively = lv_is_active(lv);

+	if (active_exclusively && vg_is_shared(lv->vg)) {
+		if (_lvactiveexclusively_lvmlockd(lv, &active_exclusively))
+			return _binary_undef_disp(rh, mem, field, private);
+	}
+
  	return _binary_disp(rh, mem, field, active_exclusively, GET_FIRST_RESERVED_NAME(lv_active_exclusively_y), private);
  }

--
2.38.1


