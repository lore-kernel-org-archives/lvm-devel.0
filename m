From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 20:59:18 +0000 (UTC)
Subject: master - tests: fix the system_id tests
Message-ID: <20150225205918.9969A60D6F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c50cbe8cbd5197793abb6f43f42b53980cdc65e
Commit:        2c50cbe8cbd5197793abb6f43f42b53980cdc65e
Parent:        ebb2205b4c56aa99cb77939eff396665c47f082d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 12:27:49 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 14:58:49 2015 -0600

tests: fix the system_id tests

That were broken by yesterday's system_id changes.
---
 man/lvmsystemid.7.in    |    2 +-
 test/shell/system_id.sh |   22 +++++++++++-----------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index 741aafe..e188c12 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -36,7 +36,7 @@ Valid system_id characters are the same as valid VG name characters.  If a
 system_id contains invalid characters, those characters are omitted and
 remaining characters are used.  If a system_id is longer than the maximum
 name length, the characters up to the maximum length are used.  The
-maximum length of a system_id is 127 characters.
+maximum length of a system_id is 128 characters.
 
 .SS Limitations and warnings
 
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 5327153..43d1203 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -298,15 +298,15 @@ grep $SID1 err
 vgremove $vg1
 rm -f $SIDFILE
 
-# Test max system_id length (127) and invalid system_id characters.
-# The 127 length limit is imposed before invalid characters are omitted.
+# Test max system_id length (128) and invalid system_id characters.
+# The 128 length limit is imposed before invalid characters are omitted.
 
 SIDFILE=etc/lvm_test.conf
 
-# 120 numbers followed by 7 letters (max len)
-SID1=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefg
-# 120 numbers followed by 8 letters (too long by 1 character, the last is omitted)
-SID2=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefgh
+# 120 numbers followed by 8 letters (max len)
+SID1=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefgh
+# 120 numbers followed by 9 letters (too long by 1 character, the last is omitted)
+SID2=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefghi
 
 # max len system_id should appear normally
 rm -f $SIDFILE
@@ -339,11 +339,11 @@ rm -f $SIDFILE
 
 # max len system_id containing an invalid character should appear without
 # the invalid character
-# 120 numbers followed by invalid '#' character followed by 7 letters (too long by 1 character)
-SID1=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789#abcdefg
+# 120 numbers followed by invalid '%' character followed by 8 letters (too long by 1 character)
+SID1=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789%abcdefgh
 # After the invalid character is omitted from SID1
-# The string is truncated to max length (127) before the invalid character is omitted
-SID2=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdef
+# The string is truncated to max length (128) before the invalid character is omitted
+SID2=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefg
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
 aux lvmconf "global/system_id_source = file"
@@ -359,7 +359,7 @@ vgremove $vg1
 rm -f $SIDFILE
 
 # contains a bunch of invalid characters
-SID1="?#$&A. at 1]"
+SID1="?%$&A. at 1]"
 # SID1 without the invalid characters
 SID2=A.1
 


