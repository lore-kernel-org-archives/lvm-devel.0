From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 31 Mar 2017 11:12:54 -0400
Subject: master - cache: scan kallsyms for kernel symbols
Message-ID: <201703311512.v2VFCskw008477@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=970df59f914733b9ade15d9cb48e758b08140d42
Commit:        970df59f914733b9ade15d9cb48e758b08140d42
Parent:        13ca11cc1472fe5689e63555780acfb40cb3bcd9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 31 17:07:21 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 31 17:12:00 2017 +0200

cache: scan kallsyms for kernel symbols

With monolithic kernels we can't actually modprobe
for cache modules as they are already compiled-in
and policy modules do not export version symbol.

Reported issue on list:
https://www.redhat.com/archives/dm-devel/2017-March/msg00061.html

Fix will try to look for explicit kernel symbols first before
calling modprobe.
---
 lib/cache_segtype/cache.c |   45 ++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 55b4c6e..da23dae 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -258,6 +258,39 @@ static void _destroy(struct segment_type *segtype)
 }
 
 #ifdef DEVMAPPER_SUPPORT
+/*
+ * Parse and look for kernel symbol in /proc/kallsyms
+ * this could be our only change to figure out there is
+ * cache policy symbol already in the monolithic kernel
+ * where 'modprobe dm-cache-smq' will simply not work
+ */
+static int _lookup_kallsyms(const char *symbol)
+{
+	static const char _syms[] = "/proc/kallsyms";
+	int ret = 0;
+	char *line = NULL;
+	size_t len;
+	FILE *s;
+
+	if (!(s = fopen(_syms, "r")))
+		log_sys_debug("fopen", _syms);
+	else {
+		while (getline(&line, &len, s) != -1)
+			if (strstr(line, symbol)) {
+				ret = 1; /* Found symbol */
+				log_debug("Found kernel symbol%s.", symbol); /* space is in symbol */
+				break;
+			}
+
+		free(line);
+		if (fclose(s))
+			log_sys_debug("fclose", _syms);
+	}
+
+	return ret;
+}
+
+
 static int _target_present(struct cmd_context *cmd,
 			   const struct lv_segment *seg __attribute__((unused)),
 			   unsigned *attributes __attribute__((unused)))
@@ -270,14 +303,15 @@ static int _target_present(struct cmd_context *cmd,
 		unsigned cache_alias;
 		const char feature[12];
 		const char module[12]; /* check dm-%s */
+		const char ksymbol[12]; /* check for kernel symbol */
 		const char *aliasing;
 	} _features[] = {
-		/* Assumption: cache >=1.9 always aliases MQ policy */
 		{ 1, 10, CACHE_FEATURE_METADATA2, 0, "metadata2" },
+		/* Assumption: cache >=1.9 always aliases MQ policy */
 		{ 1, 9, CACHE_FEATURE_POLICY_SMQ, CACHE_FEATURE_POLICY_MQ, "policy_smq", "cache-smq",
-		" and aliases cache-mq" },
-		{ 1, 8, CACHE_FEATURE_POLICY_SMQ, 0, "policy_smq", "cache-smq" },
-		{ 1, 3, CACHE_FEATURE_POLICY_MQ, 0, "policy_mq", "cache-mq" },
+		 " smq_exit", " and aliases cache-mq" },
+		{ 1, 8, CACHE_FEATURE_POLICY_SMQ, 0, "policy_smq", "cache-smq", " smq_exit" },
+		{ 1, 3, CACHE_FEATURE_POLICY_MQ, 0, "policy_mq", "cache-mq", " mq_init" },
 	};
 	static const char _lvmconf[] = "global/cache_disabled_features";
 	static unsigned _attrs = 0;
@@ -323,7 +357,8 @@ static int _target_present(struct cmd_context *cmd,
 			}
 			if (((maj > _features[i].maj) ||
 			     (maj == _features[i].maj && min >= _features[i].min)) &&
-			    module_present(cmd, _features[i].module)) {
+			    ((_features[i].ksymbol[0] && _lookup_kallsyms(_features[i].ksymbol)) ||
+			     module_present(cmd, _features[i].module))) {
 				log_debug_activation("Cache policy %s is available%s.",
 						     _features[i].module,
 						     _features[i].aliasing ? : "");


