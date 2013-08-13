From: Oliver Rath <rath@mglug.de>
Date: Tue, 13 Aug 2013 20:00:08 +0200
Subject: Are there race conditions between pvcreate and vgcreate?
Message-ID: <520A7428.9000805@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi List,

i have a strange problem:

Sometimes a script runs into a failure "device /dev/sdb1 not found or
ignored by filtering" , but the devices are created just before

i.e.

pvcreate /dev/sda5 (1,4TB)
pvcreate /dev/sdb1 (2 TB)

..

vgcreate myvg /dev/sda5 /dev/sdb1

Are there any race conditions? If there are, exist any robust solution
for this? Im using lvm2-tools 2.02.99 + --with-thin=internal
--with-replicators=insternal

Tfh!

Oliver

--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel


