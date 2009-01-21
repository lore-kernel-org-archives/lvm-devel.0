From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:46 +0100
Subject: [PATCH 05/15] Add key store handlers machinery.
In-Reply-To: <b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
Message-ID: <3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This code should load various drivers for manipulating
with key for volumes.

Here will be interface between LVM (for volume management)
and key management (and related security code).

Currently it only maintains the list of key handlers
and provides search for key handler in this list.

Also implements manadatory key handler "simple".
 - it stores cipher & keysize in LVM metadata directly
 - asks for Master Key (no processig here)

This is direct interface to dm-crypt mapping, and
it does not require any cryptography code in userspace.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/Makefile.in            |    1 +
 lib/commands/toolcontext.c |    3 ++
 lib/crypt/key_handlers.c   |   85 ++++++++++++++++++++++++++++++++++++++++++++
 lib/crypt/lvm-crypto.h     |   25 ++++++++++++-
 4 files changed, 112 insertions(+), 2 deletions(-)
 create mode 100644 lib/crypt/key_handlers.c

diff --git a/lib/Makefile.in b/lib/Makefile.in
index d7b2bf2..41395ed 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -37,6 +37,7 @@ SOURCES =\
 	cache/lvmcache.c \
 	commands/toolcontext.c \
 	config/config.c \
+	crypt/key_handlers.c \
 	crypt/masterkey.c \
 	crypt/password.c \
 	datastruct/btree.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 26a4c83..f9a0b13 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1002,6 +1002,8 @@ static int _init_crypto(struct cmd_context *cmd)
 #ifdef CRYPT_INTERNAL
 	if (!lvm_masterkeys_init())
 		return 0;
+	if (!lvm_keystore_handlers_init())
+		return 0;
 #endif
 	return 1;
 }
@@ -1010,6 +1012,7 @@ static void _destroy_crypto(struct cmd_context *cmd)
 {
 #ifdef CRYPT_INTERNAL
 	lvm_masterkeys_destroy();
+	lvm_keystore_handlers_destroy();
 #endif
 }
 
diff --git a/lib/crypt/key_handlers.c b/lib/crypt/key_handlers.c
new file mode 100644
index 0000000..678a260
--- /dev/null
+++ b/lib/crypt/key_handlers.c
@@ -0,0 +1,85 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+#include "lib.h"
+#include "lvm-crypto.h"
+
+/*
+ * Global Key Store handlers list
+ */
+static struct dm_list _keystore_handlers;
+
+/*
+ * Plain handler (mandatory)
+ */
+static int plain_retrieve(struct crypto_store *cs, const char *for_text,
+			  char *buffer, unsigned buffer_len)
+{
+	char prompt[4096];
+	unsigned len;
+
+	dm_snprintf(prompt, sizeof(prompt), "Enter master key%s%s [%u]: ",
+		    for_text ? " for " : "", for_text ?: "", buffer_len);
+	len = lvm_read_password(prompt, buffer, buffer_len);
+	if (len != buffer_len) {
+		log_error("Incorrect key length (need %u bytes, received %u)",
+			  buffer_len, len);
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct crypto_store_ops _plain_ops = {
+	.master_key_retrieve = plain_retrieve,
+};
+
+static struct crypto_store_type _plain_csh = {
+	.name = "plain",
+	.flags = CS_IGNORE_KEYHASH,
+	.ops = &_plain_ops,
+};
+
+/*
+ * Key Store registration helpers
+ */
+int lvm_keystore_handlers_init()
+{
+	dm_list_init(&_keystore_handlers);
+
+	// FIXME: here should be library loading
+	dm_list_add(&_keystore_handlers, &_plain_csh.list);
+
+	return 1;
+}
+
+void lvm_keystore_handlers_destroy()
+{
+	dm_list_init(&_keystore_handlers);
+}
+
+struct crypto_store_type *lvm_get_keystore_handler(const char *name)
+{
+	struct crypto_store_type *csh;
+
+	if (!name)
+		return_NULL;
+
+	dm_list_iterate_items(csh, &_keystore_handlers)
+		if (!strcmp(name, csh->name))
+			return csh;
+
+	log_debug("Not supported %s handler for crypto store.", name);
+	return NULL;
+}
diff --git a/lib/crypt/lvm-crypto.h b/lib/crypt/lvm-crypto.h
index 1a7825d..3ebddce 100644
--- a/lib/crypt/lvm-crypto.h
+++ b/lib/crypt/lvm-crypto.h
@@ -23,9 +23,23 @@
  */
 typedef const char *masterkey_t;
 
-#define cs_handler_name(cs)     ((cs)->type ? (cs)->type->name : (cs)->type_name)
+/*
+ * Flags says if attribute is stored in keystore area and not in LVM metadata.
+ * By default, all generic attributes in LVM metadata must be retained
+ * (for example when some keystore handler is not loaded in rescue mode).
+ */
+#define CS_IGNORE_CIPHER	0x00000001U
+#define CS_IGNORE_KEYLEN	0x00000002U
+#define CS_IGNORE_KEYHASH	0x00000004U
+
+#define cs_flags(cs)		((cs)->type ? (cs)->type->flags : 0)
+#define cs_handler_name(cs)	((cs)->type ? (cs)->type->name : (cs)->type_name)
+
+#define cs_store_cipher(cs)	(cs_flags(cs) & CS_IGNORE_CIPHER ? 0 : 1)
+#define cs_store_keylen(cs)	(cs_flags(cs) & CS_IGNORE_KEYLEN ? 0 : 1)
+#define cs_store_keyhash(cs)	(cs_flags(cs) & CS_IGNORE_KEYHASH ? 0 : 1)
 
-#define cs_key_bytes(cs)        ((cs)->key_size ? ((cs)->key_size * 2 / 8) : 4095)
+#define cs_key_bytes(cs)	((cs)->key_size ? ((cs)->key_size * 2 / 8) : 4095)
 
 /*
  * Crypto config & key store
@@ -85,6 +99,13 @@ int lvm_masterkeys_verify(struct crypto_store *cs, const char *key);
 int lvm_masterkeys_retrieve(const char *for_text, struct crypto_store *cs);
 
 /*
+ * Key Store handlers manipulation
+ */
+int lvm_keystore_handlers_init(void);
+void lvm_keystore_handlers_destroy(void);
+struct crypto_store_type *lvm_get_keystore_handler(const char *name);
+
+/*
  * Crypto Helper functions
  */
 int lvm_set_password_dev(const char *password_file);
-- 
1.5.6.5


