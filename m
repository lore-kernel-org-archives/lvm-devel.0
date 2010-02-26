From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Fri, 26 Feb 2010 16:30:01 +0100
Subject: [RFC] New cmirrord init script
Message-ID: <4B87E8F9.5090103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This one is based on the new clvmd init script and it is LSB compliant.

One question, do we need to perform any kind of deactivation of mirrors
before we shutdown the daemon? and if yes, who?

Thanks
fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: cmirrord_init_red_hat.in
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100226/86e958a1/attachment.ksh>
