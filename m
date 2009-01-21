From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:44 +0100
Subject: [PATCH 03/15] Add master key cache to LVM.
In-Reply-To: <1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
Message-ID: <589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Master key is key used directly in crypt segment mapping table.

Because LVM performs various magic with mapping table,
we need ask user (for providing master key unlocking information)
only once and during the lvm operation cache the master key.

Master key cache provides such temporary store area.

Key is stored directly in dm-crypt format in hash table,
key for hash table is crypt_store UUID.

The memory for storing key is allocated using dm_malloc
and must be always wiped before releasing.

Master key interface provides these functions:
 - init/destroy the whole cache
 - insert/remove key from cache using its ID
 - query for key

Also this patch provides two helper functions:
lvm_masterkeys_verify - verifies that key is in expected format & length
lvm_masterkeys_retrieve - calls the retrieve function
                          in crypto store if key is not already cached

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/Makefile.in            |    1 +
 lib/commands/toolcontext.c |   21 ++++++
 lib/crypt/lvm-crypto.h     |   22 +++++++
 lib/crypt/masterkey.c      |  149 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 193 insertions(+), 0 deletions(-)
 create mode 100644 lib/crypt/masterkey.c

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 54092cd..9705580 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -37,6 +37,7 @@ SOURCES =\
 	cache/lvmcache.c \
 	commands/toolcontext.c \
 	config/config.c \
+	crypt/masterkey.c \
 	datastruct/btree.c \
 	datastruct/str_list.c \
 	device/dev-cache.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0a98325..26a4c83 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -997,6 +997,22 @@ static void _init_globals(struct cmd_context *cmd)
 
 }
 
+static int _init_crypto(struct cmd_context *cmd)
+{
+#ifdef CRYPT_INTERNAL
+	if (!lvm_masterkeys_init())
+		return 0;
+#endif
+	return 1;
+}
+
+static void _destroy_crypto(struct cmd_context *cmd)
+{
+#ifdef CRYPT_INTERNAL
+	lvm_masterkeys_destroy();
+#endif
+}
+
 /* Entry point */
 struct cmd_context *create_toolcontext(unsigned is_long_lived)
 {
@@ -1092,6 +1108,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived)
 	if (!_init_backup(cmd))
 		goto error;
 
+	if (!_init_crypto(cmd))
+		goto error;
+
 	_init_rand(cmd);
 
 	_init_globals(cmd);
@@ -1164,6 +1183,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	dev_cache_exit();
 	_destroy_tags(cmd);
 	_destroy_tag_configs(cmd);
+	_destroy_crypto(cmd);
 
 	cmd->config_valid = 0;
 
@@ -1228,6 +1248,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	dev_cache_exit();
 	_destroy_tags(cmd);
 	_destroy_tag_configs(cmd);
+	_destroy_crypto(cmd);
 	dm_pool_destroy(cmd->libmem);
 	dm_free(cmd);
 
