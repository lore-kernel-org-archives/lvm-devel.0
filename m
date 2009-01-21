From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:45 +0100
Subject: [PATCH 04/15] Add simple password helpers.
In-Reply-To: <589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
Message-ID: <b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These enable to read password from
	- terminal
	- standard input
	- file

(Key store handlers will use this.)

(Alternative is use some exported funtion provided
by some crypto library but I think we should
not rely here on external library.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/Makefile.in        |    1 +
 lib/crypt/lvm-crypto.h |    6 ++
 lib/crypt/masterkey.c  |    3 +
 lib/crypt/password.c   |  127 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 137 insertions(+), 0 deletions(-)
 create mode 100644 lib/crypt/password.c

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 9705580..d7b2bf2 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -38,6 +38,7 @@ SOURCES =\
 	commands/toolcontext.c \
 	config/config.c \
 	crypt/masterkey.c \
+	crypt/password.c \
 	datastruct/btree.c \
 	datastruct/str_list.c \
 	device/dev-cache.c \
diff --git a/lib/crypt/lvm-crypto.h b/lib/crypt/lvm-crypto.h
index 9690779..1a7825d 100644
--- a/lib/crypt/lvm-crypto.h
+++ b/lib/crypt/lvm-crypto.h
@@ -84,4 +84,10 @@ masterkey_t lvm_masterkeys_query(const struct id *id);
 int lvm_masterkeys_verify(struct crypto_store *cs, const char *key);
 int lvm_masterkeys_retrieve(const char *for_text, struct crypto_store *cs);
 
+/*
+ * Crypto Helper functions
+ */
+int lvm_set_password_dev(const char *password_file);
+int lvm_read_password(char *message, char *pass, size_t len);
+
 #endif
diff --git a/lib/crypt/masterkey.c b/lib/crypt/masterkey.c
index 6efefcd..c3870ca 100644
--- a/lib/crypt/masterkey.c
+++ b/lib/crypt/masterkey.c
@@ -126,6 +126,7 @@ out:
 
 int lvm_masterkeys_init()
 {
+	(void)lvm_set_password_dev(NULL);
 	//FIXME: clear keys?
 	if (_key_hash)
 		return 1;
@@ -140,6 +141,8 @@ int lvm_masterkeys_init()
 
 void lvm_masterkeys_destroy()
 {
+	(void)lvm_set_password_dev(NULL);
+
 	if (_key_hash) {
 		log_debug("Destroying master key cache (%u).", dm_hash_get_num_entries(_key_hash));
 		dm_hash_iter(_key_hash, (dm_hash_iterate_fn) _masterkeys_destroy_entry);
diff --git a/lib/crypt/password.c b/lib/crypt/password.c
new file mode 100644
index 0000000..a7f5a46
--- /dev/null
+++ b/lib/crypt/password.c
@@ -0,0 +1,127 @@
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
+ * Various password read helpers
+ */
+#include <fcntl.h>
+#include <termios.h>
+#include "lib.h"
+#include "lvm-crypto.h"
+
+/*
+ * File name where to read password form
+ */
+static char _password_dev_name[PATH_MAX+1];
+
+static int lvm_read_password_from_stdin(char *pass, size_t maxlen)
+{
+	int ret, fd = 0;
+
+	ret = read(fd, pass, maxlen);
+
+	if (ret > 0 && ret < maxlen)
+		pass[ret-1] = 0;
+
+	return ret;
+}
+
+static int lvm_read_password_from_tty(char *message, char *pass,
+				      size_t maxlen)
+{
+	struct termios term_orig, term_noecho;
+	int fd, ret = 0;
+
+	// FIXME: add timeout option
+	// FIXME: fail if not on compatible termial
+	// FIXME: support alternative imput (file)
+
+	if ((fd = open("/dev/tty", O_RDWR)) == -1)
+		return 0;
+
+	/*
+	 * Switch echo off
+	 */
+	if (tcgetattr(fd, &term_orig))
+		goto out_err;
+	memcpy(&term_noecho, &term_orig, sizeof(term_noecho));
+	term_noecho.c_lflag &= ~ECHO;
+	if (tcsetattr(fd, TCSAFLUSH, &term_noecho))
+		goto out_err;
+
+	if (message)
+		(void)write(fd, message, strlen(message));
+
+	ret = read(fd, pass, maxlen);
+
+	if (ret > 0 && ret < maxlen)
+		pass[ret-1] = 0;
+
+	(void)write(fd, "\n", 1);
+
+	(void)tcsetattr(fd, TCSAFLUSH, &term_orig);
+
+out_err:
+	(void)close(fd);
+
+	if (!ret)
+		log_error("Unable to get password from terminal.");
+
+	return ret;
+}
+
+static int lvm_read_password_from_file(const char *password_file,
+				      char *pass, size_t len)
+{
+	struct device *dev;
+	int r = 1;
+
+	if (!(dev = dev_create_file(password_file, NULL, NULL, 1)))
+		return 0;
+
+	if (!dev_open(dev)) {
+		log_error("Cannot open key file: %s", password_file);
+		return 0;
+	}
+
+	if (!dev_read(dev, 0, len, pass))
+		r = 0;
+
+	if (!dev_close(dev))
+		stack;
+
+	return r;
+}
+
+int lvm_set_password_dev(const char *password_file)
+{
+	if (!password_file)
+		memset(_password_dev_name, 0, sizeof(_password_dev_name));
+	else
+		strncpy(_password_dev_name, password_file, PATH_MAX);
+
+	//FIXME: verify file path?
+
+	return 1;
+}
+
+int lvm_read_password(char *message, char *pass, size_t len)
+{
+	if(!_password_dev_name[0])
+		return lvm_read_password_from_tty(message, pass, len);
+	else if(!strcmp(_password_dev_name, "-"))
+		return lvm_read_password_from_stdin(pass, len);
+
+	return lvm_read_password_from_file(_password_dev_name, pass, len);
+}
-- 
1.5.6.5


