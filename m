From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Aug 2016 07:11:00 +0000 (UTC)
Subject: master - lvmcmdline: use long int for number returned by strtol
Message-ID: <20160810071100.7FEEE60774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fed8d8515644d25c24e8f62b450d80d34911970
Commit:        2fed8d8515644d25c24e8f62b450d80d34911970
Parent:        480c1c95993a1a2903e580ca402ba6368088decd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 10 09:10:28 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 10 09:10:37 2016 +0200

lvmcmdline: use long int for number returned by strtol

---
 tools/lvmcmdline.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index af38799..9a4deb7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1853,7 +1853,7 @@ static int _do_get_custom_fd(const char *env_var_name, int *fd)
 {
 	const char *str;
 	char *endptr;
-	int tmp_fd;
+	long int tmp_fd;
 
 	*fd = -1;
 


