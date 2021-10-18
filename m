From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 18 Oct 2021 19:03:45 +0200
Subject: LVM2/libdm build system
In-Reply-To: <16d0cea1-35bd-f6d8-b307-33aba881951d@yuka.dev>
References: <16d0cea1-35bd-f6d8-b307-33aba881951d@yuka.dev>
Message-ID: <4905e48a-0607-0305-31cb-a4762794290f@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18. 10. 21 v 18:31 Yureka napsal(a):
> Hey everyone,
>
>
> I recently had to deal with the LVM2 build system a bit, and it was
> horrible. For example, in an environment where only static libraries
> (.a) are available, the build system would still try to build
> libdevmapper.so and fail. Also it was not easily possible to build only
> the libdm portions of the code base.
>
> The question: Would it be thinkable to switch the build system to
> something more modern like Meson or CMake? Are the maintainers
> interested in contributions like this?


Hi


Do you have some example of your problem ?


With 'static' linking - we are not able to support this since some libraries 
are not provided in static form (i.e. udev), while they are 'core' libraries. 
So ATM we may only support? those configuration where users do provide some 
valid patches.


There is currently no plan to switch to Meson or CMake as ATM we are quite 
happy with provided autoconf.

If you can see some problem (except? for 'static' build which is simply 
officially unsupported) - please provide traces so we can fix your problem.

Also - why would you actually need 'static' build - do you have some? 
non-standard linux distro ?


Regards



