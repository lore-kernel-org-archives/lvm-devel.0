From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Jul 2013 07:26:39 +0000 (UTC)
Subject: master - api test: remove unused variable
Message-ID: <20130715072639.50758611A1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eaa1f0eb15737e130a0a501905871400b66f68ff
Commit:        eaa1f0eb15737e130a0a501905871400b66f68ff
Parent:        5b213492f8e690acb163b833eadfdb25501d8f26
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 15 09:26:31 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 15 09:26:31 2013 +0200

api test: remove unused variable

---
 test/api/vglist.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/api/vglist.c b/test/api/vglist.c
index 5939340..0a882dc 100644
--- a/test/api/vglist.c
+++ b/test/api/vglist.c
@@ -43,8 +43,6 @@ static void done(int ok) {
 
 int main(int argc, char *argv[])
 {
-	int status;
-
 	if (argc != 3)
 		abort();
 


