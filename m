From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 17 Jan 2008 03:38:05 -0500
Subject: [PATCH 1/2] Fix 'vgreduce --removemissing' on stacked mirror
Message-ID: <478F13ED.4080004@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'vgreduce --removemissing' is similar to lvconvert but is different in:
  - it removes any mirror images, not specifying the number
  - all images may be removed from the mirrored LV
  - mirrored LV itself may be removed

reconfigure_mirror_images() is the underlying function of vgreduce.

However, even with the recent patches of mine, reconfigure_mirror_images()
doesn't work well for stacked mirror.

Attached patch fixes it.

Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: fix-vgreduce-removemissing-on-stacked-mirror.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080117/20e1c4ac/attachment.ksh>
