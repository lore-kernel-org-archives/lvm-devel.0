From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Wed, 07 Jul 2010 13:55:52 +0200
Subject: [PATCH] Fix last 2 issues in clvmd init script to be LSB complaint
Message-ID: <4C346B48.6010700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

patch is pretty simple and straight forward.

With this patch we pass the 27 tests at 100%.

See https://bugzilla.redhat.com/show_bug.cgi?id=553381 for reference.

Thanks
Fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: clvmd_lsb_init.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100707/93d0525a/attachment.ksh>
