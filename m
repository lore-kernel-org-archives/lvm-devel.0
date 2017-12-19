From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 19 Dec 2017 09:32:19 -0500
Subject: master - lvm-string: add function to detect component LV suffix
Message-ID: <201712191432.vBJEWJPS018828@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a841515af623b86be0628ef6568ff74009ea643
Commit:        3a841515af623b86be0628ef6568ff74009ea643
Parent:        17649d4ac8d4c7d10bf58feefa5f1faae89713ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 11 18:12:47 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 19 15:28:07 2017 +0100

lvm-string: add function to detect component LV suffix

Add is_component_lvname() function to recognize component LV name.
---
 lib/misc/lvm-string.c |   30 +++++++++++++++++++++++++++---
 lib/misc/lvm-string.h |    1 +
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index cdcc993..a2098fd 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -150,22 +150,41 @@ static const char *_lvname_has_reserved_prefix(const char *lvname)
 	return NULL;
 }
 
-static const char *_lvname_has_reserved_string(const char *lvname)
+static const char *_lvname_has_reserved_component_string(const char *lvname)
 {
 	static const char _strings[][12] = {
+		/* Suffixes for compoment LVs */
 		"_cdata",
 		"_cmeta",
 		"_corig",
 		"_mimage",
 		"_mlog",
-		"_pmspare",
 		"_rimage",
 		"_rmeta",
 		"_tdata",
-		"_tmeta",
+		"_tmeta"
+	};
+	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_strings); ++i)
+		if (strstr(lvname, _strings[i]))
+			return _strings[i];
+
+	return NULL;
+}
+
+static const char *_lvname_has_reserved_string(const char *lvname)
+{
+	static const char _strings[][12] = {
+		/* Additional suffixes for non-compoment LVs */
+		"_pmspare",
 		"_vorigin"
 	};
 	unsigned i;
+	const char *cs;
+
+	if ((cs = _lvname_has_reserved_component_string(lvname)))
+		return cs;
 
 	for (i = 0; i < DM_ARRAY_SIZE(_strings); ++i)
 		if (strstr(lvname, _strings[i]))
@@ -208,6 +227,11 @@ int is_reserved_lvname(const char *name)
 		_lvname_has_reserved_string(name)) ? 1 : 0;
 }
 
+int is_component_lvname(const char *name)
+{
+	return (_lvname_has_reserved_component_string(name)) ? 1 : 0;
+}
+
 char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		    const char *layer)
 {
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index ebdf956..4e7404a 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -47,6 +47,7 @@ int validate_tag(const char *n);
 void copy_systemid_chars(const char *src, char *dst);
 
 int apply_lvname_restrictions(const char *name);
+int is_component_lvname(const char *name);
 int is_reserved_lvname(const char *name);
 
 /*


