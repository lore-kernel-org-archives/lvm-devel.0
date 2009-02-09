From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:03 -0500
Subject: [PATCH 15/21] Add write mode to vg_open(), calling the new vg_read API with READ_FOR_UPDATE.
In-Reply-To: <1234153329-2829-15-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-11-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-12-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-13-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-14-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-15-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-16-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/lvm2.c b/lib/lvm2.c
index cf4e603..e58f7e8 100644
--- a/lib/lvm2.c
+++ b/lib/lvm2.c
@@ -49,14 +49,17 @@ vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode)
 {
 	vg_t *vg;
 
-	if ((mode & O_ACCMODE) != O_RDONLY) {
+	if ((mode & O_ACCMODE) == O_RDONLY) {
+		vg = vg_read(libh->cmd, vg_name, NULL, 0);
+	} else if ((mode & O_ACCMODE) == O_RDWR) {
+		vg = vg_read(libh->cmd, vg_name, NULL, READ_FOR_UPDATE);
+	} else {
 		log_error("Invalid access mode 0x%x for lvm_vg_read()\n",
 			  mode);
 		libh->lvm_errno = EPERM;
 		return NULL;
 	}
-	vg = vg_read(libh->cmd, vg_name, NULL, 0);
-
+	
 	if (vg_read_error(vg)) {
 		/* FIXME: fill in vg->errno */
 		return NULL;
-- 
1.6.0.5


