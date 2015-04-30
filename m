From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 12:43:28 +0000 (UTC)
Subject: master - cleanup: config_settings.h: comments
Message-ID: <20150430124328.A04CB60D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c39d635b62aa4f27e3f9ff31f171e501bb8a874
Commit:        9c39d635b62aa4f27e3f9ff31f171e501bb8a874
Parent:        25e7178e5955231295cf96de06ef9717fa029013
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 14:43:08 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 14:43:08 2015 +0200

cleanup: config_settings.h: comments

---
 lib/config/config_settings.h |   94 ++++++++++++++++++++++++------------------
 1 files changed, 54 insertions(+), 40 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f03ec09..b496071 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -23,10 +23,7 @@
  * - define a configuration array of one or more types:
  *   cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_default_value, comment)
  *
- * The unconfigured_default_value is used as a default value which is
- * in "@...@" form and which is then substitued with concrete value while
- * running configure (see also 'lvmconfig --type default --unconfigured').
- *
+*
  * If default value can't be assigned statically because it depends on some
  * run-time checks or if it depends on other settings already defined,
  * the configuration setting  or array can be defined with the
@@ -36,42 +33,59 @@
  *
  *
  * VARIABLES:
- * id:			unique identifier
- * name:		configuration node name
- * parent:		id of parent configuration node
- * flags:		configuration item flags:
- * 				CFG_NAME_VARIABLE - configuration node name is variable
- * 				CFG_ALLOW_EMPTY - node value can be emtpy
- * 				CFG_ADVANCED - this node belongs to advanced config set
- * 				CFG_UNSUPPORTED - this node is not officially supported and it's used primarily by developers
- * 				CFG_PROFILABLE - this node is customizable by a profile
- * 				CFG_PROFILABLE_METADATA - profilable and attachable to VG/LV metadata
- * 				CFG_DEFAULT_UNDEFINED - node's default value is undefined
- * 				CFG_DISABLED - configuration is disabled (defaults always used)
- * type:		allowed type for the value of simple configuation setting, one of:
- * 				CFG_TYPE_BOOL
- * 				CFG_TYPE_INT
- * 				CFG_TYPE_FLOAT
- * 				CFG_TYPE_STRING
- * types:		allowed types for the values of array configuration setting
- * 			(use logical "OR" to define more than one allowed type,
- * 			 e.g. CFG_TYPE_STRING | CFG_TYPE_INT)
- * default_value:	default value of type 'type' for the configuration node,
- * 			if this is an array with several 'types' defined then
- * 			default value is a string where each string representation
- * 			of each value is prefixed by '#X' where X is one of:
- *				'B' for boolean value
- * 				'I' for integer value
- * 				'F' for float value
- * 				'S' for string value
- * 				'#' for the '#' character itself
- * 			For example, "#Sfd#I16" means default value [ "fd", 16 ].
- * comment:		brief comment used in configuration dumps
- * since_version:	the version this configuration node first appeared in (be sure
- *			that parent nodes are consistent with versioning, no check done
- *			if parent node is older or the same age as any child node!)
- *			Use "vsn" macro to translate the "major.minor.release" version
- *			into a single number that is being stored internally in memory.
+ * 
+ * id:                         Unique identifier.
+ *
+ * name:                       Configuration node name.
+ *
+ * parent:                     Id of parent configuration node.
+ *
+ * flags:                      Configuration item flags:
+ *                                 CFG_NAME_VARIABLE - configuration node name is variable
+ *                                 CFG_ALLOW_EMPTY - node value can be emtpy
+ *                                 CFG_ADVANCED - this node belongs to advanced config set
+ *                                 CFG_UNSUPPORTED - this node is not officially supported and it's used primarily by developers
+ *                                 CFG_PROFILABLE - this node is customizable by a profile
+ *                                 CFG_PROFILABLE_METADATA - profilable and attachable to VG/LV metadata
+ *                                 CFG_DEFAULT_UNDEFINED - node's default value is undefined
+ *                                 CFG_DISABLED - configuration is disabled (defaults always used)
+ *
+ * type:		       Allowed type for the value of simple configuation setting, one of:
+ *                                 CFG_TYPE_BOOL
+ *                                 CFG_TYPE_INT
+ *                                 CFG_TYPE_FLOAT
+ *                                 CFG_TYPE_STRING
+ *
+ * types:                      Allowed types for the values of array configuration setting
+ *                             (use logical "OR" to define more than one allowed type,
+ *                             e.g. CFG_TYPE_STRING | CFG_TYPE_INT).
+ *
+ * default_value:              Default value of type 'type' for the configuration node,
+ *                             if this is an array with several 'types' defined then
+ *                             default value is a string where each string representation
+ *                             of each value is prefixed by '#X' where X is one of:
+ *                                 'B' for boolean value
+ *                                 'I' for integer value
+ *                                 'F' for float value
+ *                                 'S' for string value
+ *                                 '#' for the '#' character itself
+ *                             For example, "#Sfd#I16" means default value [ "fd", 16 ].
+ *
+ * since_version:              The version this configuration node first appeared in (be sure
+ *                             that parent nodes are consistent with versioning, no check done
+ *                             if parent node is older or the same age as any child node!)
+ *                             Use "vsn" macro to translate the "major.minor.release" version
+ *                             into a single number that is being stored internally in memory.
+ *                             (see also lvmconfig ... --withversions)
+ *
+ * unconfigured_default_value: Unconfigured default value used as a default value which is
+ *                             in "@...@" form and which is then substitued with concrete value
+ *                             while running configure.
+ *                             (see also 'lvmconfig --type default --unconfigured')
+ *
+ * comment:                    Comment used in configuration dumps. The very first line is the
+ *                             summarizing comment.
+ *                             (see also lvmconfig ... --withcomments and --withsummary)
  */
 #include "defaults.h"
 


