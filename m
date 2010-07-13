From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Tue, 13 Jul 2010 18:45:37 -0400
Subject: [Patch]: Handle both devices of a mirrored log failing (bug 607347) - additional fix
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A592288651C@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jon,

On 07/08/10 17:48, Jonathan Brassow wrote:
> There was still potential for a hang after the last check-in to handle
> the scenario where both images of a mirrored log fail.  Taka, this
> should fix the hang you were seeing.

I found that this patch fixed the bug I was seeing.
Thank you for fixing it.

Thanks,
Taka


