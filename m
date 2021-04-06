From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:23 +0000 (GMT)
Subject: main - lvreduce: support --yes
Message-ID: <20210406200723.E9DFB3858012@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=287565fd5dd5f49f1a51c6cd9ebdc9c20ebc7730
Commit:        287565fd5dd5f49f1a51c6cd9ebdc9c20ebc7730
Parent:        f1d3648dc786a8fad53a32cbd334a44b36c53767
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 6 12:26:42 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

lvreduce: support --yes

Missed support for --yes with 'lvreduce' to answer 'y' to prompt.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 81346bd1a..b38acf883 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4970,7 +4970,7 @@ static int _request_confirmation(const struct logical_volume *lv,
 
 	log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
 
-	if (!lp->force) {
+	if (!lp->force && !lp->yes) {
 		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
 				  display_lvname(lv)) == 'n') {
 			log_error("Logical volume %s NOT reduced.",


