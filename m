From: Petr Rockai <prockai@redhat.com>
Date: Sun, 24 Oct 2010 23:06:15 +0200
Subject: [PATCH 4/4] Update tests for lvseg apis.
In-Reply-To: <4CC45DA0.4030509@redhat.com> (Zdenek Kabelac's message of "Sun, 
	24 Oct 2010 18:24:00 +0200")
References: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
	<1287494696-18310-5-git-send-email-dwysocha@redhat.com>
	<4CBEDBCE.1060400@redhat.com>
	<87zku75wmo.fsf@twilight.int.mornfall.net.>
	<4CC14AB6.9030407@redhat.com>
	<87lj5q61rn.fsf@twilight.int.mornfall.net.>
	<4CC45DA0.4030509@redhat.com>
Message-ID: <87sjzv2tdk.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:
> I'm not going to argue whether it's more or less efficient as in this case it
> will make no difference.  But passing things by value is simply very hardly
> supportable by dso libraries - and usually require complete rebuild of binary
> to use updated library. Also you would need to remember where are you using
> passing by value - and in case structure size grows - rewrite many functions
> to switch to pointers - why not do that right from the beginning? -  I'd pass
> by value only the language atomic/basic types - definitely not any structure
> where even you are pointing out future extensions in other post.

But there is a difference in adding bitfield values / union members and
adding new members to the structure! Both mentioned extensions are
ABI-compatible (within limits, see my other mails).

> BTW: I don't take vg_t/pv_t/lv_t as an an argument for passing things by value
> as it's nothing else that syntactical sugar for pointers - and in fact I'd not
> any objections against exactly same strategy for properties - making property
> object completely private structure to lvm and give the API user only handle
> lvm_property_t and set of function for this handle (C++ in C :))
> (i.e.
> lvm_property_is_string/get_string/is_integer/get_integer(lvm_property_t...)

That's both inefficient and extremely tedious to write and read. You
have to make some compromises, C is a low level language, and by no
means supports encapsulation or (gods forbid) OO. I will rather freeze
the structure ABI-wise than have to write

lvm_property_t p = lvm_get_property(...)
if (lvm_property_is_valid(p)) {
    if (lvm_property_is_string(p)) {
       const char *str = lvm_property_get_string(p);
       ...
    } else if (lvm_property_is_integer(p)) {
       int i = lvm_property_get_integer(p);
       ...
    }
}

In fact, I'd rather go for C++ than for Glib, if we want to have fancy
things in the API.

Yours,
   Petr.


