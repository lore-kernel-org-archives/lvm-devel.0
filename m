From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  1 Jul 2015 06:20:25 +0000 (UTC)
Subject: master - config: report/time_format appeared in v2.02.123
Message-ID: <20150701062025.1FF2261115@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a69ded43b0364812c58eb9479c2dae4dd2febc8c
Commit:        a69ded43b0364812c58eb9479c2dae4dd2febc8c
Parent:        4c629a5257bda5a309df25809f821a8ce1dac3e4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 1 08:19:40 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 1 08:20:20 2015 +0200

config: report/time_format appeared in v2.02.123

---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index cac1978..68f593d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1357,7 +1357,7 @@ cfg(report_binary_values_as_numeric_CFG, "binary_values_as_numeric", report_CFG_
 	"(not counting the 'unknown' value which denotes that the\n"
 	"value could not be determined).\n")
 
-cfg(report_time_format_CFG, "time_format", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_TIME_FORMAT, vsn(2, 2, 121), NULL, 0, NULL,
+cfg(report_time_format_CFG, "time_format", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_TIME_FORMAT, vsn(2, 2, 123), NULL, 0, NULL,
         "Set time format for fields reporting time values.\n"
 	"Format specification is a string which may contain special character\n"
 	"sequences and ordinary character sequences. Ordinary character sequences\n"


