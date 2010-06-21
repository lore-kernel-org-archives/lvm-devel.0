From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 21 Jun 2010 11:32:22 +0200
Subject: LVM2 ./WHATS_NEW libdm/libdm-deptree.c
In-Reply-To: <20100621085433.1811.qmail@sourceware.org>
References: <20100621085433.1811.qmail@sourceware.org>
Message-ID: <4C1F31A6.7090105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 21.6.2010 10:54, prajnoha at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	prajnoha at sourceware.org	2010-06-21 08:54:32
>
> Modified files:
> 	.              : WHATS_NEW
> 	libdm          : libdm-deptree.c
>
> Log message:
> 	Use early udev synchronisation and update of dev nodes for clustered mirrors.
> 	


I'd some discussion with Petr about related problems it looks like we have few 
things here.

1. I believe that cmirrord should be instructed by mirror kernel driver 
probably after receiving dm message from our activation code - not just 
automagicaly directly after resume code - as in this moment nodes are not yet 
ready in filesystem - and because of this 'race' we need to add this hack 
flag. However this is most probably 'API' redesign issue...

I think this strategy will be used in replicator - once we will start to used 
daemons like cmirrord for replicator - but we are not there yet...

2. Petr noticed there is not really well documented  'nowatch' rule inside 
udev, that probably should allow us to set  all 'non-toplevel' created nodes 
as 'non-watched' nodes - thus avoiding potential problem when we get nodes 
unexpectedly opened by some 'udev' rules. It should be probably possible to 
use this flag even in the case we create temporary toplevel devices for 
'clearing' _mlog while constructing i.e. mirror devices (or replicator logs) - 
so we should get 'immune' from 'random' tools opening our rather 'private' 
temporary device and blocking our deactivation code from work as devices get 
non-zero open count from some watch rule.

Zdenek


