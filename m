From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 24 Aug 2021 14:26:23 +0200
Subject: Concurrent calls lvm create vs lvm remove
In-Reply-To: <CAFe+wq3Ag7Br9TtukOn2jSvqmXJMNM=Cq_7DU8WH2rDJ6kYV+Q@mail.gmail.com>
References: <CAFe+wq3Ag7Br9TtukOn2jSvqmXJMNM=Cq_7DU8WH2rDJ6kYV+Q@mail.gmail.com>
Message-ID: <f7b2ea74-7cc2-071c-ffa8-f5cccc7e6e7c@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23. 08. 21 v 15:25 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team!
> A very good day?to you.
> I want to understand how lvm concurrent calls between create and remove for 
> lvm volumes are handled.
> 
> Very rarely, I see that when create and remove lvm volume (over a thin pool) 
> run in parallel, lvm create fails with no vg. Looking at lvm metadata debug 
> logs, they seem slightly different with
> pv gone, removing empty VG, moving PV to #orphan, and a vg_update which
> eventually brings back everything.
> 
> How is this race between create and remove handled or more generally if it 
> applies, how are concurrent calls over lvm protected for consistency?
> Are applications supposed to handle this? I would assume no.
> 
> My environment is convoluted and may not apply directly, but your help in 
> pointing to current design and usage rules will help me immensely.
> 

Hi

I guess we need to dive a bit 'deeper' into the issue to actually see what 
kind of 'concurrent call' defect do you observe.

Recently there has been submitted 'trial' to cover-up the problem which may
cause failure of lvm2 commands during rapid changes of lvm2 metadata and 
scanning.  The problem is not 100% solved but should cover most users.

But this error basically caused only error during metadata scanning
(i.e. occasionally lvm2 reported broken metadata for a VG)

If you have some other type of problem I'd highly recommend to open
bugzilla so we could collect traces and see how the case with fixes evolves.

Solving this issue over the mailing list isn't usually the best since
tracking context becomes harder over the time.

If you use RHEL - open bug for corresponding version of your RHEL,
otherwise just go with community bug here:

https://bugzilla.redhat.com/enter_bug.cgi?product=LVM%20and%20device-mapper

Be sure you provide as much info (OS version and package version) as you can 
together with some logs (if possible) and some way how do you manage to 
reproduce your issue (for fixing it's always easiest/fastest if we can 
reproduce the issue ourself)

And just some generic answers to yous questions:

Manipulation with VG is protected by vgnamed lock - so 2 lvm commands cannot 
change lvm2 metadata for a VG at the same time - they need to wait to get 
'write-lock' on a VG.

Thin-pool itself may chain messages to thin-pool - however bugfixs or 
improvements have been made over the time to this communication mechanism - so 
it's very important you report your bug while you test latest release version 
of LVM (so we do not hunt for already fixed bugs)

Regards

Zdenek


