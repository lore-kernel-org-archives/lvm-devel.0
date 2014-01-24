From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Jan 2014 12:14:24 +0000 (UTC)
Subject: master - thin: fix missing ~ in previous commit
Message-ID: <20140124121424.55143616F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89d77326170d020ebba6ae1c717c08ac4b07996a
Commit:        89d77326170d020ebba6ae1c717c08ac4b07996a
Parent:        731c298e12e36e338afdbda029e6cffb2c98b3eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 24 13:13:37 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 24 13:13:37 2014 +0100

thin: fix missing ~ in previous commit

---
 lib/metadata/pool_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 2cb0c27..18dfad5 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -255,7 +255,7 @@ int create_pool(struct logical_volume *pool_lv,
 				  pool_lv->name);
 			goto bad;
 		}
-		pool_lv->status &= LV_TEMPORARY;
+		pool_lv->status &= ~LV_TEMPORARY;
 	}
 
 	if (dm_snprintf(name, sizeof(name), "%s_%s", pool_lv->name,


