From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 21 Oct 2010 14:39:37 -0400
Subject: [PATCH 5/8] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <87sk008rcz.fsf@twilight.int.mornfall.net.>
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
	<1287487975-26572-6-git-send-email-dwysocha@redhat.com>
	<87sk008rcz.fsf@twilight.int.mornfall.net.>
Message-ID: <1287686377.5097.63.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2010-10-20 at 23:51 +0200, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> > + * This structure defines a single LVM property value for an LVM object.
> > + * The structures are returned by functions such as
> > + * lvm_vg_get_property() and lvm_vg_set_property().
> > + *
> > + * is_settable: indicates whether a 'set' function exists for this property
> > + * is_string: indicates whether this property is a string (1) or integer (0)
> > + * is_valid: indicates whether 'value' is valid (1) or not (0)
> > + */
> > +typedef struct lvm_property_value {
> > +	unsigned is_settable:1;
> > +	unsigned is_string:1;
> > +	unsigned is_valid:1;
> > +	union {
> > +		const char *string;
> > +		uint64_t integer;
> > +	} value;
> > +} lvm_property_value_t;
> 
> A is_integer might be useful here, for symmetry. In the client code, it
> might not be obvious that !p.is_string means that it is an integer. It
> would also improve API extensibility for the future, may we ever run
> into a property that's neither string nor integer (although it won't
> help with ABI).
> 

Ok, I've implemented this - easy.  But...
Now that I think about it, rather than a bitfield and 'is_string' and
'is_integer", should we have a 'type' field and leave this an unsigned
(for example, #define LVM_PROPERTY_TYPE_NUM 1 and #define
LVM_PROPERTY_TYPE STR 2) or at least should we add padding to this
struct?  The struct might warrant a bit more thought, given how much
we've changed it recently, and given the ABI implications.


> > +		}
> > +	} else if (lv) {
> > +		if (!lv_get_property(lv, &prop)) {
> > +			v.is_valid = 0;
> > +			return v;
> > +		}
> > +	}
> > +	v.is_settable = prop.is_settable;
> > +	v.is_string = prop.is_string;
> > +	if (v.is_string)
> > +		v.value.string = prop.value.string;
> > +	else
> > +		v.value.integer = prop.value.integer;
> > +	v.is_valid = 1;
> 
> Would it be more convenient to say v.is_valid = !lvm_errno(...) here?
> That way, the client code would not need to check lvm_errno unless it
> cared what went wrong. (The documentation above would need to be
> updated, too.)
> 

As the code is, the client does not need to check lvm_errno() unless it
cares what went wrong.  In essence, v.is_valid "should =" !lvm_errno()
today, though there's no explicit assignment.  However, if we explicitly
assign v.is_valid = !lvm_errno(), then this assumes all error paths will
properly set lvm_errno().  Otherwise, we may end up telling the user the
value is valid when it may not be.  Now this case is clearly a bug but
keeping them separate avoids the potential bug.  It's fairly clear right
now that all error paths do properly set lvm_errno(), so this assignment
would be safe today.

I think I'm going to leave this one as is, though perhaps clarify the
comments.  One of the near-term TODOs for lvm2app should probably be
take a look a the error paths anyway, and make any adjustments and/or
cleanups.  Maybe you can tackle this specific item on that TODO, and
once further testing is in place.




