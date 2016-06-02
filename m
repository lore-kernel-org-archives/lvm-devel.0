From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 2 Jun 2016 14:19:05 +0200
Subject: CLVMD in defunct mode
In-Reply-To: <732E8F3F83F60D458B9DD31DDDBA2A2374396A@FCEXSEXM030P.dcl.int.dexwired.net>
References: <732E8F3F83F60D458B9DD31DDDBA2A2374396A@FCEXSEXM030P.dcl.int.dexwired.net>
Message-ID: <5e0f8108-7a1a-1068-49ec-8d82def15c22@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.6.2016 v 10:30 PALAMEDE LP Ludovic (Exterieur.DCL) napsal(a):
> Hello,
>
> We experience a RHEL 5.8 Cluster LVM problem these days on our four nodes
> cluster which are sharing 55 services (mainly oracle databases). We use to
> make all our LVM duties from the first node and we manage our services (with
> clusvcadm ?e RESSOURCE for example) from any node where it is lying at.
>
>
>
> root     29727     1  0 May23 ?        00:10:54 [clvmd] <defunct>
>
>
>
> Can you explain us if there is a way to avoid these issues? We do not want to
> reboot our entire cluster and we are not able to do no pvdisplay or vgdisplay
> or others LVMs duties right now. Can we remove the /var/lock/subsys/clvmd to
> use our LVM commands? Is a migration to the RHEL 6.8 a cure ? Please let us
> know what are the root cause of this problem and what would we apply to avoid
> this type of incident in the future.
>
>

Hi

Certainly  6.8 clvmd is way better then 5.X whatever.

Crashed  clvmd usually means 'deeper' problem and without knowing deep 
internal details it's hardly solvable without reboot.

Regard

Zdenek



