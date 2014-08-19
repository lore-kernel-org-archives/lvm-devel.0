From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:18:53 +0000 (UTC)
Subject: master - libdm: check version prints error
Message-ID: <20140819141853.94F846030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10e2370d2efc501067702ffd5cd86940c3637e1c
Commit:        10e2370d2efc501067702ffd5cd86940c3637e1c
Parent:        dec39b1a5f0f599fd751bc6cea8caaac8a211d31
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 19 14:22:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

libdm: check version prints error

Move 'bad' label above log_error, so the
error message is printed on 'bad' path.
(And return 0 is not without log_error()).
---
 libdm/ioctl/libdm-iface.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 4f55ddf..7d50f3a 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -544,10 +544,10 @@ int dm_check_version(void)
 
 	dm_get_library_version(libversion, sizeof(libversion));
 
+      bad:
 	log_error("Incompatible libdevmapper %s%s and kernel driver %s",
 		  libversion, compat, dmversion);
 
-      bad:
 	_version_ok = 0;
 	return 0;
 }


