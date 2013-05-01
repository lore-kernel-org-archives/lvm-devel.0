From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 01 May 2013 15:38:50 -0500
Subject: vg activate/deactivate
Message-ID: <51817D5A.2000906@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I was looking at implementing vg activate/deactivate in lvm2app and I
see that the function vgchange_activate will fork a polling process for
monitoring.  Doing forks in a library is discouraged so I'm soliciting
suggestions for making this work without forking a process.

Thanks,
Tony


