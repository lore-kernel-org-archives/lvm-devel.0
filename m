From: David Teigland <teigland@sourceware.org>
Date: Mon, 8 Apr 2019 11:39:34 -0400
Subject: master - pvscan: for init only autoactivate vg for named dev
Message-ID: <201904081539.x38FdYMF022997@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b89c0d4b78d11b50328a6df73234524699eabb1
Commit:        6b89c0d4b78d11b50328a6df73234524699eabb1
Parent:        417724efe260723889ca4013dd7fff80bb5375c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 26 16:39:43 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 5 12:46:39 2019 -0500

pvscan: for init only autoactivate vg for named dev

When pvscan is run for the initialization case (the first
pvscan run on the system), it scans all devs and creates
online files for all PVs it finds.  Previously it would
then autoactivate every complete VG, but change this to
only autoactive the (complete) VG corresponding to the
named device arg(s).
---
 tools/pvscan.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index f0944cd..74e0b96 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1066,9 +1066,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	if (_online_pvid_files_missing()) {
 		log_verbose("pvscan all devices to initialize available PVs.");
-		_online_files_remove(_pvs_online_dir);
-		_online_files_remove(_vgs_online_dir);
-		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
+		_online_pvscan_all_devs(cmd, complete_vgnames, &add_devs);
 		_unlock_online();
 		goto activate;
 	}


