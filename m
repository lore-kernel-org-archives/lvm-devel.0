From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 May 2019 09:18:12 -0400
Subject: master - metadata: allow reading metadata with invalid creation_time
Message-ID: <201905101318.x4ADICFq032747@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85dbcda1503eef81be11947be8b9abb0b8c41c9c
Commit:        85dbcda1503eef81be11947be8b9abb0b8c41c9c
Parent:        1f7c9da554fdb9069bc46e973678e055a491ea1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 10 14:40:11 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 10 14:40:11 2019 +0200

metadata: allow reading metadata with invalid creation_time

lvm2 till version 2.02.169 (commit 78d004efa8a1809cea68283e6204edfa9d7c1091)
was printing invalid creation_time argument into metadata on 32bit arch.

However with commit ba9820b14223b731125c83dbc9709aa44fdcdbf1 we started
to properly validate all input numbers and thus we refused to accept
invalid metadata with 'garbage' string - but this results in the
situation where metadata produced on older lvm2 on 32 bit architecture
will become unreadable after upgrade.

To fix this case - extend libdm parser in a way, that whenever we
find error integer value, we also check if the parsed value is not for
creation_time node and in this case we let the metadata pass through
with made-up date 2018-05-24 (release date of 2.02.169).
---
 device_mapper/libdm-config.c |   18 +++++++++++++++---
 libdm/libdm-config.c         |   18 +++++++++++++++---
 2 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/device_mapper/libdm-config.c b/device_mapper/libdm-config.c
index 0928843..d2ac43c 100644
--- a/device_mapper/libdm-config.c
+++ b/device_mapper/libdm-config.c
@@ -51,6 +51,8 @@ struct parser {
 
 	struct dm_pool *mem;
 	int no_dup_node_check;	/* whether to disable dup node checking */
+	const char *key;        /* last obtained key */
+	unsigned ignored_creation_time;
 };
 
 struct config_output {
@@ -176,7 +178,7 @@ static int _do_dm_config_parse(struct dm_config_tree *cft, const char *start, co
 	/* TODO? if (start == end) return 1; */
 
 	struct parser *p;
-	if (!(p = dm_pool_alloc(cft->mem, sizeof(*p))))
+	if (!(p = dm_pool_zalloc(cft->mem, sizeof(*p))))
 		return_0;
 
 	p->mem = cft->mem;
@@ -615,6 +617,7 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 		match(TOK_SECTION_E);
 	} else {
 		match(TOK_EQ);
+		p->key = root->key;
 		if (!(value = _value(p)))
 			return_NULL;
 		if (root->v)
@@ -682,8 +685,17 @@ static struct dm_config_value *_type(struct parser *p)
 		errno = 0;
 		v->v.i = strtoll(p->tb, NULL, 0);	/* FIXME: check error */
 		if (errno) {
-			log_error("Failed to read int token.");
-			return NULL;
+			if (errno == ERANGE && p->key &&
+			    strcmp("creation_time", p->key) == 0) {
+				/* Due to a bug in some older 32bit builds (<2.02.169),
+				 * lvm was able to produce invalid creation_time string */
+				v->v.i = 1527120000; /* Pick 2018-05-24 day instead */
+				if (!p->ignored_creation_time++)
+					log_warn("WARNING: Invalid creation_time found in metadata (repaired with next metadata update).");
+			} else {
+				log_error("Failed to read int token.");
+				return NULL;
+			}
 		}
 		match(TOK_INT);
 		break;
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 3666fc9..6edeee2 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -51,6 +51,8 @@ struct parser {
 
 	struct dm_pool *mem;
 	int no_dup_node_check;	/* whether to disable dup node checking */
+	const char *key;        /* last obtained key */
+	unsigned ignored_creation_time;
 };
 
 struct config_output {
@@ -176,7 +178,7 @@ static int _do_dm_config_parse(struct dm_config_tree *cft, const char *start, co
 	/* TODO? if (start == end) return 1; */
 
 	struct parser *p;
-	if (!(p = dm_pool_alloc(cft->mem, sizeof(*p))))
+	if (!(p = dm_pool_zalloc(cft->mem, sizeof(*p))))
 		return_0;
 
 	p->mem = cft->mem;
@@ -615,6 +617,7 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 		match(TOK_SECTION_E);
 	} else {
 		match(TOK_EQ);
+		p->key = root->key;
 		if (!(value = _value(p)))
 			return_NULL;
 		if (root->v)
@@ -682,8 +685,17 @@ static struct dm_config_value *_type(struct parser *p)
 		errno = 0;
 		v->v.i = strtoll(p->tb, NULL, 0);	/* FIXME: check error */
 		if (errno) {
-			log_error("Failed to read int token.");
-			return NULL;
+			if (errno == ERANGE && p->key &&
+			    strcmp("creation_time", p->key) == 0) {
+				/* Due to a bug in some older 32bit builds (<2.02.169),
+				 * lvm was able to produce invalid creation_time string */
+				v->v.i = 1527120000; /* Pick 2018-05-24 day instead */
+				if (!p->ignored_creation_time++)
+					log_warn("WARNING: Invalid creation_time found in metadata (repaired with next metadata update).");
+			} else {
+				log_error("Failed to read int token.");
+				return NULL;
+			}
 		}
 		match(TOK_INT);
 		break;


