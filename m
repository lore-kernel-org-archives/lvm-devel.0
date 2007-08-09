From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 09 Aug 2007 13:56:07 -0400
Subject: [LVM2 PATCH] Add overflow check to find_config_int()
Message-ID: <46BB5537.6060609@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

find_config_int() and find_config_tree_int() are the function
to search throught the config tree and return the found value
or given default on failure.

Internally, the values are int64_t but implicitly casted to int
on return.

Though I think it doesn't matter in realistic configs,
it's better to check them and leave explicit log message.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-config-find-int-check-overflow.patch
Type: text/x-patch
Size: 1529 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/0e47d9e4/attachment.bin>
