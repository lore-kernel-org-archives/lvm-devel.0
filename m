From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 09 Aug 2007 13:52:35 -0400
Subject: [LVM2 PATCH] Fix 'lvconvert -s' to work again
Message-ID: <46BB5463.50708@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

In current CVS head, 'lvconvert -s' doesn't work.
 # lvconvert -s testvg/lvol0 testvg/lvol1
 --snapshots argument cannot be mixed with --mirrors or --log
 lvconvert: Change logical volume layout

This is due to the lvconvert parameter check uses
'count' variable uninitialized for non-mirror case.
        int count;
...
        if (arg_count(cmd, log_ARG) || arg_count(cmd, mirrors_ARG))
                count = 1;
        count += arg_count(cmd, snapshot_ARG);

While the code around the _read_params() could be tidied up
some more, I hope this fix is included for now.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvconvert-fix-arg-mixture-check.patch
Type: text/x-patch
Size: 655 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/0a718685/attachment.bin>
