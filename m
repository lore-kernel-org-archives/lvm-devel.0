From: Eric Ren <zren@suse.com>
Date: Wed, 27 Dec 2017 16:48:03 +0800
Subject: [PATCH 0/2] LVM2: fix lvmetad udev rules for CHANGE events
In-Reply-To: <b041c704-6f2a-b20f-c33e-a93e7504ad4d@suse.com>
References: <20171221115705.5055-1-mwilck@suse.com>
	<1513943697.4257.14.camel@suse.com>
	<b041c704-6f2a-b20f-c33e-a93e7504ad4d@suse.com>
Message-ID: <d9c8ba0b-26b0-00c4-ff7f-12f660a763f9@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Martin,

> - very-confusing-result-with-patches.txt on x86_64
> This patches fixed the issue on the second testing, but re-occurs at the
> third testing. After that, I cannot get the PV back again.
>
> @Martin, can you try to repeat the steps more than 2 times on your 
> testing
> machine?

I tried more times. The problem doesn't occur any more. I suspect maybe it's
because there's something wrong during my manual testing - it's easy to 
mistake
following all those steps. I will try to put all steps into a testing 
script for more testing.

Thanks,
Eric


