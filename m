From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:42 +0000 (GMT)
Subject: main - debug: use enclusing "" for debug
Message-ID: <20210302215842.C4E13382E822@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e1771f8571c54cc053b077305b886278086dd03
Commit:        8e1771f8571c54cc053b077305b886278086dd03
Parent:        1042cd9a612e1f71fda15dac62948707acee326e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 17:08:52 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:57:35 2021 +0100

debug: use enclusing "" for debug

---
 device_mapper/libdm-config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/device_mapper/libdm-config.c b/device_mapper/libdm-config.c
index d2ac43c85..7ce5620c6 100644
--- a/device_mapper/libdm-config.c
+++ b/device_mapper/libdm-config.c
@@ -983,7 +983,7 @@ static const char *_find_config_str(const void *start, node_lookup_fn find_fn,
 	}
 
 	if (fail)
-		log_very_verbose("%s not found in config: defaulting to %s",
+		log_very_verbose("%s not found in config: defaulting to \"%s\"",
 				 path, fail);
 	return fail;
 }


