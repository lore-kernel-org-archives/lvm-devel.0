From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 11 Feb 2008 16:22:05 -0500
Subject: [PATCH lvconvert] Fix missing warning on '-R|--regionsize' for already mirrored LV
Message-ID: <47B0BC7D.90305@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-R|--regionsize options for lvconvert only work when
converting from non-mirrored to mirrored.

        /*
         * Region size must not change on existing mirrors
         */
        if (arg_count(cmd, regionsize_ARG) && (lv->status & MIRRORED) &&
            (lp->region_size != seg->region_size)) {
                log_error("Mirror log region size cannot be changed on "
                          "an existing mirror.");
                return 0;
        }

However, the change in 2.02.30 about lvconvert to start polling if
no action specified, has missed the regionsize_ARG check
so it decided that 'no action was specified' before the warning.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-lvconvert-warn-on-wrong-regionsize-param.patch
Type: text/x-patch
Size: 1108 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080211/2bc90dec/attachment.bin>
