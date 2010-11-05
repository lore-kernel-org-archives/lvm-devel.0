From: Vitaly Kuznetsov <vitty@altlinux.ru>
Date: Fri, 05 Nov 2010 11:56:42 -0000
Subject: [PATCH] Fix dmeventd path check
Message-ID: <8739rg7zmq.fsf@vps2.branbackup.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I found a small bug in _start_server in daemons/dmeventd/libdevmapper-event.c: 

There is a possibility to change dmeventd_path by setting "executable"
parameter in config. But it will not work if there is no executable at
default DMEVENTD_PATH due to error in check: we must check args[0]
(which is dmeventd_path ? : default_dmeventd_path) instead of
DMEVENTD_PATH for existence. My patch fix this small issue.

-- 
Vitaly Kuznetsov, ALT Linux

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-2.02.75-alt-dmeventd-path.patch
Type: text/x-diff
Size: 573 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101105/1365565d/attachment.bin>
