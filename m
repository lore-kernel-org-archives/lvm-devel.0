From: Petr Rockai <prockai@redhat.com>
Date: Thu, 21 Oct 2010 18:36:22 +0200
Subject: [PATCH 2/4] Add lvseg 'get' functions.
In-Reply-To: <4CBED82F.7020702@redhat.com> (Zdenek Kabelac's message of "Wed, 
	20 Oct 2010 13:53:19 +0200")
References: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
	<1287494696-18310-3-git-send-email-dwysocha@redhat.com>
	<4CBED82F.7020702@redhat.com>
Message-ID: <874ocf7bax.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:
> I really think this API is wrong somewhere - there is way too many duplication
> - this isn't going to be very efficient....
> I do like the beauty of const strings....

I disagree. Having a consistent API is currently more important than
efficiency. We don't have any profile data, etc. So what you are asking
for is premature optimisation, IMO. We can ditch the duplication later
as needed. (Hopefully, we will be able to somewhat improve the general
memory allocation patterns used by LVM, independent of this. Presumably,
having better definitions of lifetimes of different things on a lower
layer would also make it feasible to rely on that lifetime in the
API. For now, I think it is a sound approach to just duplicate
everything to be on the safe side. Rule of thumb: get a working version
first, write tests, then worry about performance.)

Yours,
   Petr.


