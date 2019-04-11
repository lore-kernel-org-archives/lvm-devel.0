From: Eric Ren <renzhengeek@gmail.com>
Date: Thu, 11 Apr 2019 19:49:46 +0800
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <7839ff52-18e5-6a95-9a2a-12ea73457700@redhat.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
	<47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
	<CAKM4Aexm31mYW8WDeiZ4shCoysCcGjic8zV0XiVqEVZvKz-ecQ@mail.gmail.com>
	<7839ff52-18e5-6a95-9a2a-12ea73457700@redhat.com>
Message-ID: <CAKM4AezLrUrXZKA=vKMaRHcij3K6UBZpy-RcVXeUB9Wwfszh7Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,


> Hi,

I could recommend to orient towards the solution where the 'host' system
> provides some service for your containers -  so container ask for action,
> service orchestrates the action on the system - and returns asked resource
> to
> the container.
>

Right, it's all k8s, containerd, OCI runtime are doing.


>
> IMHO I don't see any other usable solution ATM - although many container
> developers seems to endlessly try to run these system commands from a
> container...
>

Sorry, I don't make it clear. I mean we don't use lvm in container, we  use
thin pool on physical server, create thin LV, passthrough thin dm device
into virtual machine (KATA VM, not cgroup&namespce-based container) as VM's
rootfs.

Thanks,
Eric
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190411/c838034d/attachment.htm>
