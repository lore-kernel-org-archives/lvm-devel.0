From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 Jul 2011 13:16:08 +0200
Subject: Do not decode DM flags for device removal
In-Reply-To: <4E2D4EE6.5010204@redhat.com>
References: <4E2989DC.7070105@gmail.com> <4E2D4EE6.5010204@redhat.com>
Message-ID: <4E2D5078.5000701@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/25/2011 01:09 PM +0100, Peter Rajnoha wrote:
> So I'd say fine for now, but once there's a hook on REMOVE event anywhere,
> expecting the flags to be decoded, we need to take care of proper dependencies
> (among foreign packages vs. libdevmapper) if we revert this change back then.
> 

...though the only use I can imagine is that some libudev listener has
registered the device internally and then it needs to unregister it on
REMOVE. There's no point in running any scan from within udev rules on
that event since the device is already gone.

So doing some action on REMOVE event is possible and allowed, but its
use in the future is quite negligible and less probable...

Peter


