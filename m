From: David Teigland <teigland@sourceware.org>
Date: Fri, 6 Dec 2019 17:25:01 -0500
Subject: master - update option description for settings
Message-ID: <05452.119120617245600691@us-mta-191.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3f381784f2726edda1ebfe806ba7d0b0dee33cdb
Commit:        3f381784f2726edda1ebfe806ba7d0b0dee33cdb
Parent:        ec71df6fec481b688a7c4db3171a451c18dbdc52
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 6 16:21:26 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Dec 6 16:21:26 2019 -0600

update option description for settings

---
 tools/args.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 533cc54..e0bd42a 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -463,7 +463,8 @@ arg(setphysicalvolumesize_ARG, '\0', "setphysicalvolumesize", sizemb_VAL, 0, 0,
 
 arg(settings_ARG, '\0', "settings", string_VAL, ARG_GROUPABLE, 0,
     "Specifies command specific settings in \"Key = Value\" form.\n"
-    "Repeat this option to specify multiple values.\n")
+    "Combine multiple settings in quotes, or repeat the settings\n"
+    "option for each.\n")
 
 arg(poll_ARG, '\0', "poll", bool_VAL, 0, 0,
     "When yes, start the background transformation of an LV.\n"



