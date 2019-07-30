From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Tue, 30 Jul 2019 18:55:55 +0530
Subject: Reg unusual deployment within containers
Message-ID: <5d404562.1c69fb81.4641c.47b2@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team,
Thanks for being so prompt last time, I wanted to see whether I could be lucky again ?

My deployment of lvm2 is in an uncontrolled environment, so the host can be running any version.
My software stack runs within a container, as an infrastructure. So to be always stable, it has to have very little dependency or moving components outside.

Sharing the lvm bits from host to container will also not work because on host most of the build needs dynamic lib support.
This may not be available from within container. 


The first up easy question: 
1/ can lvm2 be built as a static binary with no external dependency? Any pointers to this ?

2/  The software stack bundles lvm2 package within the infrastructure container as well. 
Now, this results in two versions of lvm2 packages one within the container and the other on the host. To take this further up, to completely isolate version dependencies as well, system-udevd and lvmetad daemons are also running within the container.
This combination has been working, but I understand is definitely very strange and never thought out even during development.
So I wish to understand the impact of the above bundling, with possibly two copies of daemons and cache and udev running within/and outside the container.

Please do let me know if this bundle approach is a feasible approach to take to production? What possible issues that may come up that cannot be handled correctly, if any.  I am coming more from design validation, because you are the experts with how its designed internally. Looking forward to hearing your opinions.


Regards
LNS
Sent from Mail for Windows 10

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190730/4d687a74/attachment.htm>
