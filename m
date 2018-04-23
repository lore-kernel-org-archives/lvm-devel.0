From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:29 -0400
Subject: master - lvmetad: fix process_each_label
Message-ID: <201804231355.w3NDtTiU001722@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e33bd1335ba91d6b978df3a39250987d3412116
Commit:        7e33bd1335ba91d6b978df3a39250987d3412116
Parent:        ddb5de7a98af5e354013a07c61e46636b9ec01e6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 6 11:22:18 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

lvmetad: fix process_each_label

Was missing the call to populate lvmcache info from lvmetad
at the start of process_each_label.
---
 tools/toollib.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b029a0d..c8dd9d3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1505,6 +1505,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LABEL);
 
 	lvmcache_label_scan(cmd);
+	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (argc) {
 		for (; opt < argc; opt++) {


