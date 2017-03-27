From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Mar 2017 14:51:12 -0400
Subject: master - tests: update to better fit
Message-ID: <201703271851.v2RIpCEf004603@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88e408b8eddc77854be5785c86726b67f814f080
Commit:        88e408b8eddc77854be5785c86726b67f814f080
Parent:        e3a3cf01eb51cb528ecf6d90548f29a781510557
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 23 16:00:02 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 27 20:50:19 2017 +0200

tests: update to better fit

Die is automatic on 'error' result
Cleanup everything on 'regular' code path.
---
 test/shell/dmsetup-keyring.sh |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/test/shell/dmsetup-keyring.sh b/test/shell/dmsetup-keyring.sh
index 5ea654e..127d2f7 100644
--- a/test/shell/dmsetup-keyring.sh
+++ b/test/shell/dmsetup-keyring.sh
@@ -46,27 +46,30 @@ dmsetup load $PREFIX-crypt --table "0 1 crypt $CIPHER $HEXKEY_32 0 $TESTDIR/dev$
 
 # test dmsetup doesn't hide key descriptions...
 str=`dmsetup table $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = :32:logon:$KEY_NAME || die
+test $str = :32:logon:$KEY_NAME
 str=`dmsetup table --showkeys $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = :32:logon:$KEY_NAME || die
+test $str = :32:logon:$KEY_NAME
 
 # ...but it hides hexbyte representation of keys...
 str=`dmsetup table --inactive $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = $HIDENKEY_32 || die
+test $str = $HIDENKEY_32
 #...unless --showkeys explictly requested
 str=`dmsetup table --showkeys --inactive $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = $HEXKEY_32 || die
+test $str = $HEXKEY_32
 
 # let's swap the tables
 dmsetup resume $PREFIX-crypt
 dmsetup load $PREFIX-crypt --table "0 1 crypt $CIPHER :32:logon:$KEY_NAME 0 $TESTDIR/dev$prefix/mapper/$PREFIX-zero 0"
 
 str=`dmsetup table --inactive $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = :32:logon:$KEY_NAME || die
+test $str = :32:logon:$KEY_NAME
 str=`dmsetup table --showkeys --inactive $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = :32:logon:$KEY_NAME || die
+test $str = :32:logon:$KEY_NAME
 
 str=`dmsetup table $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = $HIDENKEY_32 || die
+test $str = $HIDENKEY_32
 str=`dmsetup table --showkeys $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = $HEXKEY_32 || die
+test $str = $HEXKEY_32
+
+dmsetup remove $PREFIX-crypt
+dmsetup remove $PREFIX-zero


