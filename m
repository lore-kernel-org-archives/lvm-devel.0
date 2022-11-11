From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 Nov 2022 19:39:02 +0000 (GMT)
Subject: main - report: adjust lv_active_remotely for shared VGs
Message-ID: <20221111193902.0BF663858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=779fc3c0453d4a1abdfc62db740517467dbaf0e3
Commit:        779fc3c0453d4a1abdfc62db740517467dbaf0e3
Parent:        c77384785d3bd3d0c265220395dc392b52e62218
Author:        corubba <corubba@gmx.de>
AuthorDate:    Tue Nov 1 22:18:19 2022 +0100
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 11 12:08:59 2022 -0600

report: adjust lv_active_remotely for shared VGs

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

