From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jan 2013 08:24:51 +0000 (UTC)
Subject: master - filters: add scm devices
Message-ID: <20130111082451.493A712ED@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9602e68577b43cf2090e680d7b4d2318c72009a7
Commit:        9602e68577b43cf2090e680d7b4d2318c72009a7
Parent:        06abb2dd4c78e66529e7e6407db1afb3f0f44d85
Author:        Sebastian Ott <sebott@linux.vnet.ibm.com>
AuthorDate:    Thu Jan 10 20:20:37 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 11 09:24:07 2013 +0100

filters: add scm devices

Fix this:
pvcreate /dev/scma
  Device /dev/scma not found (or ignored by filtering).

Reported-by: Peter Oberparleiter <peter.oberparleiter@de.ibm.com>
Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
---
 lib/filters/device-types.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/filters/device-types.h b/lib/filters/device-types.h
index aec4293..2e49f7f 100644
--- a/lib/filters/device-types.h
+++ b/lib/filters/device-types.h
@@ -58,5 +58,6 @@ static const device_info_t _device_info[] = {
 	{"mtip32xx", 16},	/* Micron PCIe SSDs */
 	{"vtms", 16},		/* Violin Memory */
 	{"skd", 16},		/* STEC */
+	{"scm", 8},		/* Storage Class Memory (IBM S/390) */
 	{"", 0}
 };


