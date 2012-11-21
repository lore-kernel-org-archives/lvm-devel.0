From: Sherman Ma <sma@vmem.com>
Date: Wed, 21 Nov 2012 13:19:17 -0800
Subject: Violin Memory SSD array device support
In-Reply-To: <CCD19AF4.229%sma@vmem.com>
Message-ID: <CCD28524.25F%sma@vmem.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


  I would like to add Violin Memory's SSD array device (vtms) support in
LVM2.
The following is the change list:

sma at eng-builds-fir:~/git/lvm2/lib/filters$ git diff
diff --git a/lib/filters/device-types.h b/lib/filters/device-types.h
index 9efbe68..bc0cfc6 100644
--- a/lib/filters/device-types.h
+++ b/lib/filters/device-types.h
@@ -56,5 +56,6 @@ static const device_info_t _device_info[] = {
        {"blkext", 1},          /* Extended device partitions */
        {"fio", 16},            /* Fusion */
        {"mtip32xx", 16},       /* Micron PCIe SSDs */
+       {"vtms", 16},           /* Violin Memory */
        {"", 0}
 };

Any comments before I submit the change?
Thanks,

- Sherman


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20121121/2ff2dc94/attachment.htm>
