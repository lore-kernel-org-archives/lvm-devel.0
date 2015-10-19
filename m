From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 19 Oct 2015 07:59:20 +0000 (UTC)
Subject: master - cleanup: typo in comment: compact_output_fields should be compact-output_cols
Message-ID: <20151019075920.B248B60BDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23d9b17a7b06d8e6f89b2c3e9ef9f59462436458
Commit:        23d9b17a7b06d8e6f89b2c3e9ef9f59462436458
Parent:        c3bfe07f2ad393963af5b7138bccc622e6561c8f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 19 09:59:05 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 19 09:59:05 2015 +0200

cleanup: typo in comment: compact_output_fields should be compact-output_cols

---
 conf/example.conf.in         |    2 +-
 lib/config/config_settings.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index e1afed6..dddede0 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1505,7 +1505,7 @@ activation {
 	# Do not print empty values for given report fields.
 	# The same as compact_output setting, but the compaction is not done
 	# globally for all fields in report but only for given fields. If both
-	# compact_output and compact_output_fields is used at the same time,
+	# compact_output and compact_output_cols is used at the same time,
 	# the compact_output setting prevails.
 	# This configuration option has an automatic default value.
 	# compact_output_cols = ""
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index cefc579..1a261a2 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1425,7 +1425,7 @@ cfg(report_compact_output_cols_CFG, "compact_output_cols", report_CFG_SECTION, C
 	"Do not print empty values for given report fields.\n"
 	"The same as compact_output setting, but the compaction is not done\n"
 	"globally for all fields in report but only for given fields. If both\n"
-	"compact_output and compact_output_fields is used at the same time,\n"
+	"compact_output and compact_output_cols is used at the same time,\n"
 	"the compact_output setting prevails.\n")
 
 cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL, 0, NULL,


