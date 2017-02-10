From: okozina <okozina@fedoraproject.org>
Date: Fri, 10 Feb 2017 18:19:17 +0000 (UTC)
Subject: master - dmsetup: do not suppress kernel key descriptions in tables
Message-ID: <20170210181917.4FFB660DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=035c614c195b08398df3403c4bbd3d986cca68c3
Commit:        035c614c195b08398df3403c4bbd3d986cca68c3
Parent:        baba3f8e2a1c6f6fcfcefaa06e87872ff63cac6d
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Feb 10 13:19:22 2017 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri Feb 10 19:18:49 2017 +0100

dmsetup: do not suppress kernel key descriptions in tables

Kernel 4.10 (dm-crypt v1.15.0) and later supports loading device
tables with crypt segment having key in kernel keyring retention
service.

dmsetup hid key section of tables output. With this patch dmsetup
no longer hides key section if it detects kernel key description
instead of hex byte representation of key itself.
---
 WHATS_NEW_DM                  |    1 +
 man/dmsetup.8.in              |    6 ++-
 test/shell/dmsetup-keyring.sh |   72 +++++++++++++++++++++++++++++++++++++++++
 tools/dmsetup.c               |   11 +++++-
 4 files changed, 86 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4903de3..ac2d420 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Do not suppress kernel key description in dmsetup table output.
   Support configurable command executed from dmeventd thin plugin.
   Support new R|r human readable units output format.
   Thin dmeventd plugin reacts faster on lvextend failure path with umount.
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 8aa0ff7..36a6d74 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -820,8 +820,10 @@ Outputs the current table for the device in a format that can be fed
 back in using the create or load commands.
 With \fB\-\-target\fP, only information relating to the specified target type
 is displayed.
-Encryption keys are suppressed in the table output for the crypt
-target unless the \fB\-\-showkeys\fP parameter is supplied.
+Real encryption keys are suppressed in the table output for the crypt
+target unless the \fB\-\-showkeys\fP parameter is supplied. Kernel key
+references prefixed with \fB:\fP are not affected by the parameter and get
+displayed always.
 .
 .HP
 .CMD_TARGETS
diff --git a/test/shell/dmsetup-keyring.sh b/test/shell/dmsetup-keyring.sh
new file mode 100644
index 0000000..5ea654e
--- /dev/null
+++ b/test/shell/dmsetup-keyring.sh
@@ -0,0 +1,72 @@
+#!/bin/sh
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# unrelated to lvm2 daemons
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMETAD=1
+
+. lib/inittest
+
+CIPHER=aes-xts-plain64
+HEXKEY_32=0102030405060708090a0102030405060102030405060708090a010203040506
+HIDENKEY_32=0000000000000000000000000000000000000000000000000000000000000000
+KEY_NAME="$PREFIX:keydesc"
+
+function _teardown() {
+	keyctl unlink %:$PREFIX-keyring
+	aux teardown_devs_prefixed $PREFIX
+}
+
+aux target_at_least dm-zero 1 0 0 || skip "missing dm-zero target"
+aux target_at_least dm-crypt 1 15 0 || skip "dm-crypt doesn't support keys in kernel keyring service"
+which keyctl || skip "test requires keyctl utility"
+
+keyctl newring $PREFIX-keyring @u
+keyctl timeout %:$PREFIX-keyring 60
+
+trap '_teardown' EXIT
+
+keyctl add logon $KEY_NAME ${HEXKEY_32:0:32} %:$PREFIX-keyring
+
+dmsetup create $PREFIX-zero --table "0 1 zero"
+# put key in kernel keyring for active table
+dmsetup create $PREFIX-crypt --table "0 1 crypt $CIPHER :32:logon:$KEY_NAME 0 $TESTDIR/dev$prefix/mapper/$PREFIX-zero 0"
+# put hexbyte key in dm-crypt directly in inactive table
+dmsetup load $PREFIX-crypt --table "0 1 crypt $CIPHER $HEXKEY_32 0 $TESTDIR/dev$prefix/mapper/$PREFIX-zero 0"
+
+# test dmsetup doesn't hide key descriptions...
+str=`dmsetup table $PREFIX-crypt | cut -d ' ' -f 5`
+test $str = :32:logon:$KEY_NAME || die
+str=`dmsetup table --showkeys $PREFIX-crypt | cut -d ' ' -f 5`
+test $str = :32:logon:$KEY_NAME || die
+
+# ...but it hides hexbyte representation of keys...
+str=`dmsetup table --inactive $PREFIX-crypt | cut -d ' ' -f 5`
+test $str = $HIDENKEY_32 || die
+#...unless --showkeys explictly requested
+str=`dmsetup table --showkeys --inactive $PREFIX-crypt | cut -d ' ' -f 5`
+test $str = $HEXKEY_32 || die
+
+# let's swap the tables
+dmsetup resume $PREFIX-crypt
+dmsetup load $PREFIX-crypt --table "0 1 crypt $CIPHER :32:logon:$KEY_NAME 0 $TESTDIR/dev$prefix/mapper/$PREFIX-zero 0"
+
+str=`dmsetup table --inactive $PREFIX-crypt | cut -d ' ' -f 5`
+test $str = :32:logon:$KEY_NAME || die
+str=`dmsetup table --showkeys --inactive $PREFIX-crypt | cut -d ' ' -f 5`
+test $str = :32:logon:$KEY_NAME || die
+
+str=`dmsetup table $PREFIX-crypt | cut -d ' ' -f 5`
+test $str = $HIDENKEY_32 || die
+str=`dmsetup table --showkeys $PREFIX-crypt | cut -d ' ' -f 5`
+test $str = $HEXKEY_32 || die
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index c9549c6..6464069 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2197,8 +2197,15 @@ static int _status(CMD_ARGS)
 						c++;
 					if (*c)
 						c++;
-					while (*c && *c != ' ')
-						*c++ = '0';
+					/*
+					 * Do not suppress kernel key references prefixed
+					 * with colon ':'. Displaying those references is
+					 * harmless. crypt target supports kernel keys
+					 * starting with v1.15.0 (merged in kernel 4.10)
+					 */
+					if (*c != ':')
+						while (*c && *c != ' ')
+							*c++ = '0';
 				}
 				printf(FMTu64 " " FMTu64 " %s %s",
 				       start, length, target_type, params);


