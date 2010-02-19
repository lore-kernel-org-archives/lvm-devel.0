From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 19 Feb 2010 11:20:09 -0500
Subject: [RFC] WARNING: dev_open(xxx) called while suspended
Message-ID: <4B7EBA39.3070900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I'm testing 'mirrored' log patch set and I'm annoyed with a following
warning message.
  WARNING: dev_open(xxx) called while suspended
Can I suppress it by lvm configuration or something?

This message is displayed whenever log type is switched.

# lvconvert -m1 --mirrorlog core vg00/lv00
  WARNING: dev_open(/dev/sdc) called while suspended
  WARNING: dev_open(/dev/sdf) called while suspended
  Logical volume lv00 converted.

# lvconvert -m1 --mirrorlog disk vg00/lv00
  WARNING: dev_open(/dev/sdf) called while suspended
  Logical volume lv00 converted.

I bisected and found that this WARNING was introduced by the following
patch, especially adding remote_commit_cached_metadata() function.

LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
https://www.redhat.com/archives/lvm-devel/2010-January/msg00006.html

+++ LVM2/lib/metadata/metadata.c	2010/01/05 16:09:34	1.308
@@ -2331,6 +2331,12 @@
 		}
 	}
 
+	/*
+	 * Instruct remote nodes to upgrade cached metadata.
+	 */
+	if (cache_updated)
+		remote_commit_cached_metadata(vg);
+

I appreciate your comments.

Thanks,
Taka


