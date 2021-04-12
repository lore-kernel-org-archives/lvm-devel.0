From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:38 +0000 (GMT)
Subject: main - libdm: replace deprecated security_context_t
Message-ID: <20210412075538.3838539FCC74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=75424dd6927ac38c97ca4acc78b7f4933cd7b139
Commit:        75424dd6927ac38c97ca4acc78b7f4933cd7b139
Parent:        57b5bc9c87ba090e198c9e5ec679ad81db88a093
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 10 21:55:19 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

libdm: replace deprecated security_context_t

Use 'char *' instead of deprecated security_context_t.
In more details i.e.:

https://gitlab.gnome.org/GNOME/glib/-/merge_requests/1776
---
 device_mapper/libdm-common.c | 6 +++---
 libdm/libdm-common.c         | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index c0dde2071..6a2573ec4 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -931,7 +931,7 @@ int dm_task_add_target(struct dm_task *dmt, uint64_t start, uint64_t size,
 
 #ifdef HAVE_SELINUX
 static int _selabel_lookup(const char *path, mode_t mode,
-			   security_context_t *scontext)
+			   char **scontext)
 {
 #ifdef HAVE_SELINUX_LABEL_H
 	if (!_selabel_handle &&
@@ -974,7 +974,7 @@ static int _is_selinux_enabled(void)
 int dm_prepare_selinux_context(const char *path, mode_t mode)
 {
 #ifdef HAVE_SELINUX
-	security_context_t scontext = NULL;
+	char *scontext = NULL;
 
 	if (_is_selinux_enabled() <= 0)
 		return 1;
@@ -1002,7 +1002,7 @@ int dm_prepare_selinux_context(const char *path, mode_t mode)
 int dm_set_selinux_context(const char *path, mode_t mode)
 {
 #ifdef HAVE_SELINUX
-	security_context_t scontext = NULL;
+	char *scontext = NULL;
 
 	if (_is_selinux_enabled() <= 0)
 		return 1;
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 1f3fe1642..708414676 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -929,7 +929,7 @@ int dm_task_add_target(struct dm_task *dmt, uint64_t start, uint64_t size,
 
 #ifdef HAVE_SELINUX
 static int _selabel_lookup(const char *path, mode_t mode,
-			   security_context_t *scontext)
+			   char **scontext)
 {
 #ifdef HAVE_SELINUX_LABEL_H
 	if (!_selabel_handle &&
@@ -972,7 +972,7 @@ static int _is_selinux_enabled(void)
 int dm_prepare_selinux_context(const char *path, mode_t mode)
 {
 #ifdef HAVE_SELINUX
-	security_context_t scontext = NULL;
+	char *scontext = NULL;
 
 	if (_is_selinux_enabled() <= 0)
 		return 1;
@@ -1000,7 +1000,7 @@ int dm_prepare_selinux_context(const char *path, mode_t mode)
 int dm_set_selinux_context(const char *path, mode_t mode)
 {
 #ifdef HAVE_SELINUX
-	security_context_t scontext = NULL;
+	char *scontext = NULL;
 
 	if (_is_selinux_enabled() <= 0)
 		return 1;


