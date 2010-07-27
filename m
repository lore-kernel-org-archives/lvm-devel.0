From: Petr Rockai <prockai@redhat.com>
Date: Tue, 27 Jul 2010 19:05:35 +0200
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices (v3)
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A592288657F@USINDEVS02.corp.hds.com>
	(Takahiro Yasui's message of "Fri, 23 Jul 2010 17:08:55 -0400")
References: <5C30BE7ED8B03E448B2E104602D4848A592288657F@USINDEVS02.corp.hds.com>
Message-ID: <876300am8w.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Takahiro Yasui <takahiro.yasui@hds.com> writes:
> This is a updated patch (v3) to limit accesses to broken devices.
>
> * v3 changes:
>   Reset a device error count per device when vg lock is acquired
>   or released, while a device error count is reset once in lvm
>   command execution in the v2 patch.

For all I can tell, taking into account previous discussions on this,
the patch looks OK.

Reviewed-By: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


