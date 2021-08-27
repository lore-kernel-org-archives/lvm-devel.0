From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 27 Aug 2021 13:40:38 +0200
Subject: Concurrent calls lvm create vs lvm remove
In-Reply-To: <CAFe+wq26FEmQPe-AAao3Q1r-m9KQPw6MK0uE0GxGUrAw3fR_Yw@mail.gmail.com>
References: <CAFe+wq3Ag7Br9TtukOn2jSvqmXJMNM=Cq_7DU8WH2rDJ6kYV+Q@mail.gmail.com>
	<f7b2ea74-7cc2-071c-ffa8-f5cccc7e6e7c@redhat.com>
	<CAFe+wq26FEmQPe-AAao3Q1r-m9KQPw6MK0uE0GxGUrAw3fR_Yw@mail.gmail.com>
Message-ID: <0990a7b5-4f94-c818-5ce9-19736e57ed98@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27. 08. 21 v 11:23 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Zdenek,
> Thank you for your email explaining in some detail.
>
> My environment is slightly convoluted and has a container.
> I perform the following from within a container, which uses lvm2app to
> make the call.
> in a loop:
> a/ lvm thin volume create.
> b/ do read/write IOs to the lvol
> c/ lvm thin volume delete.


Ok I think we can stop right here.

Bad news is -? lvm2 is not supported to work withing container - numerous 
people tend to try this - and will always end with unsolvable problem - so let 
just repeat again - containers are not 'lightweight' VM with same features, 
just faster ;)? Devices and DM subsystem are not a containerized resource.

There could be named a very long list of problems why lvm2 can't support this. 
So while it may appear it does work temporarily it simply will not work reliable.

Some 'inovators' try to use so called 'super-priviledged' containers to 
forward lvm2 jobs to this one and then reroute results to container which 
could be some sort of way - but it's very difficult task.

> I enabled debug logs from the lvmetad running at the host. As one can
> see, sometimes pv_gone message is received by lvmetad.

Do not even try to use lvmetad within container - it can't work at all.

And since you are still with lvmetad - you are likely on some old version of lvm2.


So best advice here is - whatever you try to design - try to do it in a 
different way, so you could use? 'lvm2' commands on your system and then pass 
created device to containers.

There is no good way to run lvm2 correctly from a container unless you 
massively restrict your environment (but then what's the point with containers).


Regards


Zdenek



