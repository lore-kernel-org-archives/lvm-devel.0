From: Petr Rockai <prockai@redhat.com>
Date: Sun, 24 Oct 2010 14:04:21 +0200
Subject: [PATCH 5/8] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <1287686377.5097.63.camel@f12-work> (Dave Wysochanski's message
	of "Thu, 21 Oct 2010 14:39:37 -0400")
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
	<1287487975-26572-6-git-send-email-dwysocha@redhat.com>
	<87sk008rcz.fsf@twilight.int.mornfall.net.>
	<1287686377.5097.63.camel@f12-work>
Message-ID: <87bp6j4x16.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
>> A is_integer might be useful here, for symmetry. In the client code, it
>> might not be obvious that !p.is_string means that it is an integer. It
>> would also improve API extensibility for the future, may we ever run
>> into a property that's neither string nor integer (although it won't
>> help with ABI).
>> 
>
> Ok, I've implemented this - easy.  But...
> Now that I think about it, rather than a bitfield and 'is_string' and
> 'is_integer", should we have a 'type' field and leave this an unsigned
> (for example, #define LVM_PROPERTY_TYPE_NUM 1 and #define
> LVM_PROPERTY_TYPE STR 2) or at least should we add padding to this
> struct?  The struct might warrant a bit more thought, given how much
> we've changed it recently, and given the ABI implications.

The advantage of the bitfield is that it is much more convenient to use
(and the resulting code more concise and clearer). It also does not
impose any ABI problems as long as you keep the items in the right
order. What can be done to ensure forward compatibility is this:

uint32_t foo:1;
uint32_t bar:1;
uint32_t _padding:30;

And when you need a new flag, just reduce the padding by one and add
your new flag between the existing flags and the padding.

> As the code is, the client does not need to check lvm_errno() unless it
> cares what went wrong.  In essence, v.is_valid "should =" !lvm_errno()
> today, though there's no explicit assignment.  However, if we explicitly
> assign v.is_valid = !lvm_errno(), then this assumes all error paths will
> properly set lvm_errno().  Otherwise, we may end up telling the user the
> value is valid when it may not be.  Now this case is clearly a bug but
> keeping them separate avoids the potential bug.  It's fairly clear right
> now that all error paths do properly set lvm_errno(), so this assignment
> would be safe today.
Ok.

Yours,
   Petr.


