From: David Teigland <teigland@sourceware.org>
Date: Wed, 7 Aug 2019 12:09:06 -0400
Subject: master - config: set deprecated version for segment_libraries
Message-ID: <201908071609.x77G96HC016762@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=682b6216dfa49444145df2e21d3aab1edf584d20
Commit:        682b6216dfa49444145df2e21d3aab1edf584d20
Parent:        3a0d493d918510d863ddbdbc63d8a8ccb6ca2dd9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 5 13:31:59 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 7 11:08:11 2019 -0500

config: set deprecated version for segment_libraries

Stopped being used some time ago.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index edfe4a3..2bb72ba 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -948,7 +948,7 @@ cfg(global_format_CFG, "format", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_
 cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
 	"This setting is no longer used.")
 
-cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL, NULL)
+cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, vsn(2, 3, 3), NULL, NULL)
 
 cfg(global_proc_CFG, "proc", global_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL, 0, NULL,
 	"Location of proc filesystem.\n")


