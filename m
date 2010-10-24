From: Mike Snitzer <snitzer@redhat.com>
Date: Sat, 23 Oct 2010 20:55:15 -0400
Subject: [RFC][PATCH] never scan a device which is using the error target
Message-ID: <20101024005515.GA31723@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A merged snapshot's DM device is made to use the "error" target as part
of lvm's transaction to merge a snapshot.  This snapshot merge use-case
aside, any device using the error target shouldn't be scanned.

NOTE: I'm not using an ignore_suspended_devices() check like other
target checks in device_is_usable() -- its not clear to me what such a
check achieves -- but it clearly doesn't work for my needs seeing as the
default for lvm.conf's ignore_suspended_devices is 0.  Not sure what
commit dd5d9aa6 is up to.. but its devoid of relevant comments.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/dev_manager.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7981f22..aab0c9a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -190,6 +190,12 @@ int device_is_usable(struct device *dev)
 				  dev_name(dev), name);
 			goto out;
 		}
+
+		if (target_type && !strcmp(target_type, "error")) {
+			log_debug("%s: Error device %s not usable.",
+				  dev_name(dev), name);
+			goto out;
+		}
 	} while (next);
 
 	/* FIXME Also check dependencies? */