diff --git a/lib/crypt/lvm-crypto.h b/lib/crypt/lvm-crypto.h
index 7ce3941..9690779 100644
--- a/lib/crypt/lvm-crypto.h
+++ b/lib/crypt/lvm-crypto.h
@@ -19,6 +19,15 @@
 #include "uuid.h"
 
 /*
+ * Master key is stored in *text* hexa string, in direct dm-crypt format
+ */
+typedef const char *masterkey_t;
+
+#define cs_handler_name(cs)     ((cs)->type ? (cs)->type->name : (cs)->type_name)
+
+#define cs_key_bytes(cs)        ((cs)->key_size ? ((cs)->key_size * 2 / 8) : 4095)
+
+/*
  * Crypto config & key store
  */
 struct crypto_store_type {
@@ -62,4 +71,17 @@ struct crypto_store_ops {
 	// FIXME: key management, area formatting functions, etc
 };
 
+/*
+ * Master Key cache
+ */
+int lvm_masterkeys_init(void);
+void lvm_masterkeys_destroy(void);
+
+int lvm_masterkeys_insert(const struct id *id, masterkey_t key);
+void lvm_masterkeys_remove(const struct id *id);
+masterkey_t lvm_masterkeys_query(const struct id *id);
+
+int lvm_masterkeys_verify(struct crypto_store *cs, const char *key);
+int lvm_masterkeys_retrieve(const char *for_text, struct crypto_store *cs);
+
 #endif
diff --git a/lib/crypt/masterkey.c b/lib/crypt/masterkey.c
new file mode 100644
index 0000000..6efefcd
--- /dev/null
+++ b/lib/crypt/masterkey.c
@@ -0,0 +1,149 @@
+/*
+ * Copyright (C) 2008-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * Store for master keys used for dm-crypt mapping
+ */
+#include "lib.h"
+#include "lvm-crypto.h"
+
+static struct dm_hash_table *_key_hash = NULL;
+
+static void _masterkeys_destroy_entry(char *mk)
+{
+	/*
+	 * Safely clean memory
+	 */
+	memset(mk, 0, strlen(mk));
+	dm_free(mk);
+}
+
+void lvm_masterkeys_remove(const struct id *id)
+{
+	char *mk = (char *)lvm_masterkeys_query(id);
+
+	dm_hash_remove_binary(_key_hash, (const char *)id, ID_LEN);
+	_masterkeys_destroy_entry(mk);
+}
+
+int lvm_masterkeys_insert(const struct id *id, masterkey_t key)
+{
+	/*
+	 * Hash key for master key is id of cryptostore
+	 * Key is stored as text hexa string (direct dm-crypt format)
+	 */
+	return dm_hash_insert_binary(_key_hash, (const char *)id,
+				     ID_LEN, (void *)key) ? 1 : 0;
+}
+
+masterkey_t lvm_masterkeys_query(const struct id *id)
+{
+	return dm_hash_lookup_binary(_key_hash, (const char *)id, ID_LEN);
+}
+
+int lvm_masterkeys_verify(struct crypto_store *cs, const char *key)
+{
+	int i, len = strlen(key);
+
+	if (len != cs_key_bytes(cs))
+		return 0;
+
+	// FIXME: really stupid
+	for (i = 0; i < len; i++) {
+		if (key[i] >= '0' && key[i] <= '9')
+			continue;
+		if (key[i] >= 'a' && key[i] <= 'f')
+			continue;
+		if (key[i] >= 'A' && key[i] <= 'F')
+			continue;
+		return 0;
+	}
+
+	return 1;
+}
+
+int lvm_masterkeys_retrieve(const char *for_text, struct crypto_store *cs)
+{
+	char *password;
+	int r = 0;
+
+	// FIXME: allow several tries, set in lvm.conf
+	// FIXME: if the volume is activated, retrieve Master Key through dm table
+
+	/*
+	 * Driver for keystore is not loaded, do not try to read key.
+	 */
+	if (!cs->type || !cs->type->ops || !cs->type->ops->master_key_retrieve) {
+		log_error("Cannot retrieve password%s%s, "
+			  "key store handler type %s is not installed.",
+			  for_text ? " for " : "", for_text ?: "",
+			  cs_handler_name(cs));
+		return 0;
+	}
+
+	/*
+	 * Master Key is already cached
+	 */
+	if (lvm_masterkeys_query(&cs->id))
+		return 1;
+
+	/*
+	 * Buffer for hexa encoding
+	 */
+	if (!(password = dm_malloc(cs_key_bytes(cs) + 1)))
+		return_0;
+
+	r = cs->type->ops->master_key_retrieve(cs, for_text, password, cs_key_bytes(cs));
+
+	// FIXME: if the retrieve function fails, it should not ask during the same
+	//	  operation for the same volume again
+	if (!r)
+		goto out;
+
+	password[cs_key_bytes(cs)] = '\0';
+	if (!lvm_masterkeys_verify(cs, password)) {
+		log_error("Key is not in expected format.");
+		goto out;
+	}
+
+	return lvm_masterkeys_insert(&cs->id, password);
+out:
+	memset(password, 0, cs_key_bytes(cs));
+	dm_free(password);
+	return 0;
+}
+
+int lvm_masterkeys_init()
+{
+	//FIXME: clear keys?
+	if (_key_hash)
+		return 1;
+
+	log_debug("Initializing master key cache.");
+
+	if (!(_key_hash = dm_hash_create(128)))
+		return 0;
+
+	return 1;
+}
+
+void lvm_masterkeys_destroy()
+{
+	if (_key_hash) {
+		log_debug("Destroying master key cache (%u).", dm_hash_get_num_entries(_key_hash));
+		dm_hash_iter(_key_hash, (dm_hash_iterate_fn) _masterkeys_destroy_entry);
+		dm_hash_destroy(_key_hash);
+		_key_hash = NULL;
+	}
+}
-- 
1.5.6.5


