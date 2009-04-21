From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 21 Apr 2009 20:47:09 +0200
Subject: [PATCH 1/4] Udev integration: add LVM fields support for dmsetup
In-Reply-To: <1240338923.3705.66.camel@f10-node1>
References: <49DC94D2.4010903@redhat.com> <1240338923.3705.66.camel@f10-node1>
Message-ID: <49EE14AD.7050502@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/21/2009 08:35 PM, Dave Wysochanski wrote:
> A couple minor cleanup comments for this patch set:
> 1. Warnings when compiling these patches. 
> ioctl/libdm-iface.c:867: warning: no previous prototype for ?dm_cookie_supported?
> dmsetup.c:332: warning: assignment discards qualifiers from pointer target type

Yes, I've noticed, too :) I've added proper casting here, so it's OK now...

> 2. whitespace / tabs - set to 8 spaces / tab?
> Areas I noticed were dm_cookie_supported() definitions and other
> indents.

...ok, I'll have a look

Thanks

Peter


