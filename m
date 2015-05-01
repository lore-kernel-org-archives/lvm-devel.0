From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:31 +0000 (UTC)
Subject: master - tests: hide error message
Message-ID: <20150501130831.ACD3A60366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0eea780bceccb5e1693429529f292b2fb36afadd
Commit:        0eea780bceccb5e1693429529f292b2fb36afadd
Parent:        0480b4743a77c166390f50561e8bcdb68214d4ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 13:57:08 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:58 2015 +0200

tests: hide error message

Hide error about missing declare -A  support.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 276bb35..c6b05f8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -786,7 +786,7 @@ EOF
 	    echo "$v"
 	done >> "$config_values"
 
-	declare -A CONF || {
+	declare -A CONF 2>/dev/null || {
 		# Associative arrays is not available
 		local s
 		for s in $(cut -f1 -d/ "$config_values" | sort | uniq); do


