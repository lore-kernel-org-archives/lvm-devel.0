From: corubba <corubba@gmx.de>
Date: Thu, 27 Oct 2022 03:17:16 +0200
Subject: [PATCH 1/2] report: adjust lv_active_remotely for shared VGs
In-Reply-To: <752e9d7d-028d-270c-9024-f50feadc2d5a@gmx.de>
References: <752e9d7d-028d-270c-9024-f50feadc2d5a@gmx.de>
Message-ID: <9112f76c-2be4-1d28-4fc9-3b23500c7040@gmx.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a note to the manpage that lvmlockd is unable to determine
accurately and without side-effects whether a LV is remotely active.
Also change the value of the lv_active_remotely option from false to
undefined for shared VGs to distinctly communicate that inability to
users. Only for local VGs it can be definitely stated that they are not
remotely active.

Signed-off-by: corubba <corubba@gmx.de>
---
  lib/report/report.c | 3 ++-
  man/lvmlockd.8_main | 4 ++++
  2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 9172c1f0e..cb5fc93c8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3838,9 +3838,10 @@ static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
  				  struct dm_report_field *field,
  				  const void *data, void *private)
  {
+	const struct logical_volume *lv = (const struct logical_volume *) data;
  	int active_remotely;

-	if (!activation())
+	if (!activation() || vg_is_shared(lv->vg))
  		return _binary_undef_disp(rh, mem, field, private);

  	active_remotely = 0;
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 717292dc6..7fa11df54 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -878,6 +878,10 @@ If lvmlockd fails or is killed while in use, locks it held remain but are
  orphaned in the lock manager.  lvmlockd can be restarted with an option to
  adopt the orphan locks from the previous instance of lvmlockd.
  .
+.IP \[bu]
+The 'lvs' command does not report any remote state, because lvmlockd is
+unable to passively check the remote active or lock state of an LV.
+.
  .SH SEE ALSO
  .
  .BR lvm (8),
--
2.38.1

