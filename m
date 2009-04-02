From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 13:19:15 -0400
Subject: [RFC PATCH 1/7] remove device scan from _text_create_text_instance
In-Reply-To: <49D3D9F5.902@redhat.com>
References: <49D3D9F5.902@redhat.com>
Message-ID: <49D4F393.2020902@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Usually the _text_create_text_instance function is called after device
scan is done, and as far as I understand, lvmcache_label_scan in the
_text_create_text_instance is not necessarily needed.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/format_text/format-text.c |    2 --
 1 file changed, 2 deletions(-)

Index: LVM2.02.46-cvs-20090324/lib/format_text/format-text.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/format_text/format-text.c
+++ LVM2.02.46-cvs-20090324/lib/format_text/format-text.c
@@ -1792,8 +1792,6 @@ static struct format_instance *_text_cre
 			dm_list_add(&fid->metadata_areas, &mda->list);
 		}
 
-		/* Scan PVs in VG for any further MDAs */
-		lvmcache_label_scan(fmt->cmd, 0);
 		if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 			goto_out;
 		dm_list_iterate_items(info, &vginfo->infos) {







