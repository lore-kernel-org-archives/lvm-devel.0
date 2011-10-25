From: Milan Broz <mbroz@redhat.com>
Date: Tue, 25 Oct 2011 15:34:00 +0200
Subject: [PATCH] Fix vgchange for sparse devices
In-Reply-To: <Pine.LNX.4.64.1110250902480.16067@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1110250902480.16067@hs20-bc2-1.build.redhat.com>
Message-ID: <4EA6BAC8.2060303@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/25/2011 03:03 PM, Mikulas Patocka wrote:
> Fix vgchange for sparse devices
> 
> If we create a sparse snapshot volume with "lvcreate --virtualsize", the volume
> is not activated or deactivated with vgchange.

this is already in tree btw.

But there are several problems with virtual origins because it was never properly implemented.
https://bugzilla.redhat.com/show_bug.cgi?id=733522
https://bugzilla.redhat.com/show_bug.cgi?id=738435

Milan


