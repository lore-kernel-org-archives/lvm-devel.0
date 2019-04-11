From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Apr 2019 14:12:05 +0200
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <CAKM4AezLrUrXZKA=vKMaRHcij3K6UBZpy-RcVXeUB9Wwfszh7Q@mail.gmail.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
	<47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
	<CAKM4Aexm31mYW8WDeiZ4shCoysCcGjic8zV0XiVqEVZvKz-ecQ@mail.gmail.com>
	<7839ff52-18e5-6a95-9a2a-12ea73457700@redhat.com>
	<CAKM4AezLrUrXZKA=vKMaRHcij3K6UBZpy-RcVXeUB9Wwfszh7Q@mail.gmail.com>
Message-ID: <62151b2e-c21a-177e-f66b-e2e08857be17@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11. 04. 19 v 13:49 Eric Ren napsal(a):
> Hi,
> 
>     Hi, 
> 
>     I could recommend to orient towards the solution where the 'host' system
>     provides some service for your containers -? so container ask for action,
>     service orchestrates the action on the system - and returns asked resource to
>     the container.
> 
> 
> Right, it's all k8s, containerd, OCI runtime are doing.
> 
> 
>     IMHO I don't see any other usable solution ATM - although many container
>     developers seems to endlessly try to run these system commands from a
>     container...
> 
> 
> Sorry, I don't make it clear. I mean we don't use lvm in container, we? use 
> thin pool on physical server, create thin LV, passthrough thin dm device into 
> virtual machine (KATA VM, not cgroup&namespce-based container) as VM's rootfs.
> 

Hi

So do you get  'partial' error on thin-pool activation on your physical server ?

Then you likely miss some PV on your system.

As that's the only way how lvm2 can give you this report - it cannot find all 
required PVs for the VG - so you cannot activate without partial activation.

You should easily spot which PV is missing with -vvvv  trace for
lvchange -ay

Regards

Zdenek


