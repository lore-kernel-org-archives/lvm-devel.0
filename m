From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Apr 2019 13:32:15 +0200
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <CAKM4Aexm31mYW8WDeiZ4shCoysCcGjic8zV0XiVqEVZvKz-ecQ@mail.gmail.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
	<47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
	<CAKM4Aexm31mYW8WDeiZ4shCoysCcGjic8zV0XiVqEVZvKz-ecQ@mail.gmail.com>
Message-ID: <7839ff52-18e5-6a95-9a2a-12ea73457700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11. 04. 19 v 13:26 Eric Ren napsal(a):
> Hi?Zdenek,
> 
> Thanks for your reply. The use case is for containerd snapshooter, yes, all 
> lvm setup is on host machine, creating thin LV for VM-based/KATA container as 
> rootfs.
> 
> For example:
> https://github.com/containerd/containerd/pull/3136
> 
> and
> 
> https://github.com/containerd/containerd/pull/3022
> 
> So, we're evaluating such solution now~
> 

Hi

I could recommend to orient towards the solution where the 'host' system 
provides some service for your containers -  so container ask for action, 
service orchestrates the action on the system - and returns asked resource to 
the container.

IMHO I don't see any other usable solution ATM - although many container 
developers seems to endlessly try to run these system commands from a container...

Regards

Zdenek


