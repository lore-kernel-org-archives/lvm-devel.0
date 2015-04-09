From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  9 Apr 2015 21:11:15 +0000 (UTC)
Subject: master - config: update description
Message-ID: <20150409211115.212E66004F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=303c5ba803cbfe81b1bc92cc2b2e9aa0970b21d2
Commit:        303c5ba803cbfe81b1bc92cc2b2e9aa0970b21d2
Parent:        6f3f421228754b1758f909eabcedfd30f4d9780a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 9 16:09:53 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 9 16:09:53 2015 -0500

config: update description

Remove examples that simply replicate the default shown.
---
 lib/config/config_settings.h |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 19ec279..d76ed0f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -333,10 +333,7 @@ cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT
 	"Minimum size (in KB) of block devices which can be used as PVs.\n"
 	"In a clustered environment all nodes must use the same value.\n"
 	"Any value smaller than 512KB is ignored.\n"
-	"The original built-in setting was 512 up to and including version 2.02.84.\n"
-	"Example:\n"
-	"Ignore devices smaller than 2MB such as floppy drives:\n"
-	"pv_min_size = 2048\n")
+	"The original built-in setting was 512 up to and including version 2.02.84.\n")
 
 cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85),
 	"Issue discards to a logical volumes's underlying physical volume(s) when\n"
@@ -772,9 +769,7 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 	"option -q is for quiet output.\n"
 	"With thin_check version 2.1 or newer you can add --ignore-non-fatal-errors\n"
 	"to let it pass through ignorable errors and fix them later.\n"
-	"With thin_check version 3.2 or newer you should add --clear-needs-check-flag.\n"
-	"Example:\n"
-	"thin_check_options = [ \"-q\", \"--clear-needs-check-flag\" ]\n")
+	"With thin_check version 3.2 or newer you should add --clear-needs-check-flag.\n")
 
 cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99),
 	"The specified features are not used by thin driver.\n"


