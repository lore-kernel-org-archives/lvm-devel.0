From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 12:28:33 +0000 (UTC)
Subject: master - cleanup: config_settings.h: add some comments
Message-ID: <20150430122833.8DBFE6025E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25e7178e5955231295cf96de06ef9717fa029013
Commit:        25e7178e5955231295cf96de06ef9717fa029013
Parent:        d2c2718c11dc834a79a76acf34d76902daac5752
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 14:28:26 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 14:28:26 2015 +0200

cleanup: config_settings.h: add some comments

---
 lib/config/config_settings.h |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index aaaa3a3..f03ec09 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -18,10 +18,14 @@
  *   cfg_section(id, name, parent, flags, since_version, comment)
  *
  * - define a configuration setting of simple type:
- *   cfg(id, name, parent, flags, type, default_value, since_version, comment)
+ *   cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_default_value, comment)
  *
  * - define a configuration array of one or more types:
- *   cfg_array(id, name, parent, flags, types, default_value, since_version, comment)
+ *   cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_default_value, comment)
+ *
+ * The unconfigured_default_value is used as a default value which is
+ * in "@...@" form and which is then substitued with concrete value while
+ * running configure (see also 'lvmconfig --type default --unconfigured').
  *
  * If default value can't be assigned statically because it depends on some
  * run-time checks or if it depends on other settings already defined,


