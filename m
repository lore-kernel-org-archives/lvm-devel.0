From: thornber@redhat.com <thornber@redhat.com>
Date: Tue, 29 Jun 2010 09:09:18 +0100
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228864BB@USINDEVS02.corp.hds.com>
References: <5C30BE7ED8B03E448B2E104602D4848A59228864BB@USINDEVS02.corp.hds.com>
Message-ID: <877hliw98x.wl%thornber@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 28 Jun 2010 23:32:58 -0400,
Takahiro Yasui wrote:
> 
> Hi,
> 
> This is a patch to limit the number of accesses to broken devices.

This looks good to me.

I'm not terribly happy with the static variable holding the global max
error count, but recognise that this is consistent with other code.

Reviewed-by: Joe Thornber <ejt@redhat.com>


