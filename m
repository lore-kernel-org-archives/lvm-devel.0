From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:32 +0000 (GMT)
Subject: main - tests: avoid using length
Message-ID: <20230210165332.DF730385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc2293f18ed14f4b306c7e5b92e508a6981b4826
Commit:        cc2293f18ed14f4b306c7e5b92e508a6981b4826
Parent:        30b9d4d4aa7da8dda586fb041b88830bcc2e60de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 9 14:02:17 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

tests: avoid using length

Use ${#  for length instead.
---
 test/lib/utils.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 1d1ed48bf..ca9f5ec61 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -87,7 +87,7 @@ mkdtemp() {
 	base_template=$(echo "$template" | sed 's/XX*$//')
 
 	# Calculate how many X's we've just removed.
-	nx=$(expr length "$template" - length "$base_template")
+	nx=$(( ${#template} - ${#base_template} ))
 
 	err=
 	i=1

