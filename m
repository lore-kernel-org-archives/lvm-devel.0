From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Thu, 1 Aug 2019 10:20:08 +0530
Subject: lvmcache lv destroy with no flush
Message-ID: <5d426f7f.1c69fb81.24900.f111@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team,
A very good day to you all.

Lets say, there exists a LVM cache LV in writeback mode with lots of dirty blocks.
How can I destroy this LV without waiting for data sync to finish? This is a tear down operation and there is no necessity for data sync to complete.

Any operation like lvremove, vgremove etc. all of it wait for the cache sync to complete before tearing down the lv/vg.

Please let me know if there is a way to accomplish my requirement.

Best regards
LN
Sent from Mail for Windows 10

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190801/10faef6a/attachment.htm>
