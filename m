From: Eric Ren <zren@suse.com>
Date: Fri, 29 Sep 2017 20:57:57 +0800
Subject: lvmlockd: "lvm_global" lockspace cannot be closed normally
Message-ID: <31b56a90-9c21-6b7c-881b-1fa04741885d@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David,

I encountered this problem pretty often when I play with lvmlockd.
"lvm_global" will stay on the system. It can be closed if using 
`dlm_tool leave lvm_global`.
But, the dlm_tool command will hang there.

It's not hard to reproduce to follow bug report [1]. Just ignore it if 
you cannot reproduce
on redhat distro, sorry I don't have time to do that currently.

[1] [lvmlockd] "lvm_global" lockspace always fails to close -
 ???? https://bugzilla.suse.com/show_bug.cgi?id=1060654

Thanks,
Eric

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20170929/d2afca03/attachment.htm>
