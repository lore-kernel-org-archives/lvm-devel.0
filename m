From: PALAMEDE LP Ludovic (Exterieur.DCL) <ludovic.palamede@dexia.com>
Date: Thu, 2 Jun 2016 08:30:50 +0000
Subject: CLVMD in defunct mode
Message-ID: <732E8F3F83F60D458B9DD31DDDBA2A2374396A@FCEXSEXM030P.dcl.int.dexwired.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,
We experience a RHEL 5.8 Cluster LVM problem these days on our four nodes cluster which are sharing 55 services (mainly oracle databases). We use to make all our LVM duties from the first node and we manage our services (with clusvcadm -e RESSOURCE for example) from any node where it is lying at.

root     29727     1  0 May23 ?        00:10:54 [clvmd] <defunct>

Can you explain us if there is a way to avoid these issues? We do not want to reboot our entire cluster and we are not able to do no pvdisplay or vgdisplay or others LVMs duties right now. Can we remove the /var/lock/subsys/clvmd to use our LVM commands? Is a migration to the RHEL 6.8 a cure ? Please let us know what are the root cause of this problem and what would we apply to avoid this type of incident in the future.

Regards
LP

-------------------------------------------------------------------------
Dexia disclaimer:

http://www.dexia.com/maildisclaimer.htm <http://www.dexia.com/maildisclaimer.htm>
-------------------------------------------------------------------------
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20160602/4fbb1f5c/attachment.htm>
