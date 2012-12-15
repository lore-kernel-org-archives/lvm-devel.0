From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:14 +0000 (UTC)
Subject: master - cleanup: skip assignment
Message-ID: <20121215162514.366A4AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13835d04ac2a2c518ec935d220c7feb711327884
Commit:        13835d04ac2a2c518ec935d220c7feb711327884
Parent:        0396ade38b88431d959ce02fac689306a2c47786
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 14:18:46 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: skip assignment

env is reassigned without the use, so drop this assign.
---
 libdm/libdm-common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 075fba8..4a0ada8 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -87,7 +87,7 @@ void dm_lib_init(void)
 {
 	const char *env;
 
-	if ((env = getenv("DM_DISABLE_UDEV")))
+	if (getenv("DM_DISABLE_UDEV"))
 		_udev_disabled = 1;
 
 	env = getenv(DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME);


