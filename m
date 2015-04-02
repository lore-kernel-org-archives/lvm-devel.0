From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 11:41:12 +0000 (UTC)
Subject: master - debug: log scanned value
Message-ID: <20150402114112.4029C6025F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53ef14fca0e85fef0df41665a64d21166d8b684d
Commit:        53ef14fca0e85fef0df41665a64d21166d8b684d
Parent:        e28e22b9e1e4f7243608aa24ddf43ec63afd1751
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 27 13:43:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 13:38:41 2015 +0200

debug: log scanned value

Fix verbose print of scanned value for topology attribute.
Result is set afterwards in sectors.
---
 lib/device/dev-type.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 882c08d..d3407d1 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -799,7 +799,7 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 	}
 
 	log_very_verbose("Device %s: %s is %lu%s.",
-			 dev_name(dev), attribute, result, default_value ? "" : " bytes");
+			 dev_name(dev), attribute, value, default_value ? "" : " bytes");
 
 	result = value >> SECTOR_SHIFT;
 


