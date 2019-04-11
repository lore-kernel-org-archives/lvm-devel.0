From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Apr 2019 13:03:56 +0200
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
Message-ID: <47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11. 04. 19 v 2:27 Eric Ren napsal(a):
> Hello list,
> 
> Recently, we're exercising our container environment which uses lvm to manage 
> thin LVs, meanwhile we found a very strange error to activate the thin LV:
> 


Hi


The reason is very simple here - lvm2 does not work from containers.
It's unsupported and if it partially works - it's a pure lucky case.

ATM it's simply clear statement that lvm2 cannot be used from container simply 
because block layer is not namespaced.

I'd give here long list of reason why it currently cannot work, but for now  - 
you should focus on making all 'device-block' operation on you host - and pass 
results to container.

Regards

Zdenek


