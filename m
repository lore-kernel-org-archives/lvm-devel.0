From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:41 +0000 (UTC)
Subject: master - libdm: report: add dm_report_destroy_rows
Message-ID: <20160809173941.929F36023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c2113928430e25a4cc7b68a94aca7d8388b3b60
Commit:        9c2113928430e25a4cc7b68a94aca7d8388b3b60
Parent:        5649834f7d62b9cba3b06c1b5d0dd425978f3ad2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 09:42:33 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:24:45 2016 +0200

libdm: report: add dm_report_destroy_rows

Calling dm_report_destroy_rows makes it possible to destroy any report
content we have but at the same time it doesn't destroy the report
handle itself, thus it's possible to reuse that handle again for new
report content.

Functionally, this is the same as calling dm_report_output with the
report handle but omitting the output iself. This functionality may
be useful if we, for whatever reason, need to discard the report
content and start a fresh new one but with the same report configuration
and initialization and thus we can just reuse the existing handle.
---
 libdm/.exported_symbols.DM_1_02_133 |    1 +
 libdm/libdevmapper.h                |    5 +++++
 libdm/libdm-report.c                |    5 +++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_133 b/libdm/.exported_symbols.DM_1_02_133
new file mode 100644
index 0000000..4318f80
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_133
@@ -0,0 +1 @@
+dm_report_destroy_rows
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 2270016..844a455 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2907,6 +2907,11 @@ int dm_report_compact_given_fields(struct dm_report *rh, const char *fields);
  */
 int dm_report_is_empty(struct dm_report *rh);
 
+/*
+ * Destroy report content without doing output.
+ */
+void dm_report_destroy_rows(struct dm_report *rh);
+
 int dm_report_output(struct dm_report *rh);
 
 /*
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 02fead5..886d8a2 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4790,6 +4790,11 @@ out:
 	return r;
 }
 
+void dm_report_destroy_rows(struct dm_report *rh)
+{
+	_destroy_rows(rh);
+}
+
 static int _report_group_create_single(struct dm_report_group *group)
 {
 	return 1;


