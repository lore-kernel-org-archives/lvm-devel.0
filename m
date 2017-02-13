From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:45 +0000 (UTC)
Subject: master - args: split is a synonym for splitcache
Message-ID: <20170213181045.A3C60601DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f067c0ad78cc894a2d620c38af4d74b679d5c316
Commit:        f067c0ad78cc894a2d620c38af4d74b679d5c316
Parent:        c3e1838382122e254aaf9bda6159bc5e95303309
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 19 13:47:24 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

args: split is a synonym for splitcache

also tidy the other synonyms
---
 tools/args.h           |   59 +++++++++++++++++++++--------------------------
 tools/command-lines.in |    1 +
 tools/lvmcmdline.c     |    4 +++
 3 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 8802cd7..1d7d6f7 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -133,9 +133,6 @@ arg(configreport_ARG, '\0', "configreport", configreport_VAL, ARG_GROUPABLE, 1,
 arg(configtype_ARG, '\0', "typeconfig", configtype_VAL, 0, 0,
     "See lvmreport(7).\n")
 
-arg(corelog_ARG, '\0', "corelog", 0, 0, 0,
-    "An alias for --mirrorlog core.\n")
-
 arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0,
     "Align the start of the data to a multiple of this number.\n"
     "Also specify an appropriate Physical Extent size when creating a VG.\n"
@@ -288,10 +285,6 @@ arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0,
     "cascade is displayed.\n"
     "See lvm.conf(5) for more information about config.\n")
 
-arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_VAL, 0, 0,
-    "For commands starting with 'pv', this is an alias for --pvmetadatacopies.\n"
-    "For commands starting with 'vg', this is an alias for --vgmetadatacopies.\n")
-
 arg(metadataignore_ARG, '\0', "metadataignore", bool_VAL, 0, 0,
     "Specifies the metadataignore property of a PV.\n"
     "If yes, metadata areas on the PV are ignored, and lvm will\n"
@@ -440,24 +433,6 @@ arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", pvmetadatacopies_VAL, 0, 0,
     "This may be useful in VGs containing many PVs (this places limitations\n"
     "on the ability to use vgsplit later.)\n")
 
-arg(raidrebuild_ARG, '\0', "raidrebuild", pv_VAL, ARG_GROUPABLE, 0,
-    "An alias for --rebuild.\n")
-
-arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", sizekb_VAL, 0, 0,
-    "An alias for --maxrecoveryrate.\n")
-
-arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", sizekb_VAL, 0, 0,
-    "An alias for --minrecoveryrate.\n")
-
-arg(raidsyncaction_ARG, '\0', "raidsyncaction", syncaction_VAL, 0, 0,
-    "An alias for --syncaction.\n")
-
-arg(raidwritebehind_ARG, '\0', "raidwritebehind", number_VAL, 0, 0,
-    "An alias for --writebehind.\n")
-
-arg(raidwritemostly_ARG, '\0', "raidwritemostly", writemostly_VAL, ARG_GROUPABLE, 0,
-    "An alias for --writemostly.\n")
-
 arg(readonly_ARG, '\0', "readonly", 0, 0, 0,
     "Run the command in a special read-only mode which will read on-disk\n"
     "metadata without needing to take any locks. This can be used to peek\n"
@@ -571,9 +546,6 @@ arg(sinceversion_ARG, '\0', "sinceversion", string_VAL, 0, 0,
     "This option is currently applicable only with --type new\n"
     "to display all configuration settings introduced since given version.\n")
 
-/* Not used */
-arg(split_ARG, '\0', "split", 0, 0, 0, NULL)
-
 arg(splitcache_ARG, '\0', "splitcache", 0, 0, 0,
     "Separates a cache pool from a cache LV, and keeps the unused cache pool LV.\n"
     "Before the separation, the cache is flushed. Also see --uncache.\n")
@@ -732,9 +704,6 @@ arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", vgmetadatacopies_VAL, 0, 0,
     "\\fBall\\fP causes LVM to first clear the metadataignore flags on\n"
     "all PVs, and then to become unmanaged.\n")
 
-arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", sizemb_VAL, 0, 0,
-    "An alias for --virtualsize.\n")
-
 arg(withsummary_ARG, '\0', "withsummary", 0, 0, 0,
     "Display a one line comment for each configuration node.\n")
 
@@ -768,10 +737,34 @@ arg(writemostly_ARG, '\0', "writemostly", writemostly_VAL, ARG_GROUPABLE, 0,
     "the suffix \\fB:t\\fP. Repeat this option to change the attribute on\n"
     "multiple PVs.\n")
 
-/* Allow some variations */
+/*
+ * Synonyms of other options.
+ *
+ * Only the standard option names are used in command definitions.
+ *
+ * If used on the command line, lvm automatically translates them
+ * to the standard option name.
+ *
+ * The generated help and man output does not include
+ * these variants.  The description of the standard option names
+ * can mention a synonym, or in some cases the man page generation
+ * recognizes some of these and prints the option name to include
+ * the variant, e.g. man page generation prints --[raid]writebehind.
+ */
+arg(corelog_ARG, '\0', "corelog", 0, 0, 0, NULL)
+arg(resizable_ARG, '\0', "resizable", bool_VAL, 0, 0, NULL)
 arg(allocation_ARG, '\0', "allocation", bool_VAL, 0, 0, NULL)
 arg(available_ARG, '\0', "available", activation_VAL, 0, 0, NULL)
-arg(resizable_ARG, '\0', "resizable", bool_VAL, 0, 0, NULL)
+arg(raidrebuild_ARG, '\0', "raidrebuild", pv_VAL, ARG_GROUPABLE, 0, NULL)
+arg(raidsyncaction_ARG, '\0', "raidsyncaction", syncaction_VAL, 0, 0, NULL)
+arg(raidwritemostly_ARG, '\0', "raidwritemostly", writemostly_VAL, ARG_GROUPABLE, 0, NULL)
+arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", sizekb_VAL, 0, 0, NULL)
+arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", sizekb_VAL, 0, 0, NULL)
+arg(raidwritebehind_ARG, '\0', "raidwritebehind", number_VAL, 0, 0, NULL)
+arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", sizemb_VAL, 0, 0, NULL)
+arg(split_ARG, '\0', "split", 0, 0, 0, NULL)
+arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_VAL, 0, 0, NULL)
+
 
 /*
  * ... and now the short args.
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 81c70ba..4cc51fe 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -106,6 +106,7 @@
 # maxrecoveryrate (raidmaxrecoveryrate)
 # writebehind (raidwritebehind)
 # virtualsize (virtualoriginsize)
+# splitcache (split)
 # vgmetadatacopies (metadatacopies)
 # pvmetadatacopies (metadatacopies)
 #
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index dda4b16..4039dd9 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -940,6 +940,8 @@ static int _opt_standard_to_synonym(const char *cmd_name, int opt)
 		return raidwritebehind_ARG;
 	case virtualsize_ARG:
 		return virtualoriginsize_ARG;
+	case splitcache_ARG:
+		return split_ARG;
 	case pvmetadatacopies_ARG:
 		if (!strncmp(cmd_name, "pv", 2))
 			return metadatacopies_ARG;
@@ -977,6 +979,8 @@ static int _opt_synonym_to_standard(const char *cmd_name, int opt)
 		return writebehind_ARG;
 	case virtualoriginsize_ARG:
 		return virtualsize_ARG;
+	case split_ARG:
+		return splitcache_ARG;
 	case metadatacopies_ARG:
 		if (!strncmp(cmd_name, "pv", 2))
 			return pvmetadatacopies_ARG;


