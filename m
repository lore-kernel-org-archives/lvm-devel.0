From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Aug 2016 08:38:49 +0000 (UTC)
Subject: master - conf: add comment about cfg_runtime
Message-ID: <20160815083849.D1F6461052@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ff893cd854733de0c9e82edc9e57f55c3d9ce7a
Commit:        2ff893cd854733de0c9e82edc9e57f55c3d9ce7a
Parent:        9c9b9b276a35dcc6dce8e6a19e7afc01eef451a7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 15 10:38:38 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 15 10:38:38 2016 +0200

conf: add comment about cfg_runtime

---
 lib/config/config_settings.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1084224..fa6a01e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -23,6 +23,11 @@
  * - define a configuration array of one or more types:
  *   cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_default_value, deprecated_since_version, deprecation_comment, comment)
  *
+ * - define a configuration setting where the default value is evaluated in runtime
+ *   cfg_runtime(id, name, parent, flags, type, since_version, deprecated_since_version, deprecation_comment, comment)
+ *   (for each cfg_runtime, you need to define 'get_default_<name>(struct cmd_context *cmd, struct profile *profile)' function
+ *    to get the default value in runtime - usually, these functions are placed in config.[ch] file)
+ *
  *
  * If default value can't be assigned statically because it depends on some
  * run-time checks or if it depends on other settings already defined,


