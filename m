From: David Teigland <teigland@sourceware.org>
Date: Fri, 18 May 2018 15:32:20 -0400
Subject: master - fullreport: fix with lvmetad and only orphan PVs are visible
Message-ID: <201805181932.w4IJWKbg026758@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc275bcddf3fac6ea691e2dfda0ca3531c4b3c0c
Commit:        bc275bcddf3fac6ea691e2dfda0ca3531c4b3c0c
Parent:        0253f5a21dc0b9ee8641228739d3d1036212ba80
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 18 14:26:32 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 18 14:31:52 2018 -0500

fullreport: fix with lvmetad and only orphan PVs are visible

The report uses process_each_vg() which populates lvmcache
based on a VG list from lvmetad.  If there are no VGs,
but only orphan PVs, the orphans are not shown.  Add an
explicit call to populate lvmcache with PV info from lvmetad.
---
 tools/reporter.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 98e3d12..2d83421 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1421,6 +1421,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 		return ECMD_FAILED;
 	}
 
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
 	if (single_args->report_type == FULL) {
 		handle->custom_handle = &args;
 		r = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 1, handle, &_full_report_single);


